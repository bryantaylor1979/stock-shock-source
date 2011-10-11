classdef MacroRun < handle
    properties
        Macro
        MacroLogDir = 'X:\'
    end
    properties (Hidden = true)
        MR_Rev = 0.02;
    end
    methods (Hidden = true)
        function logic = Command(obj,line,command)
            formatch = strmatch(command,line);
            logic = not(isempty(formatch));
        end
        function text = ReadFileByLine(obj,Name)
            try
                text = textread(Name,'%s','delimiter','\n','whitespace','');
            catch
                disp(['File not found: ',Name])
            end           
        end
        function ExecuteLine(obj,Line)
            try
                disp(Line)
                
            catch
                error(['Macro Line  :',Line])
            end
        end
        function LogEvent(obj,Name,Msg)
            %%
            PWD = pwd;
            Path = [obj.MacroLogDir,'Generic\MacroEvents\']
            String = [Path,strrep(datestr(today),'-','_'),'.mat']
            
            %% Does folder exist, if not create folder.
            try
                cd(Path)
            catch
                mkdir(Path)
            end
            
            %% Latest Event
            ProgramName = {obj.ProgramName};
            MacroName = {Name};
            N_DATASET = dataset(  {ProgramName,'ProgramName'}, ...
                                {MacroName,'MacroName'}, ...
                                {{Msg},'Event'}, ...
                                {{datestr(now,'HH:MM:SS')},'DateStamp'});
            
            %%
            try
                load(String)
                disp('load')
                DATASET = [N_DATASET;DATASET]
            catch
                DATASET = N_DATASET;
            end
            save(String,'DATASET')
            
            %%
            cd(PWD)
        end
    end
    methods (Hidden = false)
        function DATASET = RunMacro(varargin)
            obj = varargin{1};
            Name = varargin{2};
            
            Name = strrep(Name,'.m','');
            PWD = pwd;
            string = [obj.MacroLogDir,obj.ProgramName,'\MacroLog\',Name];
            
            %%
            try
                cd(string)
            catch
                mkdir(string)    
            end
            cd(PWD);
            %%
            string = [string,'\log',strrep(datestr(now),':','_'),'.txt'];
            
            %%
            diary(string)
            disp(['Time Start: ',datestr(now)])
            Name = [obj.InstallDir,'Macros\',Name,'.m'];
            varargin{2} = Name;
            [DATASET, Error] = obj.ExecuteMacro(varargin(2:end));
            if Error == -1
                obj.LogEvent(Name,'MacroNotFound');
            elseif Error == -2
                obj.LogEvent(Name,'Fail');
            end
                
            disp(['Time End: ',datestr(now)])
            diary off
        end
        function [DATASET, Error] = ExecuteMacro(obj,varargin)
            % Error Codes:
            %    0: Successful.
            %   -1: Can't find file
            %   -2: General Execution Error
            %%
            varargin = varargin{1};
            x = max(size(varargin));
            if iscell(varargin)
                Name = varargin{1};
                for i = 2:2:x
                    Val = varargin{i+1};
                    if strcmpi(class(Val),'char')
                        Val = ['''',Val,''''];
                    else
                        Val = num2str(Val);
                    end
                    eval([varargin{i},' = ',Val])
                end
            else
                Name = varargin;
            end
            %%
            Error = 0;
            try
                text = obj.ReadFileByLine(Name);
            catch
                Error = -1;
                return
            end
            
            try
                DATASET = [];
                [x] = size(text,1);
                btext = [];
                FORSTART = false;
                skip = false;
                for i = 1:x
                    btext = [btext,strrep(text{i},'...','')];
                    logic = obj.Command(btext,'for');
                    if and(logic == true,FORSTART == false)
                        disp(['for loop start: ',text{i}])
                        FORSTART = true;
                    end
                    if FORSTART == true
                        End = strrep(text{i},' ','')
                        logic = obj.Command(lower(End),'end');
                        if logic
                            FORSTART = false;
                            try
                            obj.ExecuteLine([btext]);
                            catch
                               x = 1; 
                            end
                            eval([btext]);
                            btext = []; 
                            skip = true;
                        else
                            temp = strrep(text{i},' ','');
                            if not(isempty(temp))
                            btext = [btext,','];
                            end
                        end
                    else
                        if isempty(findstr(text{i},'...'))
                            obj.ExecuteLine(btext);
                            eval(btext)
                            btext = []; 
                        end
                    end
                end  
            catch
                Error = -2;
            end
        end
    end
end