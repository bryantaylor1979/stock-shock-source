DateNum = obj.DateNum;
Ticker = obj.LoadBB_AllStatusList(today);
FieldNames = {  'BB_Ticker', ...
                'BB_Signal', ...
                'BB_Profit', ...
                'Y_Spread', ...
                'FT_MarketCapInDollars'};
Folder = 'TradeStrategyRev1';
[DATASET] = obj.Quote(Ticker,FieldNames,DateNum);

%% Filtering
DATASET = obj.ColumnStr(DATASET,'BB_Signal',{'BUY-IF','BUY CONF','HOLD'});
DATASET = obj.NumRange(DATASET,'Y_Spread',[0,1]);
DATASET = sortrows(DATASET,'BB_Profit','descend'); 
bn = 1000000000;
DATASET = obj.NumRange(DATASET,'FT_MarketCapInDollars',[2*bn, Inf]); 

%% Save Data
save([obj.InstallDir,'Results\',Folder,'\DataSet\',datestr(DateNum,1)],'DATASET');
obj.DataSet2xls(DATASET,[obj.InstallDir,'Results\',Folder,'\xls\',datestr(DateNum,1),'.xls']);