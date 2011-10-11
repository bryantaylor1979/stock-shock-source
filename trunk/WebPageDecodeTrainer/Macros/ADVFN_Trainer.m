ProgramName = 'ADVFN';
DecoderName = [obj.SettingsDir,'DecodeTrainers\',ProgramName,'\Decoder.m'];
TrainerLogName = [obj.SettingsDir,'DecodeTrainers\',ProgramName,'\TrainerLog.txt'];
TrainerName = 'Trainer';

%%
outStruct = obj.Train_Multi(ProgramName,TrainerName);

%%
outStruct2 = obj.CreateCommonTrainStruct(outStruct);

%%
obj.WriteTrainingLog(outStruct2,TrainerLogName);

%%
obj.LogStruct(outStruct2,DecoderName);     