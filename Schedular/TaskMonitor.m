classdef TaskMonitor <  handle & ...
                        DataSetFiltering
    properties
    end
    methods
        function [DATASET] = GetPcsTasks(obj,Name)
            %%
            Macros = obj.LoadPlanner('Planner');
            date = today;
            date = obj.GetStoreDate(date);  
            disp(['ComputerName: ',Name])
            Macros = obj.FilterPCTaskOnly(Macros,Name);
            if isempty(Macros), error('No tasks for this computer'), end %Check that task are required for this PC.
            struct = obj.GetStatusStruct(Macros,date,Name); %Load if file exist, create if not found and save.
            
            %%
            ProgramNames = fieldnames(struct);
            x = size(ProgramNames,1);
            count = 1;
            for i = 1:x
                ProgramName = ProgramNames{i};
                ResultNames = fieldnames(struct.(ProgramName));
                y = size(ResultNames,1);
                for j = 1:y
                    Program{count,1} = ProgramName;
                    Result{count,1} = ResultNames{j};
                    AgentName{count,1} = struct.(ProgramName).(ResultNames{j}).AgentName;
                    Started(count,1) = struct.(ProgramName).(ResultNames{j}).Started;
                    Complete(count,1) = struct.(ProgramName).(ResultNames{j}).Complete;
                    temp = struct.(ProgramName).(ResultNames{j}).TimeOfLastPulse;
                    if ischar(temp)
                        temp = NaN;                      
                    end
                    TimeOfLastPulse(count,1) = temp;
                    count = count + 1;
                end
            end
            %%
            DATASET = dataset(Program,Result,Started,Complete,TimeOfLastPulse,AgentName);
            x = size(DATASET,1);
            disp(['Number Of Tasks for ',Name,': ',num2str(x)])
        end
        function [N_DATASET] = AddTimeSinceLastPulse(obj,DATASET)
            %% Time since last update
            TimeOfLastPulse = obj.GetColumn(DATASET,'TimeOfLastPulse');
            TimeSinceLastPulse = now - TimeOfLastPulse;
            
            Str = datestr(TimeOfLastPulse,'HH:MM:SS')
            for i = 1:size(Str,1)
                TimeOfLastPulseStr{i,1} = Str(i,:);
            end
            
            Str = datestr(TimeSinceLastPulse,'HH:MM:SS');
            for i = 1:size(Str,1)
                TimeSinceLastPulseStr{i,1} = Str(i,:);
            end
            
            N_DATASET = [DATASET,dataset(TimeOfLastPulseStr,TimeSinceLastPulse,TimeSinceLastPulseStr)];
        end
        function P_DATASET = FindStale(obj,N_DATASET,StaleThreshold)
            %%
            StaleThresholdNum = rem(datenum(StaleThreshold),1);
            P_DATASET = obj.NumRange(N_DATASET,'TimeSinceLastPulse',[StaleThresholdNum,Inf]);
            NumStale = size(P_DATASET,1);
            disp(['Number Stale: ',num2str(NumStale)])
        end
        function KillStale(obj,P_DATASET)
            NumberOfStale = size(P_DATASET,1);
            for i = 1:NumberOfStale
                Entry = P_DATASET(1,:);
                AgentName = obj.GetColumn(Entry,'AgentName');
                programName = ['URL_Download_',AgentName{1}];
                obj.KillProgram(programName);
            end
        end
    end
end