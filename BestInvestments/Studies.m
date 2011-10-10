classdef Studies <          ResultsLog & ...
                            DataSetFiltering
    properties
    end
    methods
        function Freq(obj)
            %%
            Threshold = [0.7,0.9];
            TT_DataSet3 = obj.NumRange(TT_DataSet2,'BB_CE_LastProfit',Threshold);
            Number = size(TT_DataSet3,1);
            
            % Date range
            BuyDate = datenum(obj.GetColumn(TT_DataSet2,'BuyDate'));
            SellDate = datenum(obj.GetColumn(TT_DataSet2,'SellDate'));
            NoOfDays = max(SellDate) - min(BuyDate);
            NoOfWeeks = NoOfDays/7;
            
            % Average Profit
            ProfitOut = obj.CalcAverageProfit(TT_DataSet3)
            
            ProfitOut.Av    
            AveragePerWeek = Number/NoOfWeeks
        end
        function MoneyVsProfit(obj)
            %%
            TradeName = 'BB_Basic';
            Property = {'BB_CE_Money', ...
                        'BB_CE_TargetProfit', ...
                        'BB_CE_LastProfit', ...
                        'BB_CE_Last2_TradeProfit', ...
                        'BB_CE_Last3_TradeProfit', ...
                        'BB_CE_Last4_TradeProfit', ...
                        'BB_CE_Last5_TradeProfit', ...
                        'BB_CE_Last6_TradeProfit', ...
                        'BB_CE_Last7_TradeProfit', ...
                        'BB_CE_Last8_TradeProfit', ...
                        'BB_CE_Last9_TradeProfit', ...
                        'BB_CE_Last10_TradeProfit', ...
                        };
            
            TT_DataSet = obj.LoadTradeTable(TradeName);
            TT_DataSet2 = obj.AddPropertyToTradeTable(TT_DataSet,Property);
            save TT_DataSet2

            %%
            MinNumberOfTrades = 50;
            BinSize = 0.01;  
            WeightedAccuracy(1) = obj.HistogramProfitVsMoney(TT_DataSet2, 'BB_CE_TargetProfit',BinSize,MinNumberOfTrades);
     
            
            %%
            MinNumberOfTrades = 50;
            WeightedAccuracy(1) = obj.HistogramProfitVsMoney(TT_DataSet2, 'BB_CE_Money',100,MinNumberOfTrades);
            
            BinSize = 0.04;           
            WeightedAccuracy(2) = obj.HistogramProfitVsMoney(TT_DataSet2,'BB_CE_LastProfit', BinSize, MinNumberOfTrades);
            for i = 2:9
                WeightedAccuracy(i+1) = obj.HistogramProfitVsMoney(TT_DataSet2,['BB_CE_Last',num2str(i),'_TradeProfit'],BinSize,MinNumberOfTrades);               
            end
            
            barh(WeightedAccuracy);
            set(gca,'YTickLabel',Property);
        end
        function WeightedAccuracy = HistogramProfitVsMoney(obj,TT_DataSet2,MoneyName,BinSize,MinNumberOfTrades)
            %%
            DATASET = obj.HistogramProfits(TT_DataSet2,MoneyName,BinSize);
            [DATASET2] = obj.NumRange(DATASET,'NumberOfTradesInBin',[MinNumberOfTrades,Inf]);
            FileName = ['C:\SourceSafe\Stocks & Shares\Programs\BestInvestments\LastProfits\',MoneyName,'LUT.mat'];
            save(FileName,'DATASET2');
            
            %%
            
            h1 = obj.PlotMoneyVsProfit(DATASET2,MoneyName);
            saveas(h1,['C:\SourceSafe\Stocks & Shares\Programs\BestInvestments\LastProfits\',MoneyName,'.jpg'])
            close(h1);
            
            h2 = obj.PlotMoneyVsProfit2(DATASET2,MoneyName);
            saveas(h2,['C:\SourceSafe\Stocks & Shares\Programs\BestInvestments\LastProfits\',MoneyName,'_Extra.jpg'])
            close(h2);
            
            h3 = obj.PlotScatter(TT_DataSet2,MoneyName)
            saveas(h3,['C:\SourceSafe\Stocks & Shares\Programs\BestInvestments\LastProfits\',MoneyName,'_Raw.jpg'])
            close(h3);

            [h4, WeightedAccuracy] = obj.PlotAccuracy(DATASET2,MoneyName)
            saveas(h4,['C:\SourceSafe\Stocks & Shares\Programs\BestInvestments\LastProfits\',MoneyName,'_Acc.jpg'])
            close(h4);
        end
    end
    methods (Hidden = true) % Plots
        function h = PlotMoneyVsProfit(obj,DATASET2,Name)
            NumberOfTradesInBin = obj.GetColumn(DATASET2,'NumberOfTradesInBin');
            Profit = obj.GetColumn(DATASET2,'ProfitAv');
            BB_CE_Money = obj.GetColumn(DATASET2,'MoneyMid');
            
            h = figure;
            bar(BB_CE_Money,Profit)
            ax1 = gca;
            xlabel(Name)
            ylabel('Profit')
            
%             xlim([1,MaxMinumum])
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
%             xlim([1,MaxMinumum])
%             xlim()
            title('MONEY vs PROFIT')
            set(gcf,'Name','MONEY vs PROFIT','NumberTitle','off')            
        end      
        function h = PlotMoneyVsProfit2(obj,DATASET2,Name)
            NumberOfTradesInBin = obj.GetColumn(DATASET2,'NumberOfTradesInBin');
            ProfitAv = obj.GetColumn(DATASET2,'ProfitAv');
            ProfitMax = obj.GetColumn(DATASET2,'ProfitMax');
            ProfitMin = obj.GetColumn(DATASET2,'ProfitMin');
            BB_CE_Money = obj.GetColumn(DATASET2,'MoneyMid');
            
            h = figure;
            subplot(2,1,1)
            x = size(ProfitMin,1)
            for i = 1:x
                hold on
                Y_Val = [ProfitMin(i),ProfitMax(i)];
                X_Val = [BB_CE_Money(i),BB_CE_Money(i)];
                plot(X_Val,Y_Val,'g-+');
            end
            scatter(BB_CE_Money,ProfitAv,'bx');
            
            %%
            
            
            %%
            ax1 = gca;
            
            ylabel('Profit')
            
            
%%             xlim([1,MaxMinumum])
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
%             xlim([1,MaxMinumum])
%             xlim()
            title('MONEY vs PROFIT')
            set(gcf,'Name','MONEY vs PROFIT','NumberTitle','off')  
            
            %%
            subplot(2,1,2)
            ProbabiltyOfProfit = obj.GetColumn(DATASET2,'ProbabiltyOfProfit');
            bar(BB_CE_Money,ProbabiltyOfProfit,'k')
            ylabel('ProbabiltyOfProfit')
            xlabel(Name)
            
            %%
            set(ax1,'Position',[0.1300    0.4378    0.787    0.4922])
            set(ax2,'Position',[0.1300    0.4378    0.787    0.4922])
            set(gca,'Position',[0.1300    0.18    0.787    0.2512])
        end
        function h = PlotScatter(obj,TT_DataSet2,Name)
            %%
            h = figure;
            Var = obj.GetColumn(TT_DataSet2,Name)
            Profit = obj.GetColumn(TT_DataSet2,'Profit')
            scatter(Var,Profit,'x')
            
            % Find axes limits
            XHighLim = 0.99;
            XLowLim = 0.01;
            YHighLim = 0.99;
            YLowLim = 0.01;
            
            
            
            %XHighLim
            Lim_Profit = sort(Profit);
            n = size(Profit,1);
            XHighLimNum = floor(n*XHighLim);
            XHighLimNum = Lim_Profit(XHighLimNum);
            
            %XLowLim
            XLowLimNum = ceil(n*XLowLim);
            XLowLimNum = Lim_Profit(XLowLimNum);
            
            
            
            %YHighLim
            Lim_Profit = sort(Var);
            n = not(isnan(Lim_Profit));
            Lim_Profit = Lim_Profit(n);
            n = size(Lim_Profit,1);
            
            YHighLimNum = floor(n*YHighLim);
            YHighLimNum = Lim_Profit(YHighLimNum)
            
            %YLowLim
            YLowLimNum = ceil(n*YLowLim);
            YLowLimNum = Lim_Profit(YLowLimNum)         
            
            %
            xlim([XLowLimNum,XHighLimNum])
            ylim([YLowLimNum,YHighLimNum])
            
            xlabel(Name)
            ylabel('Profit on trade')
        end
        function [h,WeightedAccuracy] = PlotAccuracy(obj,DATASET2,Name)
            %%
            Accuracy = obj.GetColumn(DATASET2,'Accuracy');
            BB_CE_Money = obj.GetColumn(DATASET2,'MoneyMid');
            NumberOfTradesInBin = obj.GetColumn(DATASET2,'NumberOfTradesInBin');
            
            h = figure;
            plot(BB_CE_Money,Accuracy);
            n = find(not(isnan(Accuracy)));
            
            Accuracy = Accuracy(n);
            NumberOfTradesInBin = NumberOfTradesInBin(n);
            
            TotalAccuracy = mean(Accuracy);
            
            WeightedAccuracy = Accuracy.*NumberOfTradesInBin;
            WeightedAccuracy = sum(WeightedAccuracy)/sum(NumberOfTradesInBin);
            
            %Weighted Accuracy           
            
            title({ ['Total Accuracy: (Low is good): ',num2str(TotalAccuracy)]; ...
                    ['Weighted Accuracy: (Low is good): ',num2str(WeightedAccuracy)]})
                
            ylabel('Abs Accuracy Error')
            xlabel(Name);
        end
    end
    methods (Hidden = true) % Support functions
        function DATASET = HistogramProfits(obj,TT_DataSet2,MoneyName,BinSize)
            h = waitbar(0);      
            MaxMinumum = max(obj.GetColumn(TT_DataSet2,MoneyName));
            MinMinumum = min(obj.GetColumn(TT_DataSet2,MoneyName));
            NumberOfBins =  ceil((MaxMinumum-MinMinumum)/BinSize);
            
            %%
            count = 1;
            for i = 1:NumberOfBins;
                waitbar(i/NumberOfBins,h);
                
                MinValue = MinMinumum + (i-1)*BinSize;
                MaxValue = MinMinumum + (i)*BinSize;
                disp(['Range: [',num2str(MinValue),',',num2str(MaxValue),']'])
                
                MoneyLow(count,1) = MinValue;
                MoneyHigh(count,1) = MaxValue;
                
                [DATASET] = obj.NumRange(TT_DataSet2,MoneyName,[MoneyLow(count),MoneyHigh(count)]);
                
                
                if isempty(DATASET)
                    ProfitAv(count,1) = NaN;
                    ProfitMax(count,1) = NaN;
                    ProfitMin(count,1) = NaN;
                    ProbabiltyOfProfit(count,1) = NaN;

                    MoneyMid(count,1) = NaN;
                    NumberOfTradesInBin(count,1) = 0;
                else
                    ProfitOut = obj.CalcAverageProfit(DATASET);

                    ProfitAv(count,1) = ProfitOut.Av;
                    ProfitMax(count,1) = ProfitOut.Max;
                    ProfitMin(count,1) = ProfitOut.Min;
                    ProbabiltyOfProfit(count,1) = ProfitOut.ProbabiltyOfProfit;

                    MoneyMid(count,1) = (MoneyLow(count)+MoneyHigh(count))/2;
                    NumberOfTradesInBin(count,1) = size(DATASET,1);
                    
                    DATASET = obj.Accuracy(DATASET,ProfitOut.Av,MoneyName);
                    Accuracy(count,1) = mean(obj.GetColumn(DATASET,'AbsError'));

                    count = count +1;
                end
            end       
            %%
            ProfitAv = ProfitAv-1;
            ProfitMax = ProfitMax-1;
            ProfitMin = ProfitMin-1;
            
            DATASET = dataset(MoneyLow,MoneyMid,MoneyHigh,ProfitAv,ProfitMax,ProfitMin,ProbabiltyOfProfit,NumberOfTradesInBin,Accuracy);
        end %Don't think has any meaning. But left for history reasons.
        function HighThreshold = HighThresholdOptimser(obj,TT_DataSet2)
            h = waitbar(0);
            count = 1;
            MaxMinumum = max(obj.GetColumn(TT_DataSet2,'BB_CE_Money'));
            for i = 1:MaxMinumum
                waitbar(count/MaxMinumum,h);
                [DATASET] = obj.NumRange(TT_DataSet2,'BB_CE_Money',[i,MaxMinumum]);
                ProfitAv(count) = obj.CalcAverageProfit(DATASET);
                Threshold(count) = i;
                count = count +1;
            end 
            n = find(max(ProfitAv) == ProfitAv);
            HighThreshold = min(Threshold(n));
        end
        function ProfitOut = CalcAverageProfit(obj,DataSet)
            %
            BB_CE_Money = obj.GetColumn(DataSet,'BB_CE_Money');
            Profit = obj.GetColumn(DataSet,'Profit');
            
            %Remove Inf
            n = find(not(Profit > 10));
            BB_CE_Money = BB_CE_Money(n);
            Profit = Profit(n); 
            
            %Remove Zero
            n = find(not(Profit == 0));
            BB_CE_Money = BB_CE_Money(n);
            Profit = Profit(n); 
            
            %Remove NaN
            n = find(not(isnan(Profit)));
            BB_CE_Money = BB_CE_Money(n);
            Profit = Profit(n);   
            
            ProfitOut.Av = mean(Profit);
            ProfitOut.Max = max(Profit);
            ProfitOut.Min = min(Profit);
            
            Num = size(Profit,1);
            DeNum = size(find(Profit>1),1);
            ProfitOut.ProbabiltyOfProfit = DeNum/Num;
        end
        function Per_TT_DataSet = LoadTradeTable(obj,TradeName)
            load(['A:\Stocks & Shares\Programs\BestInvestments\Results\',TradeName,'\DATASET\Per_TT_DataSet.mat'])            
        end
        function TT_DataSet2 = AddPropertyToTradeTable(obj,Per_TT_DataSet,Properties)
            %%        
            QAL = QuoteAbstractionLayer;
            
            Symbol = obj.GetColumn(Per_TT_DataSet,'Symbol');
            BuyDateNum = datenum(obj.GetColumn(Per_TT_DataSet,'BuyDate'));
            
            h = waitbar(0);
            x = size(Per_TT_DataSet,1);
            for i = 1:x
                waitbar(i/x,h);
                [DATASET] = QAL.Quote(Symbol(i),Properties,BuyDateNum(i));
                [NewDATASET2] = obj.ColumnFiltering(DATASET,Properties);
                if i == 1
                    NewDATASET = NewDATASET2;
                else
                    NewDATASET = [NewDATASET;NewDATASET2];
                end
                drawnow;
            end
            TT_DataSet2 = [Per_TT_DataSet,NewDATASET];
        end
        function DATASET = Accuracy(obj,DATASET,MeanProfit,MoneyName)
            %%
            x = size(DATASET,1);
            Profit = obj.GetColumn(DATASET,MoneyName);
            for i = 1:x
               % MeanProfit = 0.98, Profit 1.2
               % Acc = abs(1 - Profit/MeanProfit)
               AbsError(i,1) = abs(1 - MeanProfit/Profit(i));
            end
            DATASET = [DATASET,dataset(AbsError)];
        end
    end
end