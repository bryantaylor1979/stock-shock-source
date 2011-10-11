%% 
DataSet = obj.LoadLastResult('Yahoo','BB_BuyIF_Spread');
Symbols = obj.GetColumn(DataSet,'Ticker');

%%
PD_DataSet = obj.LOC_GetPerformanceData(Symbols);

%%
PD_DataSet = obj.Add_MarketCapNum(PD_DataSet);
PD_DataSet = obj.Add_MarketCapInDollars(PD_DataSet);
PD_DataSet = obj.Add_MarketCapCategory(PD_DataSet);

%%
DataSet = [DataSet,PD_DataSet];
bn = 1000000000; 

%%
DataSet = obj.NumRange(DataSet,'MarketCapInDollars',[2*bn, Inf]); %Medium Cap And Above
DataSet = obj.ColumnFiltering(DataSet,{ 'Ticker', ...
                                        'Description', ...
                                        'Sector', ...
                                        'Spread', ...
                                        'Profit', ...
                                        'MarketCap', ...
                                        'MarketCapCategory'});
%%
obj.DataSet2csv(DataSet,[obj.InstallDir,'Results\Buy_IF\BuyIfTomorrow.csv']);
obj.DataSet2xls(DataSet,[obj.InstallDir,'Results\Buy_IF\xls\',datestr(today,1),'.xls']);
save([obj.InstallDir,'Results\Buy_IF\DataSet\',datestr(today,1)],'DataSet');

%
% obj.SendFtp([obj.InstallDir,'Results\Buy_IF\BuyIfTomorrow.csv'],'httpdocs/britishbulls/BuyIf_Tommorrow/Stage3/','wfoote.com','shares','cormorant');
                                    