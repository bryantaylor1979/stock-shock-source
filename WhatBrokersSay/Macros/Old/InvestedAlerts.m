%%
obj.LoadDistributionList('DistrubtionListMe.txt')
obj.LoadInvestedSymbols('InvestedSymbolList.txt')

%% General Update
DATA = obj.LoadAllData;
DATA = obj.FilterOnInvestmentSymbolsOnly(DATA);
DATA = obj.GetCurrentTargetPrice(DATA);
DATA = obj.CalculateProfit(DATA);
DATA2 = obj.Remove_NoOfDaysOld(DATA,10);

%%
if isempty(DATA2), disp('empty'), else, obj.SendEmail(DATA2,'Invested Symbols Broker Alert');, end

try, Ticker = obj.GetColumn(DATA2(1,:),'Ticker'), end
try, Recommendation = obj.GetColumn(DATA2(1,:),'Recommendation'), end
try, string = [Ticker{1},':',Recommendation{1}], end

%%
if not(isempty(DATA2)), obj.SendSMS('07841689090',string);, end