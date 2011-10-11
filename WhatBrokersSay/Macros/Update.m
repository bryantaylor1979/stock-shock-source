date = today;
obj.LoadDistributionList('DistrubtionListMe.txt')
obj.LoadInvestedSymbols('InvestedSymbolList.txt')
[updated,NEWDATA] = obj.Sync(date);

% Invested symbol alerts
[x] = size(NEWDATA,1);
if x > 0, NEWDATA = obj.FilterOnInvestmentSymbolsOnly(NEWDATA);, end
if x > 0, obj.SendEmail(NEWDATA,'Invested Alert');, end

% General Update
DATA = obj.LoadAllData;
DATA = obj.GetCurrentTargetPrice(DATA);
DATA = obj.CalculateProfit(DATA);
if updated == true,  obj.SendEmail(DATA,'Update Alert');, else disp('No email sent'), end

try, Ticker = obj.GetColumn(DATA2(1,:),'Ticker'), end
try, Recommendation = obj.GetColumn(DATA2(1,:),'Recommendation'), end
try, string = [Ticker{1},':',Recommendation{1}], end

%%
if updated == true, obj.SendSMS('07841689090',string);, end