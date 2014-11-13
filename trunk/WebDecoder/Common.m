classdef Common < handle & ...
                  MacroRun
    properties
        SettingsDir = 'C:\SourceSafe\Stocks & Shares\Programs\WebDecoder\';
    end
    methods
        function struct = GetConfig(obj,ProgramName,TrainerName)
            file = fullfile(obj.InstallDir,'DecodeTrainers',ProgramName,[TrainerName,'.m']);
            struct = obj.GetConfigFullPath(file);  
            try
            struct = obj.ReplaceIllegalChars(struct);
            end
        end
        function s = GetURL(obj,ProgramName,TrainerName)
            file = fullfile(obj.InstallDir,'DecodeTrainers',ProgramName,[TrainerName,'.mat']);
            load(file);             
        end
        function [struct] = ReplaceIllegalChars(obj,struct)
            %%
            Perc = '<&Per&>';
            x = max(size(struct))
            for i = 1:x
                struct(i).StartString = strrep(struct(i).StartString,Perc,'%');
                struct(i).EndString = strrep(struct(i).EndString,Perc,'%');
            end
        end     
    end
    methods (Hidden = true)
        function struct = GetConfigFullPath(obj,Name)
            % Error Codes:
            %    0: Successful.
            %   -1: Can't find file
            %   -2: General Execution Error
            Error = 0;
            try
                text = obj.ReadFileByLine(Name);
            catch
                Error = -1;
                return
            end
            
            try
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