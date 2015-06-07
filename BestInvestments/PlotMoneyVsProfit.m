function h = PlotMoneyVsProfit(TP_DATASET,BinSize)
    DATASET2 = HistogramProfits(TP_DATASET,'ProfitPer',BinSize)
    NumberOfTradesInBin = DATASET2.NumberOfTradesInBin;
    Profit = DATASET2.ProfitAv;
    BB_CE_Money = DATASET2.MoneyMid;

    h = figure;
    bar(BB_CE_Money,Profit)
    ax1 = gca;
    xlabel('Money')
    ylabel('Profit')
    hold on

    ax2 = axes( 'Position',get(ax1,'Position'),...
                'XAxisLocation','top',...
                'YAxisLocation','right',...
                'Color','none',...
                'XTick', [], ...
                'XColor','k', ...
                'YColor','r');

    hl2 = line(BB_CE_Money,NumberOfTradesInBin,'Color','r','Parent',ax2);
    ylabel('NumberOfTradesInBin')
    title('MONEY vs PROFIT')
    set(gcf,'Name','MONEY vs PROFIT','NumberTitle','off')            
end
function Example(obj)
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
    
    
    %%
    BinSize = 0.01;
    h = PlotMoneyVsProfit(TP_DATASET,BinSize)
end

function DATASET = HistogramProfits(TT_DataSet2,MoneyName,BinSize)
   
    h = waitbar(0);      
    
    Profit = TT_DataSet2.(MoneyName)
    n = find(not(isnan(Profit)))
    Profit = Profit(n)
    MaxMinumum = max(Profit)
    MinMinumum = min(Profit)
    NumberOfBins =  ceil((MaxMinumum-MinMinumum)/BinSize)

    %%
    count = 1;
    for i = 1:NumberOfBins;
        waitbar(i/NumberOfBins,h);

        MinValue = MinMinumum + (i-1)*BinSize;
        MaxValue = MinMinumum + (i)*BinSize;
        disp(['Range: [',num2str(MinValue),',',num2str(MaxValue),']'])

        MoneyLow(count,1) = MinValue;
        MoneyHigh(count,1) = MaxValue;
        
        n = find(Profit>=MinValue)
        Profit_Filtered = Profit(n)
        n = find(Profit_Filtered<=MaxValue)
        Profit_Filtered = Profit_Filtered(n)


        ProfitOut = CalcAverageProfit(Profit_Filtered);
        
        if isempty(ProfitOut.Max)
            ProfitOut.Max = NaN;
        end
        if isempty(ProfitOut.Min)
            ProfitOut.Min = NaN;
        end
        
        ProfitAv(count,1) = ProfitOut.Av;
        ProfitMax(count,1) = ProfitOut.Max;
        ProfitMin(count,1) = ProfitOut.Min;
        ProbabiltyOfProfit(count,1) = ProfitOut.ProbabiltyOfProfit;
        


        MoneyMid(count,1) = (MinValue+MaxValue)/2;
        NumberOfTradesInBin(count,1) = size(Profit_Filtered,1);

        try
        AbsError = Accuracy(Profit_Filtered,ProfitOut.Av,'Money');
        catch
        AbsError = NaN; 
        end
        Accuracy(count,1) = mean(AbsError);

        count = count +1;
    end       
    %%
    ProfitAv = ProfitAv-1;
    ProfitMax = ProfitMax-1;
    ProfitMin = ProfitMin-1;

    DATASET = dataset(MoneyLow,MoneyMid,MoneyHigh,ProfitAv,ProfitMax,ProfitMin,ProbabiltyOfProfit,NumberOfTradesInBin,Accuracy);
end
function ProfitOut = CalcAverageProfit(Profit)

    %Remove Inf
    n = find(not(Profit > 10));
    Profit = Profit(n); 

    %Remove Zero
    n = find(not(Profit == 0));
    Profit = Profit(n); 

    %Remove NaN
    n = find(not(isnan(Profit)));
    Profit = Profit(n);   

    ProfitOut.Av = mean(Profit);
    ProfitOut.Max = max(Profit);
    ProfitOut.Min = min(Profit);

    Num = size(Profit,1);
    DeNum = size(find(Profit>1),1);
    ProfitOut.ProbabiltyOfProfit = DeNum/Num;
end
function AbsError = Accuracy(Profit,MeanProfit,MoneyName)
    %%
    x = size(Profit,1);
    for i = 1:x
       % MeanProfit = 0.98, Profit 1.2
       % Acc = abs(1 - Profit/MeanProfit)
       AbsError(i,1) = abs(1 - MeanProfit/Profit(i));
    end
end
