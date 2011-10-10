%%
MacroName = 'BB_OpenConf';
obj.BuySellPriceMode = 'Spread';
obj.Duration = '1y';
obj.ConfirmationMode = 'OpenUp';

NoOfInvestments = 6;
IntialInvestment = 6*1500;
TradingCost = 10;
BuyQueryName = 'BB_BuyConf';
SellQueryName = 'BB_SellConf';

TP_DataSet = obj.TradePlan(BuyQueryName,SellQueryName,NoOfInvestments);
TT_DataSet = obj.TradePlan2TradeTable(TP_DataSet);

% Adding:
%   Sell DateNum
%   Buy DateNum
%   Number of days invested, 
%   Number of working days invested. 
TT_DataSet = obj.TT_NoOfDaysInvested(TT_DataSet);
TT_DataSet = obj.TT_Profit(TT_DataSet);

% Trade Plan Analysis with profit column
TP_DataSet = obj.TP_TradeProfit(TP_DataSet,TT_DataSet);
TP_DataSet = obj.TP_Value(TP_DataSet,IntialInvestment,NoOfInvestments,TradingCost);
%
save([obj.InstallDir,'\Results\',MacroName,'\DATASET\TP_DataSet.mat'],'TP_DataSet');
save([obj.InstallDir,'\Results\',MacroName,'\DATASET\TT_DataSet.mat'],'TT_DataSet');

% Also do performace analysis
InvestmentSize = 1000;
Per_TP_DataSet = obj.TradePlan(BuyQueryName,SellQueryName,Inf);
Per_TT_DataSet = obj.TradePlan2TradeTable(Per_TP_DataSet);
Per_TT_DataSet = obj.TT_NoOfDaysInvested(Per_TT_DataSet);
Per_TT_DataSet = obj.TT_Profit(Per_TT_DataSet);

save([obj.InstallDir,'\Results\',MacroName,'\DATASET\Per_TP_DataSet.mat'],'Per_TP_DataSet');
save([obj.InstallDir,'\Results\',MacroName,'\DATASET\Per_TT_DataSet.mat'],'Per_TT_DataSet');

%
Stats = obj.StatsCalc(Per_TT_DataSet,InvestmentSize,TradingCost)
save([obj.InstallDir,'\Results\',MacroName,'\DATASET\Stats.mat'],'Stats');