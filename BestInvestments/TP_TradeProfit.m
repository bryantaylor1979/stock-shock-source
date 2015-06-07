function TP_DATASET = TP_TradeProfit(TT_DataSet,TP_DataSet)
    %% Trade Plan Info Extraction
    TP_DateOfEvent = TP_DataSet.DateNum;
    TP_Symbols = TP_DataSet.Symbol;       
    Action = TP_DataSet.Signal;  
    
    [x] = size(Action,1);
    for i = 1:x
        if or(strcmpi(Action{i},'Sell'),strcmpi(Action{i},'Short'))
            % Find profit  
            Date = TP_DateOfEvent(i);
            Symbol = TP_Symbols{i};

            % Find Trade Table entry
            n = find(strcmpi(TT_DataSet.Symbol,Symbol));
            TT_DataSet_Symbol = TT_DataSet(n,:);
            
            n = find(TT_DataSet.SellDate==Date);
            TT_DataSet_Symbol = TT_DataSet(n,:);  

            ProfitPer(i,1) = TT_DataSet_Symbol.Profit;
        else
            ProfitPer(i,1) = NaN;
        end
    end
    TP_DATASET = [TP_DataSet,dataset(ProfitPer)];
end
function DATASET = TT_Filter(DataSet,Term)
    %Example 1:  Filter on column named 'Symbol' for symbol 'IBM'
    %   DATASET = obj.TT_Filter(DataSet,{'Symbol','IBM'})
    %
    ColumnData = DataSet.(Term{1});
    if ischar(Term{2})
        n = find(strcmpi(ColumnData,Term{2}));
        DATASET = DataSet(n,:);
    end
end
function Example()
    %%
    TP_DATASET = getBritishbullsHistory('BARC.L');
    TT_DATASET = TradePlan2TradeTable(TP_DATASET);
    TT_DATASET = TT_NoOfDaysInvested(TT_DATASET);
    TT_DATASET = TT_Profit(TT_DATASET);
    TP_DATASET = TP_TradeProfit(TT_DATASET,TP_DATASET);
end