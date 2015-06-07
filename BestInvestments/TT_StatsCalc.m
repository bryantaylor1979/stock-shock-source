function Stats = TT_StatsCalc(TT_DataSet,InvestmentSize,TradingCost)
    x = size(TT_DataSet,1);
    NoOfWorkingDaysInvested = TT_DataSet.NoOfWorkingDaysInvested;
    AccumProfit = 1
    AccumNoOfDays = 0
    for i = 1:x
        Trade = TT_DataSet(i,:);
        Profit = Trade.Profit;

        MoneyAfterTrade = (InvestmentSize-TradingCost)*Profit-TradingCost;
        ProfitAfterCommission(i) = MoneyAfterTrade/InvestmentSize;
        if ProfitAfterCommission(i) <= 0 
            % If you profit went down to less than you trading
            % cost. The trade cost would neve happen. You would
            % just loose the stake. 
            ProfitAfterCommission(i) = 0;
        end
        AccumProfit = AccumProfit*ProfitAfterCommission(i);
        AccumNoOfDays = AccumNoOfDays + NoOfWorkingDaysInvested(i);
    end

    %%
    n = find(isnan(ProfitAfterCommission)==0);
    ProfitAfterCommission = ProfitAfterCommission(n);
    if not(size(n,2) == x)
       warning('Some profit sum work out to be NaN') 
    end
    n = find(not(ProfitAfterCommission==Inf));
    if not(size(n,2) == size(ProfitAfterCommission,2))
       warning('Some profit sum work out to be Inf') 
    end
    ProfitAfterCommission = ProfitAfterCommission(n);

    Stats.AverageProfit = mean(ProfitAfterCommission);
    Stats.MaxProfit = max(ProfitAfterCommission);
    Stats.MinProfit = min(ProfitAfterCommission);
    
    Stats.RangeNoWorkingDaysInvested = [min(NoOfWorkingDaysInvested),max(NoOfWorkingDaysInvested)]
    Stats.AverageNoOfWorkingDaysInvested = mean(NoOfWorkingDaysInvested);
    Stats.NumberOfTrades = x;

    n = find(ProfitAfterCommission > 1 == true);
    Number = size(n,2);
    Stats.ProbablityOfProfit = Number/x;
    Stats.AccumProfit = AccumProfit;
    Stats.TotalNumberOfDaysInvested = AccumNoOfDays;
    
    AccumNoOfDays = (AccumNoOfDays/5*7)
    Stats.APR = (AccumProfit-1)*365/AccumNoOfDays*100;
end
function Example()
    %%
    TP_DATASET = getBritishbullsHistory('BARC.L');
    TT_DATASET = TradePlan2TradeTable(TP_DATASET);
    TT_DATASET = TT_NoOfDaysInvested(TT_DATASET);
    TT_DATASET = TT_Profit(TT_DATASET);
    
    %%
    InvestmentSize = 3000;
    TradingCost = 10;
    Stats = StatsCalc(TT_DATASET, InvestmentSize, TradingCost)
end