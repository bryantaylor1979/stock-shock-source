%% Multi
ProgramName = 'ADVFN';
TrainerName = 'Error_Trainer';
outStruct = obj.Train_Multi(ProgramName,TrainerName)

%%
outStruct2 = obj.CreateCommonTrainStruct(outStruct);

%% Single
URL_Name = 'TW__02_May_2011';
s = obj.GetURL(ProgramName,URL_Name); 
struct = obj.GetConfig(ProgramName,TrainerName);
outStruct = obj.Train_Single(s,struct,URL_Name)
outStruct.StartString
outStruct.EndString

%% Single
URL_Name = 'HAWK_02_May_2011';
s = obj.GetURL(ProgramName,URL_Name); 
struct = obj.GetConfig(ProgramName,TrainerName);
outStruct = obj.Train_Single(s,struct,URL_Name)
outStruct.StartString
outStruct.EndString

%%
StartString = obj.GetStartString(s,'2')

%%
StartString = obj.GetStartString(s,'9.43')