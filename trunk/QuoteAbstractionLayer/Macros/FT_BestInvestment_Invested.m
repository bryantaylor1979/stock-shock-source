%BB - BuyConf
DateNum = obj.DateNum;
DateNum = today
Ticker = strrep(obj.LoadInvestedSymbols('InvestedSymbolList.txt'),'.L','')

FieldNames = {  'FT_BrokUp_Date', ...
                'FT_BrokUp_Symbol', ... 
                'FT_BrokUp_Recommendation', ...
                'FT_BrokUp_Strength', ...   
                'FT_BrokUp_NoOfBrokers', ...    
            	'FT_BrokUp_MedianTarget', ...    
            	'FT_BrokUp_HighEstimate', ...
                'FT_BrokUp_LowEstimate', ...
                'FT_BrokUp_LastPrice', ...
                'FT_BrokUp_MeianProfit'}  
            
Folder = 'BB_BuyConf';

% DateNum = obj.DateNum;
[DATASET] = obj.Quote(Ticker,FieldNames,DateNum)

%% Filtering
DATASET = obj.RemovePreFix2ColumnNames('BB_STATUS_',DATASET)

%% Save Data
save([obj.InstallDir,'Results\',Folder,'\DataSet\',datestr(DateNum,1)],'DATASET');
% obj.DataSet2xls(DATASET,[obj.InstallDir,'Results\',Folder,'\xls\',datestr(DateNum,1),'.xls']);