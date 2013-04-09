classdef TaskController < handle
    properties (SetObservable = true) 
        computerName = 'ltcbg-bryant';
        SimulationMode = true;
        ProgramRoot = 'Y:\'
        ProgramName = 'URL_Download' 
        MacroName = 'Stox'
        PID = NaN
        State
        Dos_Shell
        TaskList
        RunTask
        TaskKill
        remoteShareDir = 'S:\DOS\'
    end
    properties (SetObservable = true)  % STATUS
        MacroFolder = 'Y:\URL_Download\Macros\'
    end
    properties (Hidden = true)
        MacroName_LUT = [];        
        ProgramName_LUT = { 'URL_Download'; ...
                            'WebPageDecoder'};
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
            delete(timerfindall)
            
            %%
            obj = TaskController('SimulationMode', true)
            ObjectInspector(obj)
        end
        function RUN_Task(obj)
            %%
            if obj.SimulationMode == true
                obj.Dos_Shell.ControllerMode = 'MasterSim';
            else
                obj.Dos_Shell.ControllerMode = 'Master';
            end
            
            %%
            obj.Dos_Shell.remoteShareDir = obj.remoteShareDir;
            obj.RunTask.Dos_Shell.remoteShareDir = obj.remoteShareDir;
            obj.RunTask.Dos_Shell.selectedComputerName = obj.computerName;
            
            %%
            DATASET = obj.GetTaskList;
            x = size(DATASET,1);
            y = x;

            
            %%
            obj.RunTask.ProgramName = [obj.ProgramName,'.exe'];
            obj.RunTask.MacroName = obj.MacroName;
            obj.RunTask.RUN;
            while x == y
                NEW_DATASET = obj.GetTaskList;
                y = size(NEW_DATASET,1);
            end
            PID = NEW_DATASET{y,2};
            obj.PID = PID;
        end
        function KillTask(obj)
            if obj.SimulationMode == true
                obj.Dos_Shell.ControllerMode = 'MasterSim';
            else
                obj.Dos_Shell.ControllerMode = 'Master';
            end
            
            % check PID still exists
            obj.TaskKill.PID = double(obj.PID);
            logic = obj.CheckPIDExists(obj.PID);
            if logic == false
                obj.PID = NaN;
                error('can''t kill process as it does not exists') 
            end
            

            obj.TaskKill.PID = double(obj.PID);
            obj.TaskKill.RUN();
            
            % check PID ends
            while logic == true
                logic = obj.CheckPIDExists(obj.PID);
            end
            obj.PID = NaN;
        end
    end
    methods (Hidden = true)
        function obj = TaskController(varargin)
            x = size(varargin,2);
            for i = 1:2:x
                obj.(varargin{i}) = varargin{i+1};
            end
            
            %% set macro folder
            obj.MacroFolder = fullfile(obj.ProgramRoot,obj.ProgramName,'Macros\');
            obj.Dos_Shell = DOS_Command_Logger( 'remoteShareDir',   'Y:\URL_Download\Swap\');
                
            %%
            obj.TaskList = mTaskList(    'computerName', obj.computerName, ...
                                         'Dos_Shell',    obj.Dos_Shell);
            obj.RunTask = mDosRunTask(   'computerName', obj.computerName, ...
                                         'ProgramName', [obj.ProgramName,'.exe'], ...
                                         'MacroName',    obj.MacroName);
            obj.TaskKill = mDosTaskKill( 'Dos_Shell',    obj.Dos_Shell);
            imageIO = ImageIO;
            imageIO.ImageType = '.m';
            imageIO.Path = obj.MacroFolder;
            imageIO.RUN;
            names = imageIO.names;
            n = find(not(strcmpi(names,'none.m')));
            names = names(n);
            obj.MacroName_LUT = strrep(names,'.m','');
            
            %%
            obj.State = obj.RunTask.Dos_Shell.State;
            addlistener(obj.RunTask.Dos_Shell,'State','PostSet',@obj.UpdateState)
            obj.Dos_Shell.remoteShareDir = obj.remoteShareDir;
        end
        function UpdateState(varargin)
            disp('updating state')
            obj = varargin{1};
            obj.State = obj.RunTask.Dos_Shell.State;
            if strcmpi(obj.State,'finished')
                obj.PID = NaN;
            end
        end
        function logic = CheckPIDExists(obj,PID)
            obj.TaskList.filter_name = 'PID';
            obj.TaskList.filter_value = PID;
            obj.TaskList.RUN();
            DATASET = obj.TaskList.DATASET;
            x = size(DATASET,1);
            if x > 0
                logic = true;
                disp(['Process ID ', num2str(PID),' is running'])
            else
                logic = false;
                disp(['Process ID ', num2str(PID),' is not running'])
            end
        end
        function DATASET = GetTaskList(obj)
            obj.TaskList.filter_name = 'imagename';
            obj.TaskList.filter_value = [obj.ProgramName,'.exe'];
            obj.TaskList.computerName = obj.computerName;
            obj.TaskList.RUN();
            DATASET = obj.TaskList.DATASET;
        end
    end
end