classdef PGin_FT_Anal < handle & ...
                        DataSetFiltering
    properties
    end
    methods
        function [DATASET2] = Add_Signal(obj,DATASET)
            %%
            Latest_Buy = obj.GetColumn(DATASET,'Latest_Buy');
            Latest_Outperform = obj.GetColumn(DATASET,'Latest_Outperform');
            Latest_Hold = obj.GetColumn(DATASET,'Latest_Hold');
            Latest_Underperform = obj.GetColumn(DATASET,'Latest_Underperform');
            Latest_Sell = obj.GetColumn(DATASET,'Latest_Sell');
            
            Buy_Wgt = 5;
            Outperform_Wgt = 4;
            Hold_Wgt = 3;
            Underperform = 2;
            Sell = 1;
            
            x = size(MaxValues,2);
            for i = 1:x
                % Total With an Opinion
                TotalWithAnOpinion(i,1) = Latest_Buy(i) + Latest_Outperform(i) + Latest_Hold(i) + Latest_Underperform(i) + Latest_Sell(i);
                
                Score(i,1) = round((Latest_Buy(i)*Buy_Wgt + Latest_Outperform(i)*Outperform_Wgt + Latest_Hold(i)*Hold_Wgt + Latest_Underperform(i)*Underperform + Latest_Sell(i)*Sell)/TotalWithAnOpinion(i));
                
                switch Score(i,1)
                    case 5
                        Signal{i,1} = 'Buy';
                    case 4
                        Signal{i,1} = 'Outperform';
                    case 3
                        Signal{i,1} = 'Hold';
                    case 2
                        Signal{i,1} = 'Underperform';
                    case 1
                        Signal{i,1} = 'Sell';
                    otherwise
                end
            end
            %
            DATASET2 = [DATASET,dataset(TotalWithAnOpinion,Score,Signal)];
        end
        function [DATASET3] = Add_Targets(obj,DATASET2)
           %%
           AnalysisView = obj.GetColumn(DATASET2,'AnalysisView');
           for i = 1:max(size(AnalysisView)) 
               AV = AnalysisView{i};
               
               try
               %median target
               n = findstr('median target of',AV);
               MT = AV(n+16:end);
               n = findstr(MT,',');
               MedianTarget(i,1) = str2double(MT(1:n-1));
               end
               
               try
               %low estimate
               n = findstr('low estimate of',AV);
               LT = AV(n+15:end);
               n = findstr(LT,'. ');
               LowEstimate(i,1) = str2double(LT(1:n-1));
               end
               
               try
               %high estimate
               n = findstr('high estimate of',AV);
               HT = AV(n+16:end)
               n = findstr(HT,'and');
               HighEstimate(i,1) = str2double(HT(1:n-1)); 
               end
               
               try
               %last price
               n = findstr('last price of ',AV);
               LP = AV(n+14:end-1);
               LastPrice(i,1) = str2double(LP);
               end
               
               try
               n = findstr('represents a',AV);
               INC = AV(n+12:end);
               n = findstr(INC,'increase');
               INC = INC(1:n-1);
               INC = strrep(INC,' ','');
               INC = strrep(INC,'%','');
               EstimatedIncrease(i,1) = str2double(INC)/100;
               end
           end
           DATASET3 = [DATASET2,dataset(MedianTarget,LowEstimate,HighEstimate,LastPrice,EstimatedIncrease)];
        end
    end
end