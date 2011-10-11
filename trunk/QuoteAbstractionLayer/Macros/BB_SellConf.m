%BB - BuyConf
DateNum = obj.DateNum;
Ticker = obj.LoadBB_AllStatusList(DateNum);
FieldNames = {  'BB_HIST_Ticker', ...
                'BB_HIST_Signal'};
            
Folder = 'BB_SellConf';

% DateNum = obj.DateNum;
[DATASET] = obj.Quote(Ticker,FieldNames,DateNum);

%% Filtering
DATASET = obj.ColumnStr(DATASET,'BB_HIST_Signal',{'SELL CONF'});

%% Save Data
save([obj.InstallDir,'Results\',Folder,'\DataSet\',datestr(DateNum,1)],'DATASET');
% obj.DataSet2xls(DATASET,[obj.InstallDir,'Results\',Folder,'\xls\',datestr(DateNum,1),'.xls']);