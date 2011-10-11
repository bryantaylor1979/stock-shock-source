%%
DATASET = obj.CompareFolders('DigitalLook','Forecasts');  
n = find(strcmpi(obj.GetColumn(DATASET,'URL'),  'true'));
DateNum = obj.GetColumn(DATASET,'DatesNum');
DateNum = DateNum(n);

%%
x = max(size(DateNum));

%%
for i = 1:x
    Symbols = GetSaveURL_Symbols(obj,'DigitalLook','Forecasts',DateNum(i));
    DATASET = Process_ALL_Fundamentals(obj,Symbols,DateNum(i));
    
    MacroName = 'Forecasts';
    save([obj.InstallDir,'\Results\',MacroName,'\DataSet\',datestr(DateNum(i),1),'.mat'],'DATASET')
    obj.DataSet2xls(DATASET,[obj.InstallDir,'Results\',MacroName,'\xls\',datestr(DateNum(i),1),'.xls']);
    obj.DataSet2csv(DATASET,[obj.InstallDir,'Results\',MacroName,'\forecasts.csv']);
    obj.SendFtp([obj.InstallDir,'Results\',MacroName,'\forecasts.csv'],'httpdocs/DL/forecasts/','wfoote.com','shares','cormorant');
end