classdef TopSlice < handle
    properties (SetObservable = true)
        % INPUTS
        Sold_CompanyTickerSymbol = 'ATC';
        Sold_NumberOfUnits = 675000;
        Sold_Price = 1528.20;
        Holdings = dataset([]);
        Holdings_OUT = dataset([]);
    end
    methods
        function Example(obj)
            %%
            close all
            clear classes
            obj = TopSlice
            obj.RUN
            ObjectInspector(obj)
        end
        function RUN(obj)
            % bottom entry is the cheapest shares
            NumberOfHoldings = size(obj.Holdings,1);
            [Stake1_Profit,NumberOfSharesSold] = obj.ProfitOnStake(obj.Holdings,NumberOfHoldings,Inf);
            
            % new to now calcualte the profit on the second stake
            NumberOfSharesLeft = obj.Sold_NumberOfUnits - NumberOfSharesSold
            [Stake2_Profit,NumberOfSharesSold] = obj.ProfitOnStake(obj.Holdings,NumberOfHoldings-1,NumberOfSharesLeft);
            
            
            
            Overall_Profit = Stake1_Profit + Stake2_Profit;
            
            % most expensive stake reduction (by price reduction)
            NumberOfShares = obj.GetValue(obj.Holdings,'NumberOfShares',1)
            PriceOfShares = obj.GetValue(obj.Holdings,'PriceOfShares',1)
            NewPrice = PriceOfShares - Overall_Profit/NumberOfShares*100
            
            
            % update holdings
            NumberOfShares = obj.GetValue(obj.Holdings,'NumberOfShares',NumberOfHoldings-1)
            NewNumberOfShares = NumberOfShares-NumberOfSharesLeft;
            
            obj.Holdings_OUT = obj.SetValue(obj.Holdings(1:end-1,:),'NumberOfShares',NumberOfHoldings-1, NewNumberOfShares)
            obj.Holdings_OUT = obj.SetValue(obj.Holdings_OUT,       'priceofshares', 1, NewPrice)
        end
    end
    methods (Hidden = true)
        function obj = TopSlice()
            %               Symbol   Units   Price
            Holdings = {    'ATC',   79763,  1.2537; ...
                            'ATC',  115213,  0.8550; ...
                            'ATC',  136569,  0.7200; ...
                            'ATC',  163299,  0.4835; ...
                            'ATC',  271744,  0.3625; ...
                            'ATC',  618027,  0.1600};
            obj.Holdings = dataset(    {Holdings(:,1),'Symbol'}, ...
                                       {Holdings(:,2),'Units'}, ...
                                       {Holdings(:,3),'Price'});
        end
        function Bought_PricePerShare = Price2Str(obj,PricePerSharePounds)
            if PricePerSharePounds > 1
                Bought_PricePerShare = ['£',num2str(PricePerSharePounds)];
            else
                PricePerSharePence = PricePerSharePounds*100; %cover to pence
                PricePerSharePence = round(PricePerSharePence*100)/100; %round to two decimals
                Bought_PricePerShare = [num2str(PricePerSharePence),'p'];
            end            
        end
        function [Profit,NumberOfSharesSold] = ProfitOnStake(obj,Holdings,StakeNumber,SharesSoldMax)
            NumberOfShares = obj.GetValue(Holdings,'NumberOfShares',StakeNumber);
            PriceOfShares = obj.GetValue(Holdings,'PriceOfShares',StakeNumber);
            if NumberOfShares > SharesSoldMax
                NumberOfShares = SharesSoldMax;
            end
            
            StakeCost = round(NumberOfShares*PriceOfShares/100);
            
            PriceSoldPerShare = obj.Sold_Price/obj.Sold_NumberOfUnits*100;
            PriceSold = round(PriceSoldPerShare*NumberOfShares/100);
            Profit = PriceSold - StakeCost;   
            NumberOfSharesSold = NumberOfShares;
        end
        function Val = GetValue(obj,Holdings,Value,StakeNumber)
            switch lower(Value)
                case 'numberofshares'
                    Val = Holdings{StakeNumber,2};
                case 'priceofshares'
                    Val = Holdings{StakeNumber,3};
                otherwise
            end
        end
        function Holdings = SetValue(obj,Holdings,Value,StakeNumber,Val)
             switch lower(Value)
                case 'numberofshares'
                    Holdings{StakeNumber,2} = Val;
                case 'priceofshares'
                    Holdings{StakeNumber,3} = Val;
                otherwise
            end           
        end
    end
end