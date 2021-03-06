%%
MacroName = 'Forecasts';
Date = today;
Symbols = obj.GetSymbols;
Symbols = obj.RemoveSymbols(Symbols); %Symbols that have download problems. 
%%
obj.SaveURL_ALL_Fundamentals(Symbols);

%%
Symbols = obj.GetSaveURL_Symbols('DigitalLook',MacroName,Date);
DATASET = obj.Process_ALL_Fundamentals(Symbols,Date);

%%
save([obj.InstallDir,'\Results\',MacroName,'\DataSet\',datestr(Date,1),'.mat'],'DATASET')
obj.DataSet2xls(DATASET,[obj.InstallDir,'Results\',MacroName,'\xls\',datestr(Date,1),'.xls']);
obj.DataSet2csv(DATASET,[obj.InstallDir,'Results\',MacroName,'\forecasts.csv']);
obj.SendFtp([obj.InstallDir,'Results\',MacroName,'\forecasts.csv'],'httpdocs/DL/forecasts/','wfoote.com','shares','cormorant');