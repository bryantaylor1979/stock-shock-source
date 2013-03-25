classdef mDosRunTask <  handle 
    properties (SetObservable = true)
        computerName
        Mode = 'batch'; %system or batch
        Path = 'Y:\URL_Download\';
        ProgramName = 'URL_Download.exe';
        MacroName = 'Stox';
        Dos_Shell
    end
    properties (Hidden = true)
        handles
        computerName_LUT = {    'mediapc'; ...
                             	'mt'; ...
                            	'ltcbg-bryant'};
    end
    methods
        function Example(obj)
            %%
            close all
            clear classes
            
            %%
            obj = mDosRunTask
            ObjectInspector(obj)
            
            
            %%
            Path = 'Y:\URL_Download\';
            ExeName = 'URL_Download_Agent1.exe';
            ArgStr = '"Macro" "BritishBulls_ALLSTATUS"';
            obj.RunExecutable( Path,  ExeName, ArgStr)
                        
            %%
            destroy(worker)
        end
        function RUN(obj)
            obj.RunProgram(  	obj.Path, ...
                            	obj.ProgramName, ...
                             	obj.MacroName);
        end
    end
    methods (Hidden = true) % Schedualar
        function obj = mDosRunTask(varargin)
            x = size(varargin,2);
            for i = 1:2:x
                obj.(varargin{i}) = varargin{i+1};
            end
            %%
            if isempty(obj.Dos_Shell)
            obj.Dos_Shell = DOS_Command_Logger(     'ProgramName','mDosRunTask', ...
                                                    'Path',obj.Path, ...
                                                    'Mode',obj.Mode);
            end
            obj.handles.DataSetFiltering = DataSetFiltering;
        end
    end
    methods (Hidden = true) %Create Task functions.
        function job = RunProgram(obj,Path,ProgamName,MacroName)
            disp(['Running: ',ProgamName,'-',MacroName])
            ArgStr = ['"Macro" "',MacroName,'"'];
            obj.RunExecutable(Path, ProgamName, ArgStr)
        end
        function RunExecutable(obj,Path, ExeName, ArgStr)
            %%
            CommandString = [ExeName,' ', ArgStr];
            obj.Dos_Shell.Path = Path;
            obj.Dos_Shell.Mode = obj.Mode;
            obj.Dos_Shell.CommandStr = CommandString;
            obj.Dos_Shell.RUN;
        end
    end
end