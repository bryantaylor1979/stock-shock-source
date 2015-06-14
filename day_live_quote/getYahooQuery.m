function DATASET = getYahooQuery(Symbols,Fields)
% a: Ask 	
% y: Dividend Yield
% b: Bid 	
% d: Dividend per Share
% b2: Ask (Realtime) 	
% r1: Dividend Pay Date
% b3: Bid (Realtime) 	
% q: Ex-Dividend Date
% p: Previous Close 	
% o: Open 	
% c1: Change 	
% d1: Last Trade Date
% c: Change & Percent Change 	
% d2: Trade Date
% c6: Change (Realtime) 
% t1: Last Trade Time
% k2: Change Percent (Realtime) 	
% p2: Change in Percent 	
% c8: After Hours Change (Realtime) 	
% m5: Change From 200 Day Moving Average
% c3: Commission 	
% m6: Percent Change From 200 Day Moving Average
% g: Day’s Low 	
% m7: Change From 50 Day Moving Average
% h: Day’s High 	
% m8: Percent Change From 50 Day Moving Average
% k1: Last Trade (Realtime) With Time 	
% m3: 50 Day Moving Average
% l: Last Trade (With Time) 	
% m4: 200 Day Moving Average
% l1: Last Trade (Price Only) 	
% t8: 1 yr Target Price 	
% w1: Day’s Value Change 	
% g1: Holdings Gain Percent
% w4: Day’s Value Change (Realtime) 	
% g3: Annualized Gain
% p1: Price Paid 	
% g4: Holdings Gain
% m: Day’s Range 	
% g5: Holdings Gain Percent (Realtime)
% m2: Day’s Range (Realtime) 	
% g6: Holdings Gain (Realtime)	
% k: 52 Week High 	
% v: More Info
% j: 52 week Low 	
% j1: Market Capitalization
% j5: Change From 52 Week Low 	
% j3: Market Cap (Realtime)
% k4: Change From 52 week High 	
% f6: Float Shares
% j6: Percent Change From 52 week Low 	
% n: Name
% k5: Percent Change From 52 week High 	
% n4: Notes
% w: 52 week Range 	
% s: Symbol
% s1: Shares Owned
% x: Stock Exchange
% j2: Shares Outstanding
% v: Volume 	
% a5: Ask Size 	
% b6: Bid Size 	Misc
% k3: Last Trade Size 	
% t7: Ticker Trend
% a2: Average Daily Volume 	
% t6: Trade Links
% i5: Order Book (Realtime)
% e: Earnings per Share 	
% l3: Low Limit
% e7: EPS Estimate Current Year 	
% v1: Holdings Value
% e8: EPS Estimate Next Year 	
% v7: Holdings Value (Realtime)
% e9: EPS Estimate Next Quarter 	
% s6 Revenue
% b4: Book Value 	
% j4: EBITDA 	
% p5: Price / Sales 	
% p6: Price / Book 	
% r: P/E Ratio 	
% r2: P/E Ratio (Realtime) 	
% r5: PEG Ratio 	
% r6: Price / EPS Estimate Current Year 	
% r7: Price / EPS Estimate Next Year 	
% s7: Short Ratio 	

    args.YahooURL = 'http://finance.yahoo.com/d/quotes.csv?s=';
    args.ChunkLimit = 200; 
    args.FieldStrDelim = '%s';
    
    if strcmpi(Fields,'all')
    Fields = fieldnames(loadAllFields);
    end
    
    [x] = size(Symbols,1);
    y = floor(x/args.ChunkLimit);
    for i = 1:y
        Start = (i-1)*args.ChunkLimit + 1;
        End = Start + args.ChunkLimit - 1;
        DATA = GetQueryChunk(args.YahooURL,Symbols(Start:End),Fields,args.FieldStrDelim);
        if i == 1
        DATASET = DATA;    
        else
        DATASET = [DATASET;DATA];
        end
    end
    Start = y*args.ChunkLimit + 1;
    if Start-1 == x

    else
        DATA = GetQueryChunk(args.YahooURL,Symbols(Start:end),Fields,args.FieldStrDelim);
        if y == 0
            DATASET = DATA; 
            return
        end
        DATASET = [DATASET;DATA];
    end
end
function Example()
%%
%d1    Last Trade Date 
%t1    Last Trade Time   
%a     Ask
%b     Bid
Fields = {  'a'; ...
            'b'; ...
            'd1'; ...
            't1'};
Symbols = {'BARC';'RBS';'HAWK'};
DATASET = GetYahooQuery(Symbols,Fields)

%%
DATASET = GetYahooQuery(Symbols,'all')
end
function [String, FieldOutputString,FieldStr] = BuildURL(YahooURL,Symbols,Fields,FieldStrDelim)
    %% Build Symbol List
    [x] = size(Symbols,1);
    SymbolString = strrep(Symbols{1},' ','');
%     SymbolString = [SymbolString,'.L'];
    for i = 2:x
        if i == 74
            x = 1;
        end
        Symbol = Symbols{i};
        if isnumeric(Symbol)
            Symbol = num2str(Symbol);
        end
        Temp = strrep(Symbol,' ','');
%         Temp = [Temp,'.L'];
        SymbolString = [SymbolString,'+',Temp];
    end

    %% Outputs & URL string
    [x] = max(size(Fields));
    FieldOutputString = ['[',Fields{1,1}]; 
    FieldString = Fields{1,1};
    
    for i = 2:x
        FieldOutputString = [FieldOutputString,',',Fields{i}];
        FieldString = [FieldString,Fields{i}];
        FieldStrDelim = [FieldStrDelim,'%s'];
    end
    FieldOutputString = [FieldOutputString,']'];      

    %%
    String = [YahooURL,SymbolString,'&f=',FieldString];
    FieldStr = FieldStrDelim;
end
function BUILDDATA = GetQueryChunk(YahooURL,Symbols,Fields,FieldStrDelim)
    [String, FieldOutputString,FieldStr] = BuildURL(YahooURL,Symbols,Fields,FieldStrDelim);

    %% Download Data
    stockdata = urlread(String);
    command = [FieldOutputString,'= strread(stockdata,''',FieldStr,''', ''delimiter'', '','', ''emptyvalue'', NaN);'];
    eval(command);
    

    %% Build Array
    [xt] = max(size(Fields));
    for ik = 1:xt
        Field = Fields{ik};
        eval(['DATA = ',Field,';']);
        switch GetClassFromTag(Field)
            case 'char'
                %%
                [yf] = size(DATA,1);
                for pf = 1:yf
                    NEWDATA{pf,1} = strrep(DATA{pf},'"','');
                end
            case 'num'
                nf = find(strcmpi(DATA,'N/A'));
                n1 = find(not(strcmpi(DATA,'N/A')));
                NEWDATA(n1,1) = str2double(DATA(n1));
                NEWDATA(nf,1) = NaN;
            otherwise
        end
        if ik == 1
            BUILDDATA = dataset({NEWDATA,Field});
        else
            BUILDDATA = [BUILDDATA,dataset({NEWDATA,Field})];
        end
        clear NEWDATA
    end
end
function Class = GetClassFromTag(Tag)
    switch lower(Tag)
        case {'a','b','p','o','m5','g','m7','h','m3','m4','l1','k','v','j','j5','k4','f6','j2','a5','b6','k3','a2','e7','e9','b4','p5','p6','r5','r6','r7','s7'}
            Class = 'num';
        case {'d1','t1'}
            Class = 'char';
        otherwise
            Class = 'char';
    end
end
function struct = loadAllFields()
struct.a = 'Ask';
struct.y = 'Dividend Yield';
struct.b = 'Bid';
struct.d = 'Dividend per Share';
struct.b2 = 'Ask (Realtime)';	
struct.r1 = 'Dividend Pay Date';
struct.b3 = 'Bid (Realtime)'; 	
struct.q = 'Ex-Dividend Date';
struct.p = 'Previous Close';	
struct.o = 'Open';	
struct.c1 = 'Change';	
struct.d1 = 'Last Trade Date';
struct.c = 'Change & Percent Change';	
struct.d2 = 'Trade Date';
struct.c6 = 'Change (Realtime)';
struct.t1 = 'Last Trade Time';
struct.k2 = 'Change Percent (Realtime)';	
struct.p2 = 'Change in Percent';	
struct.c8 = 'After Hours Change (Realtime)';	
struct.m5 = 'Change From 200 Day Moving Average';
struct.c3 = 'Commission';
struct.m6 = 'Percent Change From 200 Day Moving Average';
struct.g = 'Day’s Low';
struct.m7 = 'Change From 50 Day Moving Average';
struct.h = 'Day’s High';
struct.m8 = 'Percent Change From 50 Day Moving Average';
struct.k1 = 'Last Trade (Realtime) With Time';
struct.m3 = '50 Day Moving Average';
struct.l = 'Last Trade (With Time)';	
struct.m4 = '200 Day Moving Average';
struct.l1 = 'Last Trade (Price Only)'; 	
struct.t8 = '1 yr Target Price'; 	
struct.w1 = 'Day’s Value Change';	
struct.g1 = 'Holdings Gain Percent';
struct.w4 = 'Day’s Value Change (Realtime)';	
struct.g3 = 'Annualized Gain';
struct.p1 = 'Price Paid';	
struct.g4 = 'Holdings Gain';
struct.m = 'Day’s Range';	
struct.g5 = 'Holdings Gain Percent (Realtime)';
struct.m2 = 'Day’s Range (Realtime)';
struct.g6 = 'Holdings Gain (Realtime)';	
struct.k = '52 Week High'; 	
struct.v = 'More Info';
struct.j = '52 week Low';	
struct.j1 = 'Market Capitalization';
struct.j5 = 'Change From 52 Week Low';	
struct.j3 = 'Market Cap (Realtime)';
struct.k4 = 'Change From 52 week High';
struct.f6 = 'Float Shares';
struct.j6 = 'Percent Change From 52 week Low'; 	
struct.n = 'Name';
struct.k5 = 'Percent Change From 52 week High';	
struct.n4 = 'Notes';
struct.w = '52 week Range';
struct.s = 'Symbol';
struct.s1 = 'Shares Owned';
struct.x = 'Stock Exchange';
struct.j2 = 'Shares Outstanding';
struct.v = 'Volume';	
struct.a5 = 'Ask Size';	
struct.b6 = 'Bid Size 	Misc';
struct.k3 = 'Last Trade Size'; 	
struct.t7 = 'Ticker Trend';
struct.a2 = 'Average Daily Volume';	
struct.t6 = 'Trade Links';
struct.i5 = 'Order Book (Realtime)';
struct.e = 'Earnings per Share'; 	
struct.l3 = 'Low Limit';
struct.e7 = 'EPS Estimate Current Year'; 	
struct.v1 = 'Holdings Value';
struct.e8 = 'EPS Estimate Next Year'; 	
struct.v7 = 'Holdings Value (Realtime)';
struct.e9 = 'EPS Estimate Next Quarter'; 	
struct.s6 = 'Revenue';
struct.b4 = 'Book Value'; 	
struct.j4 = 'EBITDA'; 	
struct.p5 = 'Price / Sales';	
struct.p6 = 'Price / Book'; 	
struct.r = 'P/E Ratio'; 	
struct.r2 = 'P/E Ratio (Realtime)'; 	
struct.r5 = 'PEG Ratio';	
struct.r6 = 'Price / EPS Estimate Current Year'; 	
struct.r7 = 'Price / EPS Estimate Next Year'; 	
struct.s7 = 'Short Ratio'; 	
end