function DATASET = TradePlan2TradeTable(varargin)
    % compulsory inputs
    DataSet = varargin{1};
    
    % default optional inputs
    args.SortBy = 'BuyDate';
    
    % optional input overwrites
    varargin = varargin(2:end);
    x = size(varargin,2);
    for i = 1:2:x
        args.(varargin{i}) = varargin{i+1};
    end

    Action = DataSet.Signal;
    [x] = size(Action,1);
    Temp = [];
    for i = 1:x
        if or(strcmpi(Action{i},'SELL'),strcmpi(Action{i},'SHORT'))
            DataSet2 = DataSet(1:i-1,:);
            %Find last buy trade
            Symbols = DataSet.Symbol;
            SELLTRADE = DataSet(i,:);
            
            Symbol = SELLTRADE.Symbol;
            
            % find buy trade
            n = find(strcmpi(Symbols,Symbol)); % filter entries with the same symbol
            POSSIBLE_BUYTRADE = DataSet(n,:);
            n = find(strcmpi(POSSIBLE_BUYTRADE.Signal,'BUY')) % get only buy trades
            POSSIBLE_BUYTRADE = POSSIBLE_BUYTRADE(n,:);
            n = find(POSSIBLE_BUYTRADE.DateNum < SELLTRADE.DateNum); % remove buy later than sell date
            POSSIBLE_BUYTRADE = POSSIBLE_BUYTRADE(n,:);
            n = find(max(POSSIBLE_BUYTRADE.DateNum) == POSSIBLE_BUYTRADE.DateNum); %get most recent buy
            BUYTRADE = POSSIBLE_BUYTRADE(n,:);
            

            %Build Info
            SellDate =   {SELLTRADE.DateNum,            'SellDate'};
            SellPrice =  {SELLTRADE.CurrentPrice,       'SellPrice'};
            BuyDate =    {BUYTRADE.DateNum,             'BuyDate'};
            BuyPrice =   {BUYTRADE.CurrentPrice,        'BuyPrice'};
            Symb =       {Symbol,                       'Symbol'};

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
    DATASET = sortrows(DATASET,args.SortBy,'descend');
end
function Example()
    %% 
    DATASET = getBritishbullsHistory('BARC.L');
    
    %%
    TT_DATASET = TradePlan2TradeTable(DATASET)
end