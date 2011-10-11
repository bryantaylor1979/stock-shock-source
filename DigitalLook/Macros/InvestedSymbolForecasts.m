%%
Symbols = strrep(obj.LoadInvestedSymbols('InvestedSymbolList.txt'),'.L','')
Symbols = strrep(Symbols,'_','')
DATASET = obj.DownloadAll(Symbols);

%%
MacroName = 'InvestedSymbolForecasts';
save([obj.InstallDir,'\Results\',MacroName,'\DataSet\',datestr(now,1),'.mat'],'DataSet')
%%
obj.DataSet2xls(DATASET,[obj.InstallDir,'Results\',MacroName,'\xls\',datestr(now,1),'.xls']);
obj.DataSet2csv(DATASET,[obj.InstallDir,'Results\',MacroName,'\forecasts.csv']);