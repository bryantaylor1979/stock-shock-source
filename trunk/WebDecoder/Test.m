classdef Test < handle 
    properties
    end
    methods
        function struct = All_TestTrainerDecode(obj,ProgramName,filename)
            %%
            fid = fopen(filename,'wt');
            Names = obj.GetURLnames(ProgramName);
            x = size(Names,1);
            OverallFailed = 0;
            for i = 1:x            
                count = 0;
                fprintf(fid,[Names{i},'\n']);
                fprintf(fid,'================\n');
                struct(i).DataSet = obj.Single_TestTrainerDecode(ProgramName,Names{i});
                y = size(struct(i).DataSet,1);
                for j = 1:y
                    if struct(i).DataSet{j,4} == false
                        if ischar(struct(i).DataSet{j,2})
                            string = [struct(i).DataSet{j,1},',',struct(i).DataSet{j,2},',',struct(i).DataSet{j,3},',FAILED'];
                        else
                            string = [struct(i).DataSet{j,1},',',num2str(struct(i).DataSet{j,2}),',',num2str(struct(i).DataSet{j,3}),',FAILED'];
                        end
                        fprintf(fid,[string,'\n']);
                        count = count + 1;
                    else
                        if ischar(struct(i).DataSet{j,2})
                            string = [struct(i).DataSet{j,1},',',struct(i).DataSet{j,2},',',struct(i).DataSet{j,3},',PASSED'];
                        else
                            string = [struct(i).DataSet{j,1},',',num2str(struct(i).DataSet{j,2}),',',num2str(struct(i).DataSet{j,3}),',PASSED'];
                        end
                        fprintf(fid,[string,'\n']);
                    end
                end
                struct(i).FailedCount = count;
                if count > 0
                    OverallFailed = OverallFailed + 1;
                end
                fprintf(fid,['\n']);
            end
            if OverallFailed == 0
                fprintf(fid,['All tests are successfull\n']);
            else
                fprintf(fid,['Test Failed']);
            end
        end
        function DataSet = Single_TestTrainerDecode(obj,ProgramName,TrainerName1)
            
            s = obj.GetURL(ProgramName,TrainerName1);
            
%             outStruct = obj.ADFVN_DecodeURL(s);
            struct = obj.GetConfig(ProgramName,'Decoder');
            outStruct = obj.DecodeURL(s,struct); 
                        
            TrainerName = 'Trainer';
            struct = obj.GetConfig(ProgramName,TrainerName);
            
            x = size(outStruct,2);
            for i = 1:x
                %
                Names{i,1} = outStruct(i).Name;
                
                Val1 = outStruct(i).Val;
                if isempty(Val1)
                    Val{i,1} = NaN;
                else
                    if ischar(Val1)
                        Val{i,1} = Val1;
                    else
                        Val{i,1} = Val1;
                    end
                end

                ExpectedValue1 = struct(i).(TrainerName1).ExpectedValue
                ExpectedValue1 = obj.DecodeVal(ExpectedValue1,outStruct(i).Class);
                if isempty(ExpectedValue1)
                    ExpectedValue{i,1} = NaN;
                else
                    if ischar(Val1)
                        ExpectedValue{i,1} = ExpectedValue1;
                    else
                        ExpectedValue{i,1} = ExpectedValue1;
                    end
                end
                disp(Names{i})
                
                if not(ischar(Val1))
                    if Val1 == ExpectedValue1
                        Pass(i,1) = true;
                    else
                        if and(isnan(ExpectedValue{i,1}),isnan(Val{i,1}))
                        Pass(i,1) = true;    
                        else
                        Pass(i,1) = false;
                        end
                    end
                else
                    if strcmpi(Val1, ExpectedValue1)
                        Pass(i,1) = true;
                    else
                        Pass(i,1) = false;
                    end                    
                end
            end
            disp(' ')
            DataSet = dataset(Names,Val,ExpectedValue,Pass);
        end
    end
end