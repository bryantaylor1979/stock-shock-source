classdef BestInvestments <  handle & ...
                            ResultsLog & ...
                            DataSetFiltering & ... 
                            MacroRun & ... 
                            BI_Validation
    %0.02   - British Bulls performance analysis
    properties
        InstallDir = 'C:\SourceSafe\Stocks & Shares\Programs\BestInvestments\';
        TradingCost = 10; %pounds
        Rev = 0.02;
        BuySellPriceMode = 'Spread'; % Spread, OpenPrice
        Duration = '1y'; %all, 1y, 3m, 2w
        ConfirmationMode = 'OpenUp'; %OpenUp, None
    end
    methods %British Bulls 
        function [DATASET2, Status] = RemoveUnSupportedSymbols2(obj,DataSet,Date)
            %Remove symbols that you won't beable to get a quote on yahoo
            %from. This is hopefully a quicker version than
            %RemoveUnSupportedSymbols
            AssumptionTime = datenum('23-Dec-2010 08:00:17');
            DATASET = obj.LoadResult('Yahoo','MasterBUYconfQuote',AssumptionTime);
            Symbols = obj.GetColumn(DATASET,'Symbols');
            
            if isempty(DataSet)
                DATASET2 = [];
                Status = -1;
                return                 
            end
            
            %%
            BB_HIST_Ticker = obj.GetColumn(DataSet,'BB_HIST_Ticker');
            x = size(DataSet,1);
            for i = 1:x
                n = find(strcmpi(Symbols,BB_HIST_Ticker{i}));
                if isempty(n)
                    Confirmation{i,1} = 'FALSE';
                else
                    Confirmation{i,1} = 'TRUE';
                end
            end
            n = find(strcmpi(Confirmation,'TRUE'));
            DATASET2 = DataSet(n,:);  
        end
    end
    methods %Confirmation 
        function [DATASET] = RemoveUnConfirmed(obj,DATASET,Date)
            switch lower(obj.ConfirmationMode)
                case 'openup'
                    DATASET = obj.RemoveUnConfirmedOpenUp(DATASET,Date);
                case 'none'
                otherwise
                    error('Confirmation mode not recognised')
            end
        end
        function [DATASET, Status] = RemoveUnConfirmedOpenUp(obj,DataSet,Date)
            %% Confirmation TRUE
            BB_HIST_Ticker = obj.GetColumn(DataSet,'BB_HIST_Ticker');
            BB_HIST_Signal = obj.GetColumn(DataSet,'BB_HIST_Signal');
            x = size(DataSet,1);
            if isempty(DataSet)
                DATASET = [];
                Status = -1;
                return
            end
            for i = 1:x
                try
                    [Price(i,1),PreClose] = obj.GetSymbolQuote(BB_HIST_Ticker{i},Date+1);
                    if (Price(i,1)/PreClose) > 1
                        Confirmation{i,1} = 'TRUE';
                    else
                        Confirmation{i,1} = 'FALSE';
                    end
                catch
                    Confirmation{i,1} = 'FALSE';
                    Price(i,1) = NaN;
                end
                if isnan(Price(i,1))
                    Confirmation{i,1} = 'FALSE';
                    Price(i,1) = NaN;
                end
            end
            n = find(strcmpi(Confirmation,'TRUE'));
            DATASET = dataset(BB_HIST_Ticker,BB_HIST_Signal,Confirmation,Price);
            DATASET = DATASET(n,:);
        end
    end
    methods %British Bulls - Add Columns
        function DATASET = NoInvested(obj,DataSet)
            Action = obj.GetColumn(DataSet,'Action');
            [x] = size(Action,1);
            NoInvested = 0;
            for i = 1:x
                switch lower(Action{i})
                    case 'buy'
                        NoInvested = NoInvested + 1;
                    case 'sell'
                        NoInvested = NoInvested - 1;
                    otherwise
                        
                end
                NumberInvested(i,1) = NoInvested;
            end
            DATASET = [DataSet,dataset(NumberInvested)];
        end
        function Symbols = LimitBuys(obj,Symbols,Number)
            [x] = max(size(Symbols,1));
            if x>Number
                Symbols = Symbols(1:Number);
            else
                Symbols = Symbols;    
            end            
        end
        function DataSet = GetSellPrice(obj,DataSet)
            %%
            x = size(DataSet,1);
            DateNum = obj.GetColumn(DataSet,'DateNum');
            Signal = obj.GetColumn(DataSet,'Signal');
            BB_Ticker = obj.GetColumn(DataSet,'BB_Ticker');
            for i = 1:x
                [P,PreClose] = obj.GetSymbolQuote(BB_Ticker{i},DateNum(i)+1);
                try
                Price(i,1) = P;
                catch
                   x = 1; 
                end
                DateNum(i,1) = DateNum(i,1)+1;
                DateStr{i,1} = datestr(DateNum(i,1));
            end
            DataSet = dataset(DateStr,BB_Ticker,Signal,Price);
        end
        function DataSet = GetPriceWithSpread(obj,DataSet,Mode)
            %% Mode is Ask or Bid.
            x = size(DataSet,1);
            DateNum = obj.GetColumn(DataSet,'DateNum');
            Signal = obj.GetColumn(DataSet,'Signal');
            BB_Ticker = obj.GetColumn(DataSet,'BB_Ticker');
            count = 1;
            for i = 1:x
                disp(['Ticker: ',BB_Ticker{i}])
                [Ask,Bid] = obj.GetSpread(BB_Ticker{i},DateNum(i)+1);
                if not(isnan(Ask))
                    if strcmpi(Mode,'Ask')
                        P = Ask;
                    elseif strcmpi(Mode,'Bid')
                        P = Bid;
                    else
                        error('')
                    end
                    Price(count,1) = P;
                    DateNum(count,1) = DateNum(i,1)+1;
                    DateStr{count,1} = datestr(DateNum(i,1));
                    BB_Ticker2{count,1} =  BB_Ticker{i};
                    Signal2{count,1} =  Signal{i};
                    
                    count = count + 1;
                end
            end
            if count == 1
                DataSet =[];
                return
            end
            BB_Ticker = BB_Ticker2;
            Signal = Signal2;

            DataSet = dataset(DateStr,BB_Ticker,Signal,Price);
        end
        function [Ask,Bid] = GetSpread(obj,Symbol,DateNum)
            %% 
            if ischar(Symbol)
                Symbol = {Symbol};
            else
                
            end
            %% 
            DateNums = obj.GetResultDateNums('Yahoo','MasterBUYconfQuote');
            
            %Find the day results
            DateNums2 = floor(DateNums);
            n = find(DateNums2 == DateNum);
            DateNums = DateNums(n);
            
            %find the earliest time. (Open Ask and Bid)
            DateNumWTime = min(DateNums);
             
            DATASET = obj.LoadResult('Yahoo','MasterBUYconfQuote',DateNumWTime);
            if isempty(DATASET)
                %% Ask-Bid Assumption
                disp('Bid/Ask not avaliable for that day, using instantaneous spread assumption')
                AssumptionTime = datenum('23-Dec-2010 08:00:17');
                DATASET = obj.LoadResult('Yahoo','MasterBUYconfQuote',AssumptionTime);
                DATASET = obj.ColumnStr(DATASET,'Symbols',Symbol);
                if isempty(DATASET)
                    Bid = NaN;
                    Ask = NaN;
                else
                Spread = obj.GetColumn(DATASET,'Spread');
                [Open] = obj.GetSymbolQuote(Symbol{1},floor(DateNum));
                % Not +/- spread/2 -> This doesn't work.
                % Better assumption below, but still not quite centered!
                % Good enough i hope. 
                Bid = Open*(1-(Spread/200));
                Ask = Bid*(1 + Spread/100);
                end
            else
                disp(datestr(DateNumWTime))
                DATASET = obj.ColumnStr(DATASET,'Symbols',Symbol);
                Ask = obj.GetColumn(DATASET,'a');
                Bid = obj.GetColumn(DATASET,'b');
            end      
        end
    end
    methods (Hidden = true)
        function Symbols = FindCommonSymbols(obj,Symbols1,Symbols2)
            [x] = size(Symbols1,1);
            Symbols = [];
            for i = 1:x
                n = find(strcmpi(Symbols1{i},Symbols2));
                if isempty(n)
                    
                else
                    Symbols = [Symbols;Symbols1(i)];
                end
            end
        end
    end
end