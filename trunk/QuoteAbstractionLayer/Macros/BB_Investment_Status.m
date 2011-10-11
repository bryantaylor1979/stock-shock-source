%BB - BuyConf
DateNum = obj.DateNum;
DateNum = today
Ticker = strrep(obj.LoadInvestedSymbols('InvestedSymbolList.txt'),'.L','')

FieldNames = {  'BB_STATUS_Ticker', ...
                'BB_STATUS_Description', ...
                'BB_STATUS_Close', ...
                'BB_STATUS_Signal'};
            
Folder = 'BB_Investment_Status';

% DateNum = obj.DateNum;
[DATASET] = obj.Quote(Ticker,FieldNames,DateNum)

%% Filtering
DATASET = obj.RemovePreFix2ColumnNames('BB_STATUS_',DATASET)

%% Save Data
save([obj.InstallDir,'Results\',Folder,'\DataSet\',datestr(DateNum,1)],'DATASET');
obj.DataSet2xls(DATASET,[obj.InstallDir,'Results\',Folder,'\xls\',datestr(DateNum,1),'.xls']);
obj.DataSet2csv(DATASET,[obj.InstallDir,'Results\',Folder,'\invested.csv']);