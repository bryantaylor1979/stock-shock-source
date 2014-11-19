classdef URL_Download < handle & ...
                        MacroRun
    %TODO: GetRequiredSymbols Working.
    properties
        MapName = 'III_IndexMap'
        Method = 'url' %url | url2 | wq | xml
        WaitbarEnable = false
        sURL
        eURL
        timeout = 200;
        t1 = 100000; 
        InstallDir = [];
        RunOnInt = 'on'
        ProgramName = 'URL_Download';

        SymbolInfo_OBJ = [];
        ResultsLog_OBJ = [];
        WebQuery_OBJ = [];
    end
    properties
        IllegalSymbols = {'CON'}; %Add symbols here if you get a save error.
    end
    %TODO: CON__ load ? I think this is now working
    methods (Static)
        function Example()
           %%
           close all
           clear classes
           
           %%
           URL_Download('Macro','Stox','WaitbarEnable',true);
           
           %%
           URL_Download('Macro','BritishBulls_HIST','WaitbarEnable',true);
           
           %%
           obj = URL_Download('Macro','BritishBulls_HIST','RunOnInt',false);
        end         
    end
    methods (Hidden = false)
        function Symbols = GetRequiredSymbols(obj,Program,MacroName,Date)
            %% Required Symbols
            [Data] = obj.III_IndexMap;
            RequiredSymbols = Data(:,2);
            
            %% Saved Symbols List
            try
                SavedSymbols = obj.GetSaveType_Symbols('URL',Program,MacroName,Date);
            catch
                disp('No symbols found')
                Symbols = RequiredSymbols;   
                return
            end
            [Symbols] = obj.RemoveSymbols(RequiredSymbols,SavedSymbols);
        end
        function DownloadAllURL(obj,Symbols,ProgramName,ResultName,Date,MacroName)
            %
            disp(['Executed: ',datestr(now)])
            
            %Intialise a waitbar if not visible
            try
                get(obj.handles.figure);
            catch
                if obj.WaitbarEnable == true
                    h = waitbar(0);
                    position = get(h,'position');
                    position(4) = 75;
                    set(h,'position',position)
                else
                    h = 1; 
                end
            end

            %% Load Objects
            %Verfied - The symbols 
            [x] = size(Symbols,1);
            tic
            disp(['URL_Download - ',obj.Macro])
            for j = 1:x
                  if obj.WaitbarEnable == true
                      waitbar((j)/x,h,{['URL_Download -',obj.Macro];['Processing... ',num2str(j),' of ',num2str(x),' (',num2str(round(j/x*100)),'%)']})
                      drawnow;
                  else
                      disp(['Processing... ',num2str(j),' of ',num2str(x),' (',num2str(round(j/x*100)),'%)'])
                  end
                  Symbol = strrep(Symbols{j},'.L','');
                  obj.DownloadURL(Symbol,ProgramName,ResultName,Date);
            end
            pause(5);
            if obj.WaitbarEnable == true
                close(h)
            end
        end
        function s = DownloadURL(obj,Symbol,ProgramName,ResultName,Date)
            time = 1;
            while time < obj.timeout
                try 
                    url = [obj.sURL,Symbol,obj.eURL];
                    disp(url);
                    switch lower(obj.Method)
                        case 'xml'
                            s = parseXML(url);
                        case 'url'
                            s = urlread(url);
                        case 'url2'
                            s = urlread2(url,[],[],obj.t1);                         
                        case 'wq'
                            s = obj.WebQuery_OBJ.ReadWebQuery(url); 
                        otherwise
                            error('method not recognised')
                    end
                    break
                catch
                    disp(['Connection problems, Wait: ',num2str(time)])
                    pause(time);
                    time = time*2;
                end
            end
            if obj.timeout <= time
               s = [];
               Error = -2;
               warning(['Failed to download: ',Symbol])
               return 
            end 
            
            n = find(strcmpi(Symbol,obj.IllegalSymbols), 1);
            if not(isempty(n))
                Symbol = [Symbol,'__'];
            end
            obj.ResultsLog_OBJ.SaveResult_Type(s,Symbol,ProgramName,ResultName,upper(obj.Method),Date);
        end
    end
    methods (Hidden = true)
        function [Symbols] = RemoveSymbols(~,array1,array2)
            % remove small array from the big symbol array
            % order doesn't matter.
            % input array must be column-wise

            small_array = strrep(array1,'.L','');
            big_array = strrep(array2,'.L','');
            Symbols = [];

            [x] = size(small_array,1);
            [y] = size(big_array,1);

            for i = 1:x %first symbol to remove
                n = find(strcmpi(small_array{i},big_array), 1);
                if isempty(n)
                    Symbols = [Symbols;small_array(i)];
                end
            end
        end
        function obj = URL_Download(varargin)           
            % set-up defaults
            [path,~,~] = fileparts(which('URL_Download'));
            obj.InstallDir = path;         
            obj.MacroLogDir = path;    
            
            disp('Start URL Download')
            [x] = size(varargin,2);
            for i = 1:2:x
                obj.(varargin{i}) = varargin{i+1};
            end
            
            % Load Objects
            obj.SymbolInfo_OBJ = SymbolInfo('MapName',      obj.MapName);
            obj.ResultsLog_OBJ = ResultsLog('ResultsDir',   fullfile(path,'Results'));
            
            if isempty(obj.Macro)
                PWD = pwd;
                cd(fullfile(obj.InstallDir,'Macros'))
                d = dir;
                str = {d.name};
                str = str(3:end);
                [s,v] = listdlg('PromptString',['(',obj.Rev,') Select a file:'],...
                                'SelectionMode','single',...
                                'ListString',str);
                drawnow;
                obj.Macro = str{s};
                cd(PWD)
            end
            
            if strcmpi(obj.RunOnInt,'on');
                obj.RunMacro(obj.Macro);
            end
            
            try
            close(obj.handles.figure)
            end
        end
        % The CalculateTime function is not currently being used. The time
        % is calculate anyway by jenkins. May not be required anymore. 
        function TimeStr = CalculateTime(~,Seconds) %Add this in to the batcher. (Once the batcher is adopted)
            secs = round(Seconds);
            minutes = floor(secs/60);
            hours = floor(minutes/60);
            min = minutes - hours*60;
            secs = secs - minutes*60;
            TimeStr = [num2str(hours),'h ',num2str(min),'m ',num2str(secs),'s'];
        end  
    end
end