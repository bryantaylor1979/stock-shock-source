classdef mTaskManager < handle & ...
						DOS_Command_Logger & ...
                        DataSetFiltering
    properties
    end
    methods
        function Example(obj)
            %%
            close all
            clear classes
            obj = mTaskManager
            
            %%
            get(job,'State')
            
            %% find jobs
            findJob(sched)
            
            %%
            obj.DispSchedularTasks
            
            %%
            obj.RemoveAllCompletedTasks()
            
            %%
            fetchOutputs(job)
            
            %%
            Path = 'Y:\URL_Download\';
            ProgramName = 'URL_Download.exe';
            MacroName = 'Stox';
            job = batch(@(x,y)obj.RunProgram(Path,ProgramName,MacroName),0); 
            
            %%
            job = obj.RunBatchProgram(Path,ProgramName,MacroName);
            
            %%
			obj = mDosTaskList( 	'filter_imagename_Enable',      true, ...
									'filter_imagename',              'URL_Download.exe', ...
									'filter_imagename_operator',    'eq'); 	%ne, eq
			DATASET = obj.TaskList
            
            %% 
            PID = obj.GetColumn(DATASET,'PID')
            
            %%
            Path = 'Y:\URL_Download\';
            ExeName = 'URL_Download_Agent1.exe';
            ArgStr = '"Macro" "BritishBulls_ALLSTATUS" "AgentName" "Agent1"';
            obj.RunExecutable( Path,  ExeName, ArgStr)
        end
    end
    methods % Schedualar
        function DispSchedularTasks(obj)
            sched = findResource();
            jobs = findJob(sched)
        end
        function [pending queued running completed] = GetScheduledTasks(obj)
            sched = findResource();
            [pending queued running completed] = findJob(sched)
        end
        function DestroyAllPendingTasks(obj)
            %%
            [pending queued running completed] = obj.GetScheduledTasks();
            x = size(pending,1);
            for i = 1:x
                destroy(pending(i));
            end
        end
        function RemoveAllCompletedTasks(obj)
            [pending queued running completed] = obj.GetScheduledTasks();
            x = size(completed,1);
            for i = 1:x
                destroy(completed(i));
            end            
        end
    end
    methods %Create Task functions.
        function job = RunBatchProgram(obj,Path,ProgramName,MacroName)
            job = batch(@(x,y)obj.RunProgram(Path,ProgramName,MacroName),0);            
        end
        function RunProgram(obj,Path,ProgamName,MacroName)
            disp(['Running: ',ProgamName,'-',MacroName])
            ArgStr = ['"Macro" "',MacroName,'"'];
            obj.RunExecutable(Path, ProgamName, ArgStr)
        end
        function RunExecutable(obj,Path, ExeName, ArgStr)
            %%
            PWD = pwd;
            CommandString = [ExeName,' ', ArgStr];
            cd(Path)
            [Error,String] = obj.Dos_Command(CommandString);
            cd(PWD);
        end
    end
end