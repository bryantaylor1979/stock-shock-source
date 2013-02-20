classdef mDosRunTask <  handle 
    properties (SetObservable = true)
        Mode = 'batch'; %system or batch
        Path = 'Y:\URL_Download\';
        ProgramName = 'URL_Download.exe';
        MacroName = 'Stox';
        DosShell
    end
    properties (Hidden = true)
        handles
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
            ArgStr = '"Macro" "BritishBulls_ALLSTATUS" "AgentName" "Agent1"';
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
            obj.DosShell = DOS_Command_Logger(  'ProgramName','mDosRunTask', ...
                                                'Path',obj.Path, ...
                                                'Mode',obj.Mode);
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
            obj.DosShell.Path = Path;
            obj.DosShell.Mode = obj.Mode;
            obj.DosShell.CommandStr = CommandString;
            obj.DosShell.RUN;
        end
    end
end