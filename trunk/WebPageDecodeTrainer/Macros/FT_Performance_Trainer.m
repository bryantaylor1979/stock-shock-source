ProgramName = 'FT_Performance';
DecoderName = [obj.InstallDir,'DecodeTrainers\',ProgramName,'\Decoder.m']
TrainerLogName = [obj.InstallDir,'DecodeTrainers\',ProgramName,'\TrainerLog.txt']
TrainerName = 'Trainer';
outStruct = obj.Train_Multi(ProgramName,TrainerName);
outStruct2 = obj.CreateCommonTrainStruct(outStruct);
obj.WriteTrainingLog(outStruct2,TrainerLogName);
obj.LogStruct(outStruct2,DecoderName);     

%% Validation
LogFileName = [obj.InstallDir,'DecodeTrainers\',ProgramName,'\TestLog.csv'];
struct = obj.All_TestTrainerDecode(ProgramName,LogFileName);