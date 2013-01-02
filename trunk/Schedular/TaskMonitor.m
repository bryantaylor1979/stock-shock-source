classdef TaskMonitor <  handle & ...
                        DataSetFiltering
    properties
    end
    methods
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
                try
                    AgentName = obj.GetColumn(Entry,'AgentName');
                    programName = ['URL_Download_',AgentName{1}];
                    obj.KillProgram(programName);
                catch
                    disp('Agent Name Not logged')   
                end
            end
        end
    end
end