DateNum = obj.DateNum;
Ticker = obj.LoadBB_AllStatusList(today);

FieldNames = {  'BB_Ticker', ...
                'ST_Rating', ...
                'ST_TargetsSixMonths', ...
                'ST_TargetOneYear'};
            
Folder = 'Stox5_Star';

[DATASET] = obj.Quote(Ticker,FieldNames,DateNum);

%% Filtering
[DATASET] = obj.NumRange(DATASET,'ST_Rating',[4,6]);
[DATASET] = obj.RemoveNaN(DATASET,'ST_TargetsSixMonths'); %Remove NaN

%% Save Data
save([obj.InstallDir,'Results\',Folder,'\DataSet\',datestr(DateNum,1)],'DATASET');
obj.DataSet2xls(DATASET,[obj.InstallDir,'Results\',Folder,'\xls\',datestr(DateNum,1),'.xls']);