function TP_DATASET = TP_Value(TP_DataSet,IntialInvestment,NoOfInvestments,TradingCost)
    TotalMoneyPot = IntialInvestment;
    Bank = TotalMoneyPot;

    [x] = size(TP_DataSet,1);
    Money_Invested = 0;
    for i = 1:x
        Trade = TP_DataSet(i,:);
        Actions = Trade.Signal;
        Action = Actions{1};
        if strcmpi(Action,'BUY')
            % Calculate Stake
            SingleStake = TotalMoneyPot/NoOfInvestments - TradingCost; %Correct
            Money_Invested = Money_Invested + SingleStake; %Correct
            Bank = Bank - (SingleStake + TradingCost); %Correct
        elseif or(strcmpi(Action,'SELL'),strcmpi(Action,'SHORT'))
            Profit = Trade.ProfitPer;
            TradeSymbol = Trade.Symbol;

            % Find Invested Stake Value
            InvestedStake = TP_DataSet(1:i-1,:);
            Symbols = InvestedStake.Symbol;
            n = find(strcmpi(Symbols,TradeSymbol));
            InvestedStake = Stake(n(end));

            % New Stake
            SingleStake = InvestedStake*Profit - TradingCost;
            Money_Invested = Money_Invested - InvestedStake;
            TotalMoneyPot = TotalMoneyPot - InvestedStake + SingleStake;

            % Bank
            Bank = Bank + SingleStake;
        end
        TotalAssets(i,1) = round(TotalMoneyPot*100)/100;
        MoneyInvested(i,1) = round(Money_Invested*100)/100;
        Stake(i,1) = round(SingleStake*100)/100;
        Cash(i,1) = round(Bank*100)/100;
        TotalProfit(i,1) = TotalAssets(i,1) - IntialInvestment;
    end
    TP_DATASET = [TP_DataSet,dataset(TotalAssets,TotalProfit,MoneyInvested,Stake,Cash)];
end
function Example()
    %%
    TP_DATASET = getBritishbullsHistory('BARC.L');
    TT_DATASET = TradePlan2TradeTable(TP_DATASET);
    TT_DATASET = TT_NoOfDaysInvested(TT_DATASET);
    TT_DATASET = TT_Profit(TT_DATASET);
    TP_DATASET = TP_TradeProfit(TT_DATASET,TP_DATASET);
    
    NoOfInvestments = 6;
    IntialInvestment = 6*1500;
    TradingCost = 10;
    TP_DATASET = TP_Value(TP_DATASET,IntialInvestment,NoOfInvestments,TradingCost)
end