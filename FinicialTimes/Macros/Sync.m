%Description:   Download all Finical times brokers views

%%
Folder = 'Sync';
Date = today;

%obj.LoadInvestedSymbols('InvestedSymbolList.txt');
Symbols = obj.GetBBSymbolList;

%%
obj.DownloadAll_URL_BrokersView(Symbols,Date);
%%
Date = today;
DATASET = obj.DecodeAll_URL_BrokersView(Symbols,Date);
DATASET = obj.AddDateStrColumn(DATASET);
DATASET = obj.CalcMedianProfit(DATASET);

%
save([obj.InstallDir,'Results\',Folder,'\DataSet\',datestr(Date,1)],'DATASET');
obj.DataSet2xls(DATASET,[obj.InstallDir,'Results\',Folder,'\xls\',datestr(Date,1),'.xls']);
obj.DataSet2csv(DATASET,[obj.InstallDir,'Results\',Folder,'\ftbestpick.csv']);

obj.DayBrokersView2SymbolFileLoop(Date);