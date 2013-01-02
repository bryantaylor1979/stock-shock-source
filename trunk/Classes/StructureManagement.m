classdef StructureManagement < handle
    properties
    end
    methods
        function [Dat] = GetField(obj,struct,field)
            %%
            Dat = squeeze(struct2cell(struct));
            n = find(strcmpi(fieldnames(struct),field));
            Dat = rot90(Dat(n,:));
        end
        function Table = struct2Table(obj,struct)
            Table = [rot90(fieldnames(struct),3);fliplr(rot90(squeeze(struct2cell(struct))))];
        end
        function [DATASET] = struct2DATASET(obj,struct)
           
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
            disp(['Number Of Tasks for this PC: ',num2str(x)])
        end
    end
end