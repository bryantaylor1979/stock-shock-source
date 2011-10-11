%BB - BuyConf
DateNum = obj.DateNum;

Ticker = obj.GetDownloadSymbols('Data');

FieldNames = {  'BB_HIST_Ticker', ...
                'BB_HIST_Signal', ...
                'BB_CE_Money'};
            
Folder = 'BB_BuyConf_WithMoney';

% DateNum = obj.DateNum;
[DATASET1] = obj.Quote(Ticker,FieldNames,DateNum);

% Filtering
DATASET = obj.ColumnStr(DATASET1,'BB_HIST_Signal',{'BUY CONF'});
DATASET = sortrows(DATASET,'BB_CE_Money','descend');

% Save Data
save([obj.InstallDir,'Results\',Folder,'\DataSet\',datestr(DateNum,1)],'DATASET');
% obj.DataSet2xls(DATASET,[obj.InstallDir,'Results\',Folder,'\xls\',datestr(DateNum,1),'.xls']);