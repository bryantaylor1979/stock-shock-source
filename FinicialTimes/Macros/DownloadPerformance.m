%%
Folder = 'Performance';
Symbols = obj.GetBBSymbolList;
Date = today;

%%
obj.URLSAVEALL_Performance(Symbols,Date);

%%
DATASET = obj.LOC_AllPerformanceData(Symbols,Date);

%
DATASET = obj.Add_MarketCapNum(DATASET);
DATASET = obj.Add_MarketCapInDollars(DATASET);
DATASET = obj.Add_MarketCapCategory(DATASET);

%
save([obj.InstallDir,'Results\',Folder,'\DataSet\',datestr(Date,1)],'DATASET');

%
obj.DataSet2xls(DATASET,[obj.InstallDir,'Results\',Folder,'\xls\',datestr(Date,1),'.xls']);
% obj.SendFtp([obj.InstallDir,'Results\Performance\britishbulls.csv'],'httpdocs/ft/PerformanceData/','wfoote.com','shares','cormorant');