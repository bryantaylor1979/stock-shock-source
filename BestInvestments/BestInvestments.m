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
        function TRADES2 = TradePlan(obj,BuyQueryName,SellQueryName,NoOfInvestments)
            %%
            Mode = obj.BuySellPriceMode; % Spread, OpenPrice
            [Max,Min] = obj.Query_DateRange(BuyQueryName);
            
            %%
            InvestedSymbols = [];
            SymbolSpread = NoOfInvestments;
            
            %% Work out duration
            End = Max;
            switch obj.Duration
                case 'all'
                    Start = Min;
                case '1y'
                    Start = Max - 365;
                case '3m'
                    Start = Max - (30*4);
                case '2w'
                    Start = Max - (2*7);
                otherwise
            end
                
                
            First = true;
            for i = Start:End
                waitbar((i-Start)/(End-Start));
                Date = i;
                DayOfTheWeek = datestr(Date,'DDD');
                switch DayOfTheWeek
                    case {'Mon','Tue','Wed','Thu','Fri'}
                        %Number of new investments required (NewNo)
                        [NoIn] = size(InvestedSymbols,1);
                        NewNo = SymbolSpread - NoIn;
                        disp(['Date: ',datestr(Date)])
                        disp('=================')
                        disp(['Number Of Currently Invested Symbols: ',num2str(NoIn)])
                        disp(['Day of the week: ',DayOfTheWeek])
                        
                        %Look at SELL symbols
                        if not(isempty(InvestedSymbols))
                             SellSymbols = obj.IsSell(SellQueryName,InvestedSymbols,Date);
                             if not(isempty(SellSymbols))
                                [DATASET] = obj.BuildDataSet(SellSymbols,'SELL',Date);
                                if strcmpi(Mode,'OpenPrice')
                                    DATASET = obj.GetSellPrice(DATASET);
                                elseif strcmpi(Mode,'Spread')
                                    DATASET = obj.GetPriceWithSpread(DATASET,'Bid');
                                else
                                    error('');
                                end
                                if isempty(DATASET)
                                    
                                else
                                TRADES2 = [TRADES2;[DATASET]];
                                InvestedSymbols = obj.RemoveSymbols(InvestedSymbols,SellSymbols);
                                end
                             end
                        end

                        %Look at BUY symbols
                        if not(NewNo == 0)
                            [DATASET, Status]  = obj.GetQueryResults(BuyQueryName,Date);
                            if and(Status == 0,isempty(DATASET)==0); %Data is avaliable
                                disp(['BestBuys Executed:  Success'])
                                DATASET = obj.DataSetRemoveSymbols(DATASET,InvestedSymbols);
                                DATASET = obj.RemoveUnSupportedSymbols2(DATASET,Date);
                                DATASET = obj.RemoveUnConfirmed(DATASET,Date);
                                
                                if not(isempty(DATASET))
                                    BuySymbols = obj.GetColumn(DATASET,'BB_HIST_Ticker');
                                    BuySymbols = obj.RemoveSymbols(BuySymbols,InvestedSymbols);
                                    BuySymbols = obj.LimitBuys(BuySymbols,NewNo);

                                    if not(isempty(BuySymbols))
                                        %Build Table
                                        [DATASET] = obj.BuildDataSet(BuySymbols,'BUY',Date);
                                        if strcmpi(Mode,'OpenPrice')
                                            DATASET = obj.GetSellPrice(DATASET);
                                        elseif strcmpi(Mode,'Spread')
                                            DATASET = obj.GetPriceWithSpread(DATASET,'Ask');
                                        else
                                            error('');
                                        end
                                        
                                        if not(isempty(DATASET))
                                            BuySymbols = obj.GetColumn(DATASET,'BB_Ticker');
                                            InvestedSymbols = [InvestedSymbols;BuySymbols];
                                            %Build Trade List
                                            if First == true
                                                TRADES2 = DATASET;
                                                First = false;
                                            else
                                                try
                                                TRADES2 = [TRADES2;[DATASET]];
                                                catch
                                                   x = 1; 
                                                end
                                            end
                                        end
                                    end
                                end
                            else
                                disp(['BestBuys Executed:  Failed'])
                            end
                        end
                        
                        % Other Info    
                        disp(' ')
                    case {'Sat','Sun'}
                    otherwise
                        disp('Day of week not recognised')
                end
            end
        end
        function [DataSet, Status]  = GetQueryResults(obj,QueryName,Date)
            [DataSet, Status] = obj.LoadResult('QuoteAbstractionLayer',QueryName,Date);
        end
        function [DATASET, Status] = DataSetRemoveSymbols(obj,DATASET,InvestedSymbols)   
            %%
            [x] = size(InvestedSymbols,1);
            if isempty(DATASET)
                DATASET = [];
                Status = -1;
                return                 
            end
            for i = 1:x
                try
                    [Symbols] = obj.GetColumn(DATASET,'BB_HIST_Ticker');
                    n = find(not(strcmpi(InvestedSymbols{i},Symbols)));
                    DATASET = DATASET(n,:);
                catch
                    DATASET = [];
                    Status = -1;
                    return 
                end
            end
            [x] = size(DATASET,1);
            if x == 0
                DATASET = [];
                Status = -1;
                return 
            else
                Status = 0;
                DATASET = DATASET;
            end
        end
        function [DATASET, Status] = RemoveUnSupportedSymbols(obj,DataSet,Date)
            %Remove symbols that you won't beable to get a quote on yahoo
            %from.
            BB_HIST_Ticker = obj.GetColumn(DataSet,'BB_HIST_Ticker');
            BB_HIST_Signal = obj.GetColumn(DataSet,'BB_HIST_Signal');
            x = size(DataSet,1);
            for i = 1:x
                try
                    [Price(i,1),PreClose] = obj.GetSymbolQuote(BB_HIST_Ticker{i},Date+1);
                    Confirmation{i,1} = 'TRUE';
                catch
                    Confirmation{i,1} = 'FALSE';
                end
                if isnan(Price(i,1))
                    Confirmation{i,1} = 'FALSE';
                end
            end
            n = find(strcmpi(Confirmation,'TRUE'));
            DATASET = dataset(BB_HIST_Ticker,BB_HIST_Signal,Confirmation);
            DATASET = DATASET(n,:);         
        end
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
    methods %Trade Plan Analysis
        function TP_DATASET = TP_TradeProfit(obj,TP_DataSet,TT_DataSet)
            %% Trade Plan Info Extraction
            Action = obj.GetColumn(TP_DataSet,'Signal'); 
            TP_DateOfEvent = obj.GetColumn(TP_DataSet,'DateStr');
            TP_Symbols = obj.GetColumn(TP_DataSet,'BB_Ticker');            
            
            [x] = size(Action,1)
            for i = 1:x
                if strcmpi(Action{i},'Sell')
                    % Find profit  
                    Date = TP_DateOfEvent{i};
                    Symbol = TP_Symbols{i};
                    
                    % Find Trade Table entry
                    TT_DataSet_Symbol = obj.TT_Filter(TT_DataSet,{'Symbol',Symbol});
                    TT_DataSet_Symbol = obj.TT_Filter(TT_DataSet_Symbol,{'SellDate',Date});
                    
                    ProfitPer(i,1) = obj.GetColumn(TT_DataSet_Symbol,'Profit');
                else
                    ProfitPer(i,1) = NaN;
                end
            end
            TP_DATASET = [TP_DataSet,dataset(ProfitPer)];
        end
        function TP_DATASET = TP_Value(obj,TP_DataSet,IntialInvestment,NoOfInvestments,TradingCost)
            TotalMoneyPot = IntialInvestment;
            Bank = TotalMoneyPot;
            
            [x] = size(TP_DataSet,1);
            Money_Invested = 0;
            for i = 1:x
                Trade = TP_DataSet(i,:);
                Action = obj.GetColumn(Trade,'Signal');
                Action = Action{1};
                if strcmpi(Action,'BUY')
                    %Calculate Stake
                    SingleStake = TotalMoneyPot/NoOfInvestments - TradingCost; %Correct
                    Money_Invested = Money_Invested + SingleStake; %Correct
                    Bank = Bank - (SingleStake + TradingCost); %Correct
                elseif strcmpi(Action,'SELL')
                    Profit = obj.GetColumn(Trade,'ProfitPer');
                    TradeSymbol = obj.GetColumn(Trade,'BB_Ticker');
                    
                    %Find Invested Stake Value
                    InvestedStake = TP_DataSet(1:i-1,:);
                    Symbols = obj.GetColumn(InvestedStake,'BB_Ticker');
                    n = find(strcmpi(Symbols,TradeSymbol));
                    InvestedStake = Stake(n(end));
                    
                    % New Stake
                    SingleStake = InvestedStake*Profit - TradingCost;
                    Money_Invested = Money_Invested - InvestedStake;
                    TotalMoneyPot = TotalMoneyPot - InvestedStake + SingleStake;
                    
                    %Bank
                    Bank = Bank + SingleStake;
                end
                AverallProfit(i,1) = round(TotalMoneyPot*100)/100;
                MoneyInvested(i,1) = round(Money_Invested*100)/100;
                Stake(i,1) = round(SingleStake*100)/100;
                Banked(i,1) = round(Bank*100)/100;
            end
            TP_DATASET = [TP_DataSet,dataset(AverallProfit,MoneyInvested,Stake,Banked)];
        end
    end
    methods %Trade Table Analysis
        function DATASET = TradePlan2TradeTable(obj,DataSet)
            Action = obj.GetColumn(DataSet,'Signal');
            [x] = size(Action,1);
            Temp = [];
            for i = 1:x
                if strcmpi(Action{i},'SELL')
                    DataSet2 = DataSet(1:i-1,:);
                    %Find last buy trade
                    Symbols = obj.GetColumn(DataSet2,'BB_Ticker');
                    Symbol = obj.GetColumn(DataSet(i,:),'BB_Ticker');
                    n = find(strcmpi(Symbols,Symbol));
                    BUYTRADE = DataSet(n(end),:);
                    SELLTRADE = DataSet(i,:);
                    
                    %Build Info
                    SellDate =   {obj.GetColumn(SELLTRADE,'DateStr'),   'SellDate'};
                    SellPrice =  {obj.GetColumn(SELLTRADE,'Price'),         'SellPrice'};
                    BuyDate =    {obj.GetColumn(BUYTRADE,'DateStr'),    'BuyDate'};
                    BuyPrice =   {obj.GetColumn(BUYTRADE,'Price'),          'BuyPrice'};
                    Symb =       {Symbol,                                   'Symbol'};
                    
                    NewRow = dataset(Symb,BuyDate,BuyPrice,SellDate,SellPrice);
                    
                    %Build DataSet
                    if isempty(Temp)
                        DATASET = NewRow;
                        Temp = 1;
                    else
                        DATASET = [DATASET;NewRow];
                    end
                end
            end
        end
        function DATASET = TT_NoOfDaysInvested(obj,DataSet)
            %Input MUST be a trade table format
            BuyDateNum = datenum(obj.GetColumn(DataSet,'BuyDate'));
            SellDateNum = datenum(obj.GetColumn(DataSet,'SellDate'));
            
            NoOfDaysInvested = SellDateNum - BuyDateNum;
            
            [x] = size(NoOfDaysInvested,1);
            for i = 1:x
                NoOfWorkingDaysInvested(i,1) = obj.NoOfWorkingDaysBetweenDates(BuyDateNum(i),SellDateNum(i));
            end
            
            %Build Ouput DATASET
            DATASET = [DataSet,dataset(BuyDateNum,SellDateNum,NoOfDaysInvested,NoOfWorkingDaysInvested)];
        end
        function DATASET = TT_Profit(obj,DataSet)
            BuyPrice = datenum(obj.GetColumn(DataSet,'BuyPrice'));
            SellPrice = datenum(obj.GetColumn(DataSet,'SellPrice'));
            
            Profit = SellPrice./BuyPrice;
            DATASET = [DataSet,dataset(Profit)];
        end
        function DATASET = TT_Filter(obj,DataSet,Term)
            %Example 1:  Filter on column named 'Symbol' for symbol 'IBM'
            %   DATASET = obj.TT_Filter(DataSet,{'Symbol','IBM'})
            %
            ColumnData = obj.GetColumn(DataSet,Term{1});
            if ischar(Term{2})
                n = find(strcmpi(ColumnData,Term{2}));
                DATASET = DataSet(n,:);
            end
        end
        function Stats = StatsCalc(obj,TT_DataSet,InvestmentSize,TradingCost)
            x = size(TT_DataSet,1);
            NoOfWorkingDaysInvested = obj.GetColumn(TT_DataSet,'NoOfWorkingDaysInvested');
            for i = 1:x
                Trade = TT_DataSet(i,:);
                Profit = obj.GetColumn(Trade,'Profit');
                
                MoneyAfterTrade = (InvestmentSize-TradingCost)*Profit-TradingCost;
                ProfitAfterCommission(i) = MoneyAfterTrade/InvestmentSize;
                if ProfitAfterCommission(i) <= 0 
                    % If you profit went down to less than you trading
                    % cost. The trade cost would neve happen. You would
                    % just loose the stake. 
                    ProfitAfterCommission(i) = 0;
                end
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
            Stats.AverageNoOfWorkingDaysInvested = mean(NoOfWorkingDaysInvested);
            Stats.NumberOfTrades = x;
            
            n = find(ProfitAfterCommission > 1 == true);
            Number = size(n,2);
            Stats.ProbablityOfProfit = Number/x;
        end
    end
    methods %Support functions
        function Symbols = RemoveSymbols(obj,Symbols,SellSymbols)
            if isempty(Symbols)
                return
            end
            for i = 1:max(size(SellSymbols))
                n = find(not(strcmpi(Symbols,SellSymbols{i})));
                Symbols = Symbols(n);
            end
        end
        function SellSymbols = IsSell(obj,SellQueryName,InvestedSymbols,Date)      
            DATASET = [];
            [NoIn] = size(InvestedSymbols,1);
            [DataSet, Status] = obj.LoadResult('QuoteAbstractionLayer',SellQueryName,Date);
            Status = [];
            if isempty(DataSet)
                SellSymbols = [];
                return
            end
            Symbols = obj.GetColumn(DataSet,'BB_HIST_Ticker');
       
            for i = 1:NoIn
                if isempty(find(strcmpi(Symbols,InvestedSymbols(i))))
                else
                    Status = [Status,i];
                end
            end   
            if isempty(Status)
                SellSymbols = [];
            else
                SellSymbols = InvestedSymbols(Status);
            end
        end
        function [DATASET] = BuildDataSet(obj,Symbols,Signal_,Date)
            for i = 1:max(size(Symbols))
                Signal{i,1} = Signal_;
                DateNum(i,1) = Date;
                DateStr{i,1} = datestr(Date);
            end
            BB_Ticker = Symbols;
            DATASET = dataset(DateStr,BB_Ticker,Signal,DateNum);  
        end
    end
    methods (Hidden = true)
        function [Open,PreClose] = GetSymbolQuote(obj,Symbol,Date)
           startdate = Date;
           enddate = Date-10;
           timeout = 2;
           time = 1;
            
           while time < timeout
               try
                   [    date, ...
                        close, ...
                        open, ...
                        low, ...
                        high, ...
                        volume, ...
                        closeadj] = ...
                        sqq([Symbol,'.L'],startdate,enddate,'d');
                    break
               catch
                   disp(['Pause for ',num2str(time),' seconds'])
                   pause(time)
                   time = time*2; 
               end
           end
           if time >= timeout
               Open = NaN;
               PreClose = NaN;
               return
           end
            
           if not(max(date) == Date)
              disp('Warning the data is not on quoted date') 
           end
           n = find(date==Date);
           if 1 == max(size(date))
                Open = NaN;
                PreClose = NaN; 
                return
           end
           if not(isempty(n))
                Open = open(n);
                PreClose = close(n-1);
           else
                Open = NaN;
                PreClose = NaN;               
           end
        end
        function [DayNum2] = DayNum(obj,DayNum);
            if isnumeric(DayNum)
                DayNum = datestr(DayNum,'ddd');
            end
            [x] = size(DayNum,1);
            for i = 1:x
                switch lower(DayNum(i,:))
                    case 'mon'
                        DayNum2 = 1;
                    case 'tue'
                        DayNum2 = 2;
                    case 'wed'
                        DayNum2 = 3;
                    case 'thu'
                        DayNum2 = 4;
                    case 'fri'
                        DayNum2 = 5;
                    case 'sat'
                        DayNum2 = 6;
                    case 'sun'
                        DayNum2 = 7;
                end
            end
        end
        function [Symbols] = Combine3symbolSet(obj,Symbols1,Symbols2,Symbols3)
            Symbols4 = obj.Combine2symbolSet(Symbols1,Symbols2);
            Symbols = obj.Combine2symbolSet(Symbols4,Symbols3);
        end
        function Symbols = Combine2symbolSet(obj,Symbols1,Symbols2)
            RemoveSymbols = obj.FindCommonSymbols(Symbols1,Symbols2)
            Symbols1_Removed = obj.RemoveSymbols(Symbols1,RemoveSymbols);
            Symbols = [Symbols1_Removed;Symbols2];
        end
        function Symbols = FormatSymbols(obj,Symbols)
            Symbols = strrep(Symbols,'.L','');
        end
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
        function [NoOfWorkingDays] = NoOfWorkingDaysBetweenDates(obj,Start,End)
            DayOfTheWeek_Start = datestr(Start,8);
            DayOfTheWeek_End = datestr(End,8);
            
            %Week Diff
            Start_DateNum = obj.DateOfWeekStart(Start);
            End_DateNum = obj.DateOfWeekStart(End);
            WeekDiff = (End_DateNum - Start_DateNum)/7;
            
            DayReSync = obj.DayNum(DayOfTheWeek_End) - obj.DayNum(DayOfTheWeek_Start);
            
            NoOfWorkingDays = 5*WeekDiff + DayReSync;            
        end
        function WeekNumber = WeekNum(obj,DateNum)
            datestr(DateNum,'ddd dd.mm.yyyy');
            
            % First Day Of The Year
            FirstDayOfYear = datenum(datestr(DateNum,'yyyy'),'yyyy');
            
            % Start Of Week One
            Day = datestr(FirstDayOfYear,'ddd');
            if obj.DayNum(Day) == 1
                Num = 0;
            else
                Num = 8 - obj.DayNum(Day);
            end  
            StartOfWeekOne = FirstDayOfYear + Num;
            datestr(StartOfWeekOne,'ddd dd.mm.yyyy');
            
            %Week Number
            WeekNumber = floor((DateNum - StartOfWeekOne)/7);
        end %Not used any more
        function DateNum = DateOfWeekStart(obj,DateNum)
            DateNum2 = obj.DayNum(DateNum);
            DateNum = DateNum - DateNum2+1;
        end
    end
end