%%
DATASET = obj.CompareFolders('FinicialTimes','Performance');  
n = find(strcmpi(obj.GetColumn(DATASET,'URL'),  'true'));
DateNum = obj.GetColumn(DATASET,'DatesNum');
DateNum = DateNum(n);
x = max(size(DateNum));

%%
Folder = 'Performance';
Symbols = obj.GetBBSymbolList;

%%
for i = 1:x
    Symbols = obj.GetSaveURL_Symbols('FinicialTimes','Performance',DateNum(i));
    DATASET = obj.LOC_AllPerformanceData(Symbols,DateNum(i));
    DATASET = obj.Add_MarketCapNum(DATASET);
    DATASET = obj.Add_MarketCapInDollars(DATASET);
    DATASET = obj.Add_MarketCapCategory(DATASET);
    save([obj.InstallDir,'Results\',Folder,'\DataSet\',datestr(DateNum(i),1)],'DATASET');
    obj.DataSet2xls(DATASET,[obj.InstallDir,'Results\',Folder,'\xls\',datestr(DateNum(i),1),'.xls']);
end