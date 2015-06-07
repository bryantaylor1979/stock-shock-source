function DATASET = TT_Profit(DataSet)
    BuyPrice = DataSet.BuyPrice;
    SellPrice = DataSet.SellPrice;

    Profit = SellPrice./BuyPrice;
    DATASET = [DataSet,dataset(Profit)];
end
function Example()
    %% 
    DATASET = getBritishbullsHistory('BARC.L');
    TT_DATASET = TradePlan2TradeTable(DATASET);
    DATASET = TT_NoOfDaysInvested(TT_DATASET);
    
    %%
    Profit_DATASET = TT_Profit(DATASET)
end