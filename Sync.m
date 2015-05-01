%%
[Data] = obj.III_IndexMap;
Symbols = Data(:,2);

%%
Date = today;
DATASET = obj.ProcessALL(Symbols,Date);

%%
Folder = 'Best_Investments';
Path = [obj.InstallDir,'Results\',Folder,'\DataSet\',datestr(Date,1)];
save(Path,'DATASET');
obj.DataSet2xls(DATASET, [obj.InstallDir,'Results\',Folder,'\xls\',datestr(Date,1),'.xls']);
obj.DataSet2csv(DATASET,[obj.InstallDir,'Results\',Folder,'\stoxlinebestpick.csv']);
obj.SendFtp([obj.InstallDir,'Results\',Folder,'\stoxlinebestpick.csv'],'httpdocs/Stox/','wfoote.com','shares','cormorant');