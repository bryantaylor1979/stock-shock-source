%%
Folder = 'Sync';
Symbols = obj.GetBBSymbolList;
DateNums = obj.GetBrokersViewDateNums();

x = size(DateNums,1);
for i = 1:x
    %
    Date = DateNums(i);
    DATASET = obj.DecodeAll_URL_BrokersView(Symbols,Date);

    %
    save([obj.InstallDir,'Results\',Folder,'\DataSet\',datestr(Date,1)],'DATASET');
    obj.DataSet2xls(DATASET,[obj.InstallDir,'Results\',Folder,'\xls\',datestr(Date,1),'.xls']);
end
obj.DataSet2csv(DATASET,[obj.InstallDir,'Results\',Folder,'\ftbestpick.csv']);
obj.DayBrokersView2SymbolsFiles;