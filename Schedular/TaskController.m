classdef TaskController < handle
    properties (SetObservable = true)    
        ProgramRoot = 'Y:\'
        ProgramName = 'URL_Download' 
        MacroName = 'Stox'
        PID = NaN
        State
        TaskList
        RunTask
        TaskKill
    end
    properties (SetObservable = true)  % STATUS
        MacroFolder = 'Y:\URL_Download\Macros\'
    end
    properties (Hidden = true)
        MacroName_LUT = [];        
        ProgramName_LUT = { 'URL_Download'; ...
                            'WebPageDecoder'};
    end
    methods
        function Example(obj)
            %%
            close all
            clear classes
            
            %%
            obj = TaskController
            ObjectInspector(obj)
        end
        function RUN_Task(obj)
            DATASET = obj.GetTaskList;
            x = size(DATASET,1);
            y = x;
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
            % check PID still exists
            obj.TaskKill.PID = obj.PID;
            logic = obj.CheckPIDExists(obj.PID);
            if logic == false
                obj.PID = NaN;
                error('can''t kill process as it does not exists') 
            end
            

            obj.TaskKill.PID = obj.PID;
            obj.TaskKill.RUN();
            
            % check PID ends
            while logic == true
                logic = obj.CheckPIDExists(obj.PID);
            end
            obj.PID = NaN;
        end
    end
    methods (Hidden = true)
        function obj = TaskController()
            %% set macro folder
            obj.MacroFolder = fullfile(obj.ProgramRoot,obj.ProgramName,'Macros\');
                
            %%
            obj.TaskList = mTaskList();
            obj.RunTask = mDosRunTask(  'ProgramName', [obj.ProgramName,'.exe'], ...
                                        'MacroName',    obj.MacroName);
            obj.TaskKill = mDosTaskKill;
            imageIO = ImageIO;
            imageIO.ImageType = '.m';
            imageIO.Path = obj.MacroFolder;
            imageIO.RUN;
            names = imageIO.names;
            n = find(not(strcmpi(names,'none.m')));
            names = names(n);
            obj.MacroName_LUT = strrep(names,'.m','');
            
            %%
            obj.State = obj.RunTask.DosShell.State;
            addlistener(obj.RunTask.DosShell,'State','PostSet',@obj.UpdateState)
        end
        function UpdateState(varargin)
            obj = varargin{1};
            obj.State = obj.RunTask.DosShell.State;
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
            obj.TaskList.RUN();
            DATASET = obj.TaskList.DATASET;
        end
    end
end