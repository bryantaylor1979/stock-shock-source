classdef QuoteAbstractionLayer <    handle & ...
                                    ResultsLog & ...
                                    DataSetFiltering & ...
                                    MacroRun & ...
                                    InvestedSymbols 
    %Intial Mission is to produce the trade strategy method 1
    properties %Filtering Properties
        InstallDir = 'C:\SourceSafe\Stocks & Shares\Programs\QuoteAbstractionLayer\';
        ProgramName = 'QuoteAbstractionLayer'
        RunOnInt = 'off'
        CloseGUIwhenComplete = 'off'
        DateNum
    end
    methods
        function [DATASET] = Quote(obj,Ticker,FieldNames,DateNum)
            % Quote Fieldnames
            %BRITISH BULLS - All Status
            %==========================
            %    BB_STATUS_Ticker
            %    BB_STATUS_Description
            %    BB_STATUS_Subsector
            %    BB_STATUS_Prev
            %    BB_STATUS_Open
            %    BB_STATUS_High
            %    BB_STATUS_Low
            %    BB_STATUS_Close
            %    BB_STATUS_Change
            %    BB_STATUS_Signal
            %    BB_STATUS_Sector
            %    BB_STATUS_Profit
            %
            %BRITISH BULLS - Current Event
            %=============================
            %    BB_CE_Symbol
            %    BB_CE_Date
            %    BB_CE_CurrentPrice
            %    BB_CE_Signal
            %    BB_CE_ConfSignal
            %    BB_CE_Money
            %
            %Yahoo - Price
            %=============
            %    Y_a         Ask
            %    Y_b         Bid
            %    Y_c1        Change
            %    Y_Spread    Ask/Bid - Spread
            %    Y_c8        AfterHoursChange_RealTime
            %    Y_j         52WeekLow
            %    Y_j5        ChangeFrom52weekLow
            %    Y_k2        ChangePercent_RT
            %    Y_k5        PercentChangeFrom52weekHigh
            %    Y_m         DaysRange
            %    Y_m2        DaysRange_RT
            %    Y_m5        ChangeFrom200DayMovingAverage
            %    Y_m8        PercentChangeFrom50DayMovingAverage
            %    Y_o         Open
            %    Y_p2        ChangeInPercent
            %    Y_b2        Ask_RT
            %    Y_g         DaysLow
            %    Y_k         52WeekHigh
            %    Y_m3        50DayMovingAverage
            %    Y_m6        PercentageChangeFrom200DayMovingAverage
            %    Y_k4        ChangeFrom52weekHigh
            %    Y_l1        LastTrade_PriceOnly
            %    Y_m4        200DayMovingAverage
            %    Y_m7        ChangeFrom50DayMovingAverage
            %    Y_b3        Bid_RT
            %    Y_c         ChangeAndPercentageChange
            %    Y_c6        Change_RT
            %    Y_h         DaysHigh            
            %    Y_w         52weekRange
            %    Y_w1        DaysValueChange
            %    Y_p         PreviousClose
            %    Y_j6        PercentChangeFrom52weekLow
            %    Y_t8        1YrTargetPrice
            %    Y_w4        DayValueChange_RT
            %
            %Yahoo FUNDAMENTALS
            %==================
            %    Y_d        Dividend/Share
            %    Y_e        Earnings/Share
            %    Y_e7       EPS_EstimateCurrentYear
            %    Y_f6       FloatShares
            %    Y_j1       MarketCapitalization
            %    Y_y        Dividend
            %    Y_r1       DividendPayDate
            %    Y_r6       Price/EPS_EstimateCurrentYear
            %    Y_q        ExDividendDate
            %    Y_r2       P/E_Ratio (RT)
            %    Y_r7       Price/EPS_EstimateNextYear
            %    Y_e8       EPS_EstimateNextYear
            %    Y_e9       EPS_EstimateNextQuarter
            %    Y_r        P/E_Ratio
            %    Y_r5       PEG_Ratio
            %    Y_j3       MarketCap_RT
            %
            %Yahoo OTHER
            %===========
            %    Y_l        LastTrade_WithTime
            %    Y_d1       LastTradeDate
            %    Y_k1       LastTrade_RT_WithTime
            %    Y_t1       LastTradeTime
            %    Y_b4       BookValue
            %    Y_d2       TradeDate
            %    Y_g3       AnnualizedGain
            %    Y_g4       HoldingsGain
            %    Y_g6       HoldingsGain_RT
            %    Y_g1       HoldingsGainPercent
            %    Y_g5       HoldingsGainPercent_RT
            %    Y_v7       HoldingsValue_RT
            %    Y_v1       HoldingsValue
            %    Y_l2       HighLimit
            %    Y_l3       LowLimit
            %    Y_s7       ShortRatio
            %    Y_t7       TickerTrend
            %    Y_a2       AverageDailyVolume
            %    Y_v        Volume
            %    Y_c3       Commission
            %    Y_i        MoreInfo
            %    Y_n        Name
            %    Y_p5       Price/Sales
            %    Y_s        Symbol
            %    Y_e1       ErrorIndication    (Returned for symbol changed/invalid)         
            %    Y_i5       OrderBook_RT
            %    Y_j4       EBITDA
            %    Y_n4       Notes
            %    Y_p1       PricePaid
            %    Y_p6       Price/Book
            %    Y_s1       SharesOwned
            %    Y_t6       TradeLinks
            %    Y_x        StockExchange
            %    Y_Spread   Spread
            %
            %FININCAL TIMES Performance
            %=========================
            %    FT_Perf_Open
            %    FT_Perf_AvVolumeStr
            %    FT_Perf_DayLow
            %    FT_Perf_DayHigh
            %    FT_Perf_OfficialClose
            %    FT_Perf_EPS
            %    FT_Perf_DivYield
            %    FT_Perf_DivPS
            %    FT_Perf_DivExDate
            %    FT_Perf_PreviousClose
            %    FT_Perf_SharesOutstanding
            %    FT_Perf_DivPayDate
            %    FT_Perf_NextDivExDate
            %    FT_Perf_NextDivPayDate
            %    FT_Perf_MarketCap
            %    FT_Perf_PE
            %    FT_Perf_FreeFloat
            %    FT_Perf_Currency
            %    FT_Perf_AmountStr
            %    FT_Perf_Exp
            %    FT_Perf_Amount
            %    FT_Perf_AmountNum
            %    FT_Perf_MarketCapInDollars
            %    FT_Perf_MarketCapCategory
            %
            %
            %FININCAL TIMES Brokers View
            %===========================
            %    FT_BrokUp_Date                 
            %    FT_BrokUp_Symbol        
            %    FT_BrokUp_Recommendation
            %    FT_BrokUp_Strength    
            %    FT_BrokUp_NoOfBrokers    
            %    FT_BrokUp_MedianTarget    
            %    FT_BrokUp_HighEstimate
            %    FT_BrokUp_LowEstimate    
            %
            %STOXLINE
            %========
            %    ST_Symbol
            %    ST_TargetsSixMonths
            %    ST_SupportOne
            %    ST_SupportTwo
            %    ST_ResistanceOne
            %    ST_TargetOneYear
            %    ST_ResistanceTwo
            %    ST_PivotPointStart
            %    ST_MA_Five
            %    ST_MA_Twenty
            %    ST_MA_OneHundred
            %    ST_MA_TwoHundredAndFifty
            %    ST_K
            %    ST_D
            %    ST_RSI
            %    ST_High
            %    ST_Low
            %    ST_TenDysVol
            %    ST_Change
            %    ST_ThreeMnthsVol
            %    ST_PriceAndMovingAvText
            %    ST_BollingerBands
            %    ST_Rating
            %    ST_Signal
            %    ST_Stars
            %    ST_DateEval  
            %
            %DIGITAL LOOK Forecasts
            %======================
            %    DL_FC_Symbol
            %    DL_FC_DateStr
            %    DL_FC_YearEnd
            %    DL_FC_Revenue
            %    DL_FC_PreTax
            %    DL_FC_EPS
            %    DL_FC_PE
            %    DL_FC_PEG
            %    DL_FC_EPSGrth
            %    DL_FC_Div
            %    DL_FC_Yield
            %
            %DIGITAL LOOK EPS
            %================
            %    DL_EPS_Symbol        
            %    DL_EPS_PE_Min_1YR              
            %    DL_EPS_PE_Max_1YR
            %    DL_EPS_PE_Min_1YR_M90L10
            %    DL_EPS_PE_Max_1YR_M90L10
            %    DL_EPS_PE_RT
            %    DL_EPS_PE_Star
            %    DL_EPS_Potential
            
            %%
            first = true;       
                        
            n = strmatch('BB_STATUS_',FieldNames);
            BB_FieldNames = FieldNames(n);
            if not(isempty(n))
                [N_DATASET] = obj.BB_STATUS_Quote(Ticker,BB_FieldNames,DateNum);
                if first == true
                    first = false;
                    DATASET = [N_DATASET];   
                else
                    DATASET = [DATASET,N_DATASET];
                end
            end
            
            n = strmatch('BB_HIST_',FieldNames);
            BB_FieldNames = FieldNames(n);
            if not(isempty(n))
                [N_DATASET] = obj.BB_HIST_Quote(Ticker,BB_FieldNames,DateNum);
                if first == true
                    first = false;
                    DATASET = [N_DATASET];   
                else
                    DATASET = [DATASET,N_DATASET];
                end
            end
            
            n = strmatch('BB_CE_',FieldNames);
            BB_FieldNames = FieldNames(n);
            if not(isempty(n))
                if first == true
                    first = false;
                    [N_DATASET] = obj.BB_CE_Quote(Ticker,BB_FieldNames,DateNum);
                    DATASET = [N_DATASET];   
                else
                    Ticker = obj.GetColumn(DATASET,'BB_HIST_Ticker');
                    [N_DATASET] = obj.BB_CE_Quote(Ticker,BB_FieldNames,DateNum);
                    DATASET = [DATASET,N_DATASET];
                end
            end
            
            n = strmatch('Y_',FieldNames);
            Y_FieldNames = FieldNames(n);
            if not(isempty(n))
                [N_DATASET] = obj.Y_Quote(Ticker,Y_FieldNames,DateNum);
                if first == true
                    first = false;
                    DATASET = [N_DATASET];   
                else
                    DATASET = [DATASET,N_DATASET];
                end
            end
            
            %%
            n = strmatch('FT_Perf_',FieldNames);
            FT_FieldNames = FieldNames(n);   
            if not(isempty(n))
                [N_DATASET] = obj.FT_Perf_Quote(Ticker,FT_FieldNames,DateNum);
                if first == true
                    first = false;
                    DATASET = [N_DATASET];   
                else
                    DATASET = [DATASET,N_DATASET];
                end
            end
            
            %%
            n = strmatch('FT_BrokUp_',FieldNames);
            FT_FieldNames = FieldNames(n);   
            if not(isempty(n))
                [N_DATASET] = obj.FT_BrokUp_Quote(Ticker,FT_FieldNames,DateNum);
                if first == true
                    first = false;
                    DATASET = [N_DATASET];   
                else
                    DATASET = [DATASET,N_DATASET];
                end
            end
            
            n = strmatch('ST_',FieldNames);
            ST_FieldNames = FieldNames(n); 
            if not(isempty(n))
                [N_DATASET] = obj.ST_Quote(Ticker,ST_FieldNames,DateNum);
                if first == true
                    first = false;
                    DATASET = [N_DATASET];   
                else
                    DATASET = [DATASET,N_DATASET];
                end
            end   
            
            n = strmatch('DL_FC_',FieldNames);
            DL_FieldNames = FieldNames(n); 
            if not(isempty(n))
                [N_DATASET] = obj.DL_FC_Quote(Ticker,DL_FieldNames,DateNum);
                if first == true
                    first = false;
                    DATASET = [N_DATASET];   
                else
                    DATASET = [DATASET,N_DATASET];
                end
            end 
            
            n = strmatch('DL_EPS_',FieldNames);
            DL_FieldNames = FieldNames(n); 
            if not(isempty(n))
                [N_DATASET] = obj.DL_EPS_Quote(Ticker,DL_FieldNames,DateNum);
                if first == true
                    first = false;
                    DATASET = [N_DATASET];   
                else
                    DATASET = [DATASET,N_DATASET];
                end
            end  
        end
    end
    methods %Quote Filtering
        function RUN_Quote_Hist(obj,MacroName)
            %%
            BB_Hist_Min = datenum('08-Oct-2007');
            h = waitbar(0);
            for i = BB_Hist_Min:today
                waitbar((BB_Hist_Min-i)/(today-BB_Hist_Min),h)
                obj.DateNum = i;
                Day = datestr(i,'DDD');
                switch Day
                    case {'Mon','Tue','Wed','Thu','Fri'}
                        obj.RunMacro(MacroName);  
                    otherwise
                end
            end
        end
        function RUN_Quote(obj,MacroName)
            %% Check for that data is avaliable
            BB_DateNum = obj.GetLastDateNum('BritishBulls','ALL_STATUS');
            Y_DateNum = obj.GetLastDateNum('Yahoo','MasterSyncDayEnd');
            FT_DateNum = obj.GetLastDateNum('FinicialTimes','Performance');
            ST_DateNum = obj.GetLastDateNum('Stox','Best_Investments');
            MinDate = min([BB_DateNum,Y_DateNum,FT_DateNum,ST_DateNum]);
            
            %
            if MinDate == today - 1
                disp('Data not avaliable today. Yesterdays data will be used. This is normally updated around 11pm') 
            elseif MinDate == today
                disp('Up to date. Todays data will be used')
            else
                disp('Data may be out of date, or it could be the weekend?')
            end
            %%
            obj.DateNum = MinDate;
            obj.RunMacro(MacroName);
        end
        function RUN_ALL_Quotes(obj,DateNum)
            %% Get Macro Name List
            PWD = pwd;
            
            PATH = [obj.InstallDir,'Macros\'];
            cd(PATH);
            names = rot90(struct2cell(dir));
            names = names(1:end-2,1);
            
            %only .m files
            n = [];
            for i = 1:max(size(names))
                if isempty(findstr('.m',names{i}))    
                else
                    n = [n,i];
                end
            end
            names = names(n);
            
            obj.DateNum = DateNum;
            for i = 1:max(size(names))
                MacroName = strrep(names{i},'.m','');
                obj.RunMacro(MacroName);
            end
            
            cd(PWD);
        end
    end
    methods %Program Quotes
        function [DATASET] = BB_STATUS_Quote(obj,Ticker,FieldNames,DateNum)
        % British Bulls Abstraction Layer
             %FieldNames:
             %  Ticker
             %  Description
             %  Subsector
             %  Prev
             %  Open
             %  High
             %  Low
             %  Close
             %  Change
             %  Signal
             %  Sector
             %  Profit
             FieldNames = strrep(FieldNames,'BB_STATUS_','');
             DATASET = obj.LoadResult('BritishBulls','ALL_STATUS',DateNum);
             if not(ischar(Ticker))
             DATASET = obj.ColumnStr(DATASET,'Ticker',Ticker);
             end
             
             Tickers = obj.GetColumn(DATASET,'Ticker');
             x = size(Ticker,1)
             for i = 1:x
                 waitbar(i/x)
                 n = find(strcmpi(Tickers,Ticker{i}));
                 if isempty(n)
                     N_DATASET = dataset(   {Ticker(i),'Ticker'}, ...
                                            {{'--'},'Description'}, ...
                                            {{'--'},'Subsector'}, ...
                                            {NaN,'Prev'}, ...
                                            {NaN,'Open'}, ...
                                            {NaN,'High'}, ...
                                            {NaN,'Low'},...
                                            {NaN,'Close'}, ...
                                            {NaN,'Change'}, ...
                                            {{'--'},'Signal'}, ...
                                            {{'--'},'Sector'}, ...
                                            {NaN,'Profit'});
                 else
                     N_DATASET = DATASET(n,:);
                 end
                 if i == 1
                    F_DATASET = N_DATASET;
                 else
                    F_DATASET = [F_DATASET;N_DATASET]; 
                 end
             end
             DATASET = F_DATASET;
             
             DATASET = obj.ColumnFiltering(DATASET,FieldNames);
             DATASET = obj.AddPreFix2ColumnNames('BB_STATUS_',DATASET);
        end
        function [DATASET] = BB_HIST_Quote(obj,Ticker,FieldNames,DateNum)
        % British Bulls Abstraction Layer
             %FieldNames:
             %  Ticker
             %  Description
             %  Subsector
             %  DateNum
             %  DateStr
             %  Signal
             %  Sector
             FieldNames = strrep(FieldNames,'BB_HIST_','');
             DATASET = obj.LoadResult('BritishBulls','HIST',DateNum);
             if not(ischar(Ticker))
             DATASET = obj.ColumnStr(DATASET,'Ticker',Ticker);
             end
             DATASET = obj.ColumnFiltering(DATASET,FieldNames);
             DATASET = obj.AddPreFix2ColumnNames('BB_HIST_',DATASET);
        end
        function [DATASET] = BB_CE_Quote(obj,Ticker,FieldNames,DateNum)
        % British Bulls Abstraction Layer
             %FieldNames:
             %  Symbol
             %  Date
             %  CurrentPrice
             %  Signal
             %  ConfSignal
             %  Money
             FieldNames = strrep(FieldNames,'BB_CE_','');
             DateNum = obj.GetLastDateOfResult('BritishBulls','CurrentEvent',DateNum);
             DATASET = obj.LoadResult('BritishBulls','CurrentEvent',DateNum);
             
             if not(ischar(Ticker))
             DATASET = obj.ColumnStr(DATASET,'Symbol',Ticker);
             end
             Tickers = obj.GetColumn(DATASET,'Symbol');
             x = size(Ticker,1);
             for i = 1:x
                 n = find(strcmpi(Tickers,Ticker{i}));
                 if isempty(n)
                     N_DATASET = dataset(       {Ticker(i),'Symbol'}, ...
                                                {{'N/A'},'Date'}, ...
                                                {NaN,'CurrentPrice'}, ...
                                                {{'N/A'},'Signal'}, ...
                                                {{'N/A'},'ConfSignal'}, ...
                                                {NaN,'Money'}, ...
                                                {NaN,'TargetProfit'}, ...
                                                {NaN,'LastProfit'}, ...
                                                {NaN,'Last2_TradeProfit'}, ...
                                                {NaN,'Last3_TradeProfit'}, ...
                                                {NaN,'Last4_TradeProfit'}, ...
                                                {NaN,'Last5_TradeProfit'}, ...
                                                {NaN,'Last6_TradeProfit'}, ...
                                                {NaN,'Last7_TradeProfit'}, ...
                                                {NaN,'Last8_TradeProfit'}, ...
                                                {NaN,'Last9_TradeProfit'}, ...
                                                {NaN,'Last10_TradeProfit'});
                 else
                     N_DATASET = DATASET(n,:);
                 end
                 if i == 1
                    F_DATASET = N_DATASET;
                 else
                    F_DATASET = [F_DATASET;N_DATASET]; 
                 end
             end
             DATASET = F_DATASET;
             DATASET = obj.ColumnFiltering(DATASET,FieldNames);
             DATASET = obj.AddPreFix2ColumnNames('BB_CE_',DATASET);
        end
        function [DATASET] = Y_Quote(obj,Ticker,FieldNames,DateNum)
        % Yahoo Abstraction Layer
            %PRICE
            %=====
            % 'a'   Ask
            % 'b'   Bid
            % 'c1'  Change
            % 'Spread'
            % 'c8'  AfterHoursChange_RealTime
            % 'j'   52WeekLow
            % 'j5'  ChangeFrom52weekLow
            % 'k2'  ChangePercent_RT
            % 'k5'  PercentChangeFrom52weekHigh
            % 'm'   DaysRange
            % 'm2'  DaysRange_RT
            % 'm5'  ChangeFrom200DayMovingAverage
            % 'm8'  PercentChangeFrom50DayMovingAverage
            % 'o'   Open
            % 'p2'  ChangeInPercent
            % 'b2'  Ask_RT
            % 'g'   DaysLow
            % 'k'   52WeekHigh
            % 'm3'  50DayMovingAverage
            % 'm6'  PercentageChangeFrom200DayMovingAverage
            % 'k4'  ChangeFrom52weekHigh
            % 'l1'  LastTrade_PriceOnly
            % 'm4'  200DayMovingAverage
            % 'm7'  ChangeFrom50DayMovingAverage
            % 'b3'  Bid_RT
            % 'c'   ChangeAndPercentageChange
            % 'c6'  Change_RT
            % 'h'   DaysHigh            
            % 'w'   52weekRange
            % 'w1'  DaysValueChange
            % 'p'   PreviousClose
            % 'j6'  PercentChangeFrom52weekLow
            % 't8'  1YrTargetPrice
            % 'w4'  DayValueChange_RT
            %
            %FUNDAMENTALS
            %============
            % 'd'   Dividend/Share
            % 'e'   Earnings/Share
            % 'e7'  EPS_EstimateCurrentYear
            % 'f6'  FloatShares
            % 'j1'  MarketCapitalization
            % 'y'   Dividend
            % 'r1'  DividendPayDate
            % 'r6'  Price/EPS_EstimateCurrentYear
            % 'q'   ExDividendDate
            % 'r2'  P/E_Ratio (RT)
            % 'r7'  Price/EPS_EstimateNextYear
            % 'e8'  EPS_EstimateNextYear
            % 'e9'  EPS_EstimateNextQuarter
            % 'r'   P/E_Ratio
            % 'r5'  PEG_Ratio
            % 'j3'  MarketCap_RT
            %
            %OTHER
            %=====
            % 'l'   LastTrade_WithTime
            % 'd1'  LastTradeDate
            % 'k1'  LastTrade_RT_WithTime
            % 't1'  LastTradeTime
            % 'b4'  BookValue
            % 'd2'  TradeDate
            % 'g3'  AnnualizedGain
            % 'g4'  HoldingsGain
            % 'g6'  HoldingsGain_RT
            % 'g1'  HoldingsGainPercent
            % 'g5'  HoldingsGainPercent_RT
            % 'v7'  HoldingsValue_RT
            % 'v1'  HoldingsValue
            % 'l2'  HighLimit
            % 'l3'  LowLimit
            % 's7'  ShortRatio
            % 't7'  TickerTrend
            % 'a2'  AverageDailyVolume
            % 'v'   Volume
            % 'c3'  Commission
            % 'i'   MoreInfo
            % 'n'   Name
            % 'p5'  Price/Sales
            % 's'   Symbol
            % 'e1'  ErrorIndication    (Returned for symbol changed/invalid)         
            % 'i5'  OrderBook_RT
            % 'j4'  EBITDA
            % 'n4'  Notes
            % 'p1'  PricePaid
            % 'p6'  Price/Book
            % 's1'  SharesOwned
            % 't6'  TradeLinks
            % 'x'   StockExchange
            
             FieldNames = strrep(FieldNames,'Y_','');
             DATASET = obj.LoadResult('Yahoo','MasterSyncDayEnd',DateNum);
             if not(ischar(Ticker))
             DATASET = obj.ColumnStr(DATASET,'Ticker',Ticker);
             end 
             FieldNames2 = {  'Ticker', ...
                              'Ask', ...
                              'Bid', ...
                              'Spread'};
             Tickers = obj.GetColumn(DATASET,'Ticker');
             DATASET = obj.ColumnFiltering(DATASET,FieldNames2);   
             x = size(Ticker,1);
             for i = 1:x
                 n = find(strcmpi(Tickers,Ticker{i}));
                 if isempty(n)
                     N_DATASET = dataset({Ticker(i),'Ticker'},{NaN,'Ask'},{NaN,'Bid'},{NaN,'Spread'});
                 else
                     N_DATASET = DATASET(n,:);
                 end
                 if i == 1
                    F_DATASET = N_DATASET;
                 else
                    F_DATASET = [F_DATASET;N_DATASET]; 
                 end
             end
             DATASET = F_DATASET;
             DATASET = obj.ColumnFiltering(DATASET,FieldNames); 
             DATASET = obj.AddPreFix2ColumnNames('Y_',DATASET);
        end
        function [DATASET] = FT_Perf_Quote(obj,Ticker,FieldNames,DateNum)
        % Finicial Times Abstraction Layer
            % 'Ticker'
            % 'Open'
            % 'AvVolumeStr'
            % 'DayLow'
            % 'DayHigh'
            % 'OfficialClose'
            % 'EPS'
            % 'DivYield'
            % 'DivPS'
            % 'DivExDate'
            % 'PreviousClose'
            % 'SharesOutstanding'
            % 'DivPayDate'
            % 'NextDivExDate'
            % 'NextDivPayDate'
            % 'MarketCap'
            % 'PE'
            % 'FreeFloat'
            % 'Currency'
            % 'AmountStr'
            % 'Exp'
            % 'Amount'
            % 'AmountNum'
            % 'MarketCapInDollars'
            % 'MarketCapCategory'
             FieldNames = strrep(FieldNames,'FT_Perf_','');
             DATASET = obj.LoadResult('FinicialTimes','Performance',DateNum);
             if not(ischar(Ticker))
             DATASET = obj.ColumnStr(DATASET,'Ticker',Ticker);
             end 
             Tickers = obj.GetColumn(DATASET,'Ticker');
             x = size(Ticker,1)
             for i = 1:x
                 waitbar(i/x)
                 n = find(strcmpi(Tickers,Ticker{i}));
                 if isempty(n)
                     N_DATASET = dataset(   {Ticker(i),'Ticker'}, ...
                                            {NaN,'Open'}, ...
                                            {{'--'},'AvVolumeStr'}, ...
                                            {NaN,'DayLow'}, ...
                                            {NaN,'DayHigh'}, ...
                                            {NaN,'OfficialClose'}, ...
                                            {NaN,'EPS'},...
                                            {NaN,'DivYield'}, ...
                                            {NaN,'DivPS'}, ...
                                            {{'--'},'DivExDate'}, ...
                                            {NaN,'PreviousClose'}, ...
                                            {{'--'},'SharesOutstanding'}, ...
                                            {{'--'},'DivPayDate'}, ...
                                            {{'--'},'NextDivExDate'}, ...
                                            {{'--'},'NextDivPayDate'}, ...
                                            {{'--'},'MarketCap'}, ...
                                            {{'--'},'PE'}, ...
                                            {{'--'},'FreeFloat'}, ...
                                            {{'--'},'Currency'}, ...
                                            {{'--'},'AmountStr'}, ...
                                            {{'--'},'Exp'}, ...
                                            {NaN,'Amount'}, ...
                                            {NaN,'AmountNum'}, ...
                                            {NaN,'MarketCapInDollars'}, ...
                                            {{'--'},'MarketCapCategory'} ...
                                            );
                 else
                     N_DATASET = DATASET(n,:);
                 end
                 if i == 1
                    F_DATASET = N_DATASET;
                 else
                    F_DATASET = [F_DATASET;N_DATASET]; 
                 end
             end
             DATASET = F_DATASET;
             DATASET = obj.ColumnFiltering(DATASET,FieldNames);  
             DATASET = obj.AddPreFix2ColumnNames('FT_Perf_',DATASET);
        end
        function [DATASET] = FT_BrokUp_Quote(obj,Ticker,FieldNames,DateNum)
        % Finicial Times Abstraction Layer
            %  Date                 
            %  Symbol        
            %  Recommendation
            %  Strength    
            %  NoOfBrokers    
            %  MedianTarget    
            %  HighEstimate
            %  LowEstimate    
            %  LastPrice    
            %  MedianProfit
             FieldNames = strrep(FieldNames,'FT_BrokUp_','');
             DATASET = obj.LoadResult('FinicialTimes','Best_Investments',DateNum);
             if not(ischar(Ticker))
             DATASET = obj.ColumnStr(DATASET,'Ticker',Ticker);
             end 
             DATASET = obj.ColumnFiltering(DATASET,FieldNames);  
             DATASET = obj.AddPreFix2ColumnNames('FT_BrokUp_',DATASET);
        end
        function [DATASET] = ST_Quote(obj,Ticker,FieldNames,DateNum)
        %STOXLINE abstraction layer
            %Symbol
            %TargetsSixMonths
            %SupportOne
            %SupportTwo
            %ResistanceOne
            %TargetOneYear
            %ResistanceTwo
            %PivotPointStart
            %MA_Five
            %MA_Twenty
            %MA_OneHundred
            %MA_TwoHundredAndFifty
            %K
            %D
            %RSI
            %High
            %Low
            %TenDysVol
            %Change
            %ThreeMnthsVol
            %PriceAndMovingAvText
            %BollingerBands
            %Rating
            %Signal
            %Stars
            %DateEval  
            
            FieldNames = strrep(FieldNames,'ST_','');
            DATASET = obj.LoadResult('Stox','Best_Investments',DateNum)
            
             
             if not(ischar(Ticker))
             DATASET = obj.ColumnStr(DATASET,'Symbol',Ticker);
             end 
             
             Tickers = obj.GetColumn(DATASET,'Symbol');
             x = size(Ticker,1);
             for i = 1:x
                 n = find(strcmpi(Tickers,Ticker{i}));
                 if isempty(n)
                     N_DATASET = dataset(   {Ticker(i),'Symbol'}, ...
                                            {NaN,'TargetsSixMonths'}, ...
                                            {NaN,'SupportOne'}, ...
                                            {NaN,'SupportTwo'}, ...
                                            {NaN,'ResistanceOne'}, ...
                                            {NaN,'TargetOneYear'}, ...
                                            {NaN,'ResistanceTwo'}, ...
                                            {NaN,'PivotPointStart'}, ...
                                            {NaN,'MA_Five'}, ...
                                            {NaN,'MA_Twenty'}, ...                                          
                                            {NaN,'MA_OneHundred'}, ...
                                            {NaN,'MA_TwoHundredAndFifty'}, ...
                                            {NaN,'K'}, ...
                                            {NaN,'D'}, ...
                                            {NaN,'RSI'}, ...
                                            {NaN,'High'}, ...
                                            {NaN,'Low'}, ...
                                            {NaN,'TenDysVol'}, ...
                                            {NaN,'Change'}, ...
                                            {NaN,'ThreeMnthsVol'}, ...
                                            {NaN,'PriceAndMovingAvText'}, ...
                                            {NaN,'BollingerBands'}, ...
                                            {NaN,'Rating'}, ...
                                            {NaN,'Signal'}, ...
                                            {NaN,'Stars'}, ...
                                            {DateNum,'DateEval'});
                 else
                     N_DATASET = DATASET(n,:);
                 end
                 if i == 1
                    F_DATASET = N_DATASET;
                 else
                    F_DATASET = [F_DATASET;N_DATASET]; 
                 end
             end
             DATASET = F_DATASET;
             DATASET = obj.ColumnFiltering(DATASET,FieldNames); 
             DATASET = obj.AddPreFix2ColumnNames('ST_',DATASET);
        end
        function [DATASET] = DL_FC_Quote(obj,Ticker,FieldNames,DateNum)
        % British Bulls Abstraction Layer
             %FieldNames:
             %  Symbol        
             %  DateStr              
             %  YearEnd        
             %  Revenue
             %  PreTax    
             %  EPS      
             %  PE  
             %  PEG     
             %  EPSGrth    
             %  Div      
             %  Yield

             FieldNames = strrep(FieldNames,'DL_FC_','');
             
             DateNum = obj.GetLastDateOfResult('DigitalLook','Forecasts',DateNum);
             DATASET = obj.LoadResult('DigitalLook','Forecasts',DateNum);
             
             if not(ischar(Ticker))
             DATASET = obj.ColumnStr(DATASET,'Symbol',Ticker)
             end
             
             DATASET = obj.ColumnFiltering(DATASET,FieldNames);
             DATASET = obj.AddPreFix2ColumnNames('DL_FC_',DATASET);
        end
        function [DATASET] = DL_EPS_Quote(obj,Ticker,FieldNames,DateNum)
        % British Bulls Abstraction Layer
             %FieldNames:
             %  Symbol        
             %  PE_Min_1YR              
             %  PE_Max_1YR
             %  PE_Min_1YR_M90L10
             %  PE_Max_1YR_M90L10
             %  PE_RT
             %  PE_Star
             %  Potential
             FieldNames = strrep(FieldNames,'DL_EPS_','');
             
             DateNum = obj.GetLastDateOfResult('DigitalLook','EPS',DateNum);
             DATASET = obj.LoadResult('DigitalLook','EPS',DateNum);
             
             if not(ischar(Ticker))
             DATASET = obj.ColumnStr(DATASET,'Symbol',Ticker);
             end
             
             DATASET = obj.ColumnFiltering(DATASET,FieldNames);
             DATASET = obj.AddPreFix2ColumnNames('DL_EPS_',DATASET);            
        end
    end
    methods (Hidden = true)
        function obj = QuoteAbstractionLayer(varargin)
            %dynamic inputs
            [x] = size(varargin,2);
            for i = 1:2:x
                obj.(varargin{i}) = varargin{i+1};
            end
            
            %%
            if isempty(obj.InstallDir)
                name = which(obj.ProgramName);
                obj.InstallDir = strrep(name,[obj.ProgramName,'.m'],'');                
            end             
            
            if strcmpi(obj.RunOnInt,'on')
                obj.Macro
                obj.RunMacro(obj.Macro);
            end
            if strcmpi(obj.CloseGUIwhenComplete,'on')
                close(gcf)
            end     
        end
    end
end