%obj.LoadDistributionList('DistrubtionListAll.txt')
DATA = obj.LoadAllData;
DATA = obj.GetCurrentTargetPrice(DATA);
DATA = obj.CalculateProfit(DATA);
DATA = obj.Remove_NoOfDaysOld(DATA,14);
DATA = obj.FilterOnProfit(DATA,[1.2,1000000000]);
DATA = sortrows(DATA,'Profit','descend');
obj.DataSet2xls(DATA,['C:\SourceSafe\Stocks & Shares\Programs\',obj.ProgramName,'\Results\WatchList\xls\',datestr(now,1),'.xls']);
obj.DataSet2csv(DATA,['C:\SourceSafe\Stocks & Shares\Programs\',obj.ProgramName,'\Results\WatchList\brokers.csv']);
obj.SendFtp(['C:\SourceSafe\Stocks & Shares\Programs\',obj.ProgramName,'\Results\WatchList\brokers.csv'],'httpdocs/matbrokers','wfoote.com','shares','cormorant');