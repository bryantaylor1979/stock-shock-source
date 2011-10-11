obj.LoadDistributionList('DistrubtionListMe.txt')
obj.LoadInvestedSymbols('InvestedSymbolList.txt')
obj.InvestedSymbolList = strrep(obj.InvestedSymbolList,'_','.')
DATA = obj.LoadAllData;
DATA = obj.FilterOnInvestmentSymbolsOnly(DATA);
DATA = obj.GetCurrentTargetPrice(DATA);
DATA = obj.CalculateProfit(DATA);
DATA = obj.FilterOffOld(DATA);
Columns = {'Dates','Ticker','BrokerName','Recommendation','BrokersChange','CurrentPriceTarget','Profit'};
DATA = obj.FilterColumns(DATA,Columns);
obj.DataSet2xls(DATA,['C:\SourceSafe\Stocks & Shares\Programs\',obj.ProgramName,'\Results\InvestedSymbols\xls\',datestr(now,1),'.xls']);
