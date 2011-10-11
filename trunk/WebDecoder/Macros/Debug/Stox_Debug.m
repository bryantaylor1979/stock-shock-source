%% Multi
ProgramName = 'Stox';
TrainerName = 'Error_Trainer';
outStruct = obj.Train_Multi(ProgramName,TrainerName)

%%
outStruct2 = obj.CreateCommonTrainStruct(outStruct)

%% Single
URL_Name = 'BA_14_June_2011';
s = obj.GetURL(ProgramName,URL_Name); 
struct = obj.GetConfig(ProgramName,TrainerName);
outStruct = obj.Train_Single(s,struct,URL_Name)
outStruct.StartString
outStruct.EndString

%% Single
URL_Name = 'CHG_14_June_2011';
s = obj.GetURL(ProgramName,URL_Name); 
struct = obj.GetConfig(ProgramName,TrainerName);
outStruct = obj.Train_Single(s,struct,URL_Name)
outStruct.StartString
outStruct.EndString

%% Single
URL_Name = 'ZYT_14_June_2011';
s = obj.GetURL(ProgramName,URL_Name); 
struct = obj.GetConfig(ProgramName,TrainerName);
outStruct = obj.Train_Single(s,struct,URL_Name)
outStruct.StartString
outStruct.EndString

%%
StartString = obj.GetStartString(s,'2')

%%
StartString = obj.GetStartString(s,'9.43')