function DATASET = getYahooHistorical(varargin)
    %% compulsory inputs
    SymbolName = varargin{1};
    
    % defaults
    args.startdate = today-2; %Datenum of the start of the world!
    args.enddate = today;
    args.method = 'fetch'; %fetch or sqq
    args.conn = [];
    args.freq = 'd'; %d, w, m, v(dvidends)
    
    % optional overwrites
    
    if strcmpi(args.method,'fetch')
        args.Params = {'Close','Open','High','Low','Volume'};
    end
    
    
    if isempty(args.conn)
        args.conn = Connect2yahoo();
    end
    if strcmpi(args.method,'fetch')
        data = fetch(args.conn,SymbolName,args.Params,args.startdate,args.enddate,args.freq)
    else
        % Outputs:  Parallel vectors (column arrays) or single output matrix if NVARGOUT=1. 
        %   DATE:       Date for the quote
        %   CLOSE:      Closing market price
        %   OPEN:       Opening price
        %   HIGH:       High price (during trading day or frequency period)
        %   LOW:        Low price (during trading day or frequency period)
        %   VOLUME:     Volume (during trading day or frequency period)
        %   CLOSEADJ:   Close Adjusted for Splits 
        data = sqq('ibm',today,today-7,'d')
    end
    
    x = size(args.Params,2);
    DATASET = [];
    for i = 1:x+1
        if i == 1
            DATASET = dataset({data(:,i),'DateNum'});
        else
            DATASET = [DATASET,dataset({data(:,i),args.Params{i-1}})];
        end
    end
end
function example()
    %%
    DATASET = getYahooHistorical('ibm')
end
function conn = Connect2yahoo()
    %%
    AutoRetry = true
    if AutoRetry == true
       Time = 2; 
    else
       Time = 1; 
    end
    Timeout = 40;
    while Time < Timeout
        try
            conn = yahoo;
            break
        catch
            if Time == 1
               ButtonName = questdlg(   'Do you want to retry or work offline?', ...
                                        'Connection Failed', ...
                                        'Retry', 'Offline', 'Retry'); 
               switch ButtonName
                   case 'Retry'
                       %Do nothing
                   case 'Offline'
                       break %Break out while loop
                   otherwise
               end
            end
            PauseTime = 5*2^Time;
            disp(['Connection failed. Wait ',num2str(PauseTime),' secs'])
            pause(PauseTime);
            Time = Time + 1;
        end
    end
    if Time == Timeout
        msgbox('Could not connect to yahoo. Check connection') 
    else
        disp('Connection established') 
    end
end

function [varargout] = sqq(varargin)
% SQQ -- calls STOCKQUOTEQUERY to fetch historical stock prices for a given ticker symbol
%     from the YAHOO web serve using the MATLAB Java URL interface.  SQQ allows
%     for greater flexibility of inputs, but the main code is in STOCKQUOTEQUERY 
%
%     v1.2 Michael Boldin 10/4/2003
%
%     STOCKQUOTEQUERY is based on parts of GETSTOCKDATA by Peter Webb of Mathworks, 
%     as explained in the October 2002 MATLAB News and Notes article
%     "Internet Enabled Data Analysis and Visualization with MATLAB"  
%     See STOCKQUOTEQUERY notes for corrections of problems and additional
%     features
%
%
% VARARGOUT: [date, close, open, low, high, volume, closeadj]
%
%      If NARGOUT=0, the arrays [date, close, open, low, high, volume, closeadj]
%      are created in 'base' memory.
%
%      If NARGOUT=1, output is single matrix will the full set of data items.
%
%      In the NARGOUT=3 case, output is [date, close, volume]
%
%      Otherwise in the NARGOUT=5 case, the full set of data items are placed into 
%      output arrays in the order [date, close, open, low, high, volume, closeadj]
%       
%      Last output item, closeadj, is usually the same as close in recent periods 
%      but adjusts for stock split in longer historical data.  The closeadj/close ratio 
%      can be used to adjust open, high, low.  Use close/closeadj to adjust volume.
%
%
% VARARGIN: (symbol, date1 or N, date2 or N, frequency)
%
%    If no inputs, keyboard/console inputs are required
%
%    Input Options-- VARARGINs 1 to 4
%
%    (SYMBOL). Single string only.  Assumes last day is today and queries includes the last 7 days. 
%
%    (SYMBOL, N).  Query covers last N days, using today for the last day.  
%
%    (SYMBOL, DATE1, N).  If N < 0, DATE1 is last day, and query covers the prior N days.  
%                         If N > 0, DATE1 is first day, and query covers the next N days.  N <= 5*365 required. 
%
%    (SYMBOL, DATE1, DATE2).  
%         DATE1:  START_DATE  date string or numeric
%         DATE2:  END_DATE date string or numeric.  (The date numeric must be > 5*365. 
%         DATE Inputs will be reordered if DATE1 > DATE2  
%
%    (SYMBOL, DATE1, N or DATE2, FREQUENCY).
%         Fourth input determine FREQUENCY: Daily ('d'), Weekly ('w'), or Monthly ('m')
%         The default FREQUENCY is 'd'.
%
%   These options make the following four cases equivalent
%       sqq('ibm')
%       sqq('ibm',7)
%       sqq('ibm',today,-7)
%       sqq('ibm',today-7,today)
%       sqq('ibm',today,today-7)
%       sqq('ibm',today,today-7,'d')
%
%     Note that N is always interpretted as days, and N is not limitted to trading days 
%     (when the stock market is open).  Thus, frequency does not affect how N is applied, 
%     i.e.  frequency = 'm' does not turn N into months 
%      
% Outputs:  Parallel vectors (column arrays) or single output matrix if NVARGOUT=1. 
%   DATE:       Date for the quote
%   CLOSE:      Closing market price
%   OPEN:       Opening price
%   HIGH:       High price (during trading day or frequency period)
%   LOW:        Low price (during trading day or frequency period)
%   VOLUME:     Volume (during trading day or frequency period)
%   CLOSEADJ:   Close Adjusted for Splits 
%

disp 'Stock Quote Query';

%extra step to ensure usable 'today' date; 
date_today=floor(731857);
try;
    date_today=today;
catch
    date_today=floor(now);
end;
if date_today < 731857;
  date_today=floor(731857);
end;

%Frequency default is daily 
freq= 'd';

%nargin

%Look at input arguments to determine query parameters
%No arguments-- need to ask for inputs
if ( nargin == 0 )
    symbol=input('Input ticker symbol: ','s');
    symbol=upper(symbol);
    
    sdate=input(['End date (use blank for today, ' datestr(date_today) ' ): '],'s');
    try;
        if isempty(sdate); 
            date2=date_today;
        else
            date2=datenum(char(sdate));
            date2ck=datestr(date2);
        end;
    catch;
        error(['Can not interpret date, please start over' sdate]); 
        return
    end;
    
    snum=input('Start Date or days back as number (use blank for 7 days): ','s');
    
    try, date1=datenum(char(snum)); catch, date1=[]; end;
    
    try;
        if isempty(snum); 
            date1=datenum(date2)-7;
        elseif ~isempty(date1);
            date1=date1; %date1 should be OK;  
        else  
            date1=date2-str2num(snum);  
        end;
    catch;
        error(['Problem with input number, please start over']); 
        return
    end;
    
end;    

if nargin >= 1
try
    
    symbol= varargin{1};
    symbol=upper(symbol);
    
    %One argument case, just stock symbol, get last seven days
    if ( nargin == 1 )
        date2= date_today;
        date1= date2 - 7;
        
        %Two argument case,  stock symbol and N days
    elseif ( nargin == 2 );
        v2= varargin{2};
        if isnumeric(v2)
            date2= date_today;
            v2= abs(v2);
            date1= date2 - v2;
        else
            disp(['*** Problem with Inputs, Please start over']);
            disp(varargin);
            return
        end
        
        %Three or four argument cases,  stock symbol and both start and end dates, or start is a N number
        %Fourth argument is frequency 
    elseif ( nargin == 3 | nargin == 4 )
        v2= varargin{2};
        v3= varargin{3};
        if ( nargin == 4 )
            freq= varargin{4};
        end;  
        
        if isnumeric(v3) & v3 <= 5*365;
            if ( v3 <= 0 );
                date2= datenum(v2);
                date1= date2 + v3;
            else;
                date1= datenum(v2);
                date2= date1 + v3;
            end;
        else;
            date1= datenum(v2);
            date2= datenum(v3);
            if date1 > date2; %switch dates;
                date1= datenum(v3);
                date2= datenum(v2);
            end;    
        end;
        
    elseif ( nargin > 4 );
        disp(['*** Too many inputs, four at most (symbol, date1, date2 or N, freq), Please start over']);
        disp(varargin);
        return
        
    end;    
    
catch
    disp(['*** Problem with Inputs, Please start over']);
    disp(varargin);
    return
    
end
end

%Always convert to date string for  stockquotequery function 
start_date=datestr(date1);  
end_date=datestr(date2);    

%check ticker symbol
try;
    symbol_numeric_ck= ~isempty(str2num(symbol));
    symbol_length=size(symbol,2);
end;

disp(' ');     
%Confirm symbol and dates are OK
if isempty(symbol) | symbol_numeric_ck | (symbol_length > 6);
    disp(['*** Problem with Ticker Symbol-- ' symbol '-- empty, number, or too long']); 
    disp('*** Please start over');
elseif ( datenum(end_date) >=  datenum(start_date) )
    disp('Starting query');
    disp(['Ticker Symbol: ' symbol ' , Start Date: ' datestr(start_date) ' , End Date: ' datestr(end_date)]);
    disp(['Covering ' num2str(datenum(end_date) - datenum(start_date)+1) ' total days (potentially)']);
else
    disp(['*** Problem with dates, please start over']);
    disp(['*** Check Start Date: ' start_date '  End Date: ' end_date]);
end;

[date, close, open, low, high, volume, closeadj] ...
     = StockQuoteQuery(symbol, start_date, end_date, freq);

if isempty(close);
   disp(['PROBLEM FOUND ... full extract NOT MADE for ' symbol  ]);
else;
   nr_date=size(date,1); 
   n_close=sum(close > 0);
   disp(['Done ... extracted ' num2str(n_close) ' valid stock price observations'  ...
      ' over ' num2str(nr_date) ' dates' ]);
end;

 %Now output part
 if nargout == 1;  
     varargout{1} = [date close open low high volume closeadj];
     
 elseif nargout == 2; 
     varargout{1} = date;
     varargout{2} = close; 
     
 elseif nargout == 5; 
     varargout{1} = date;
     varargout{2} = close;
     varargout{3} = open;
     varargout{4} = low;
     varargout{5} = high; 
     
 elseif nargout == 7; 
     varargout{1} = date;
     varargout{2} = close;
     varargout{3} = open;
     varargout{4} = low;
     varargout{5} = high; 
     varargout{6} = volume;
     varargout{7} = closeadj;
     
 elseif nargout == 0;
     assignin('base','date',date);
     assignin('base','close',close);
     assignin('base','open',open);    
     assignin('base','low',low);
     assignin('base','high',high);
     assignin('base','volume',volume);    
     assignin('base','closeadj',closeadj);
     
 end;
 
%end of --SQQ-- function


end

function [date, close, open, low, high, volume, closeadj] = StockQuoteQuery(symbol, start_date, end_date, frequency, varargin)
% STOCKQUOTEQUERY -- Fetch historical stock prices for a given ticker symbol
%     from the YAHOO web serve using the MATLAB Java URL interface.  
%     See SQQ for a function that calls STOCKQUOTEQUERY and allows for 
%     flexibility in input and output and for more explanation of inputs and outputs.
%
%     v1.3b Michael Boldin 10/23/2003  
%     changes made to make R12 compatible
%       uses findstr instead of strfind;
%
%     STOCKQUOTEQUERY is based on GETSTOCKDATA by Peter Webb of Mathworks, 
%     as explained in the October 2002 MATLAB News and Notes article
%     "Internet Enabled Data Analysis and Visualization with MATLAB"  
%     See notes below for corrections of problems and additional
%     features.
%
% Required Inputs:  (SYMBOL, START_DATE, END_DATE, FREQUENCY).
%    optional: VERBOSE=1 or 'V' as fifth input to display run time notes and status
%                      
% Outputs:  Parallel vectors (column arrays). 
%   DATE:       Date for the quotes
%   CLOSE:      Closing market price
%   OPEN:       Opening price
%   HIGH:       High price (during trading day or frequency period)
%   LOW:        Low price (during trading day or frequency period)
%   VOLUME:     Volume (during trading day or frequency period)
%   CLOSEADJ:   Close Adjusted for Splits 
%
%
% Corrections and additions to GETSTOCKDATA
%   --verifies YAHOO server tables have 7 elements on a line before parsing the line.
%       The server tables sometimes show extra lines for dividend payments and splits. 
%   --close(breader); close(ireader); close(stream); commented out-- caused problems.
%   --adjusts query parameters to refer to January as month '0', not '1', and February 
%       as  '1', and so on. (This is a feature of the YAHOO system. STOCKQUOTEQUERY uses
%       1 to 12 numbering for months in the input-output parameter translation.) 
%   --flips data vectors to normal date order (increasing, oldest to most recent).
%   --does not require month(), day() or year() functions, uses datevec. 
%   --keeps VOLUME and CLOSEADJ data.
%   --SQQ has flexible input options, especially for dates. 
%   --R12 compatible.
%


% Initialize input variables to empty matrices
dates = cell(1); date = [];
open = []; high = []; low = []; close = []; closeadj = [];
volume= [];
stockdata = {}; %Cell array for holding data lines from query

matlabv= str2num(version('-release'));
connect_query_data=0;  %this variable holds the status of the query steps;

verbose=0;
if ( nargin < 4 ),
    error('Not enough inputs');
elseif ( nargin >= 5 );
    v5=varargin{1};
    if isnumeric(v5), verbose=v5; end;
    if ischar(v5) & strncmp(upper(v5),'VERBOSE',1), verbose=1; end;
end;

symbol=upper(symbol);

% Set up the dates and query string
date1=datenum(start_date);   date2=datenum(end_date);
if date1 > date2; %switch dates;
    date1= date2;
    date2= datenum(start_date);
end;  
urlString = YahooUrlString(symbol, date1, date2, frequency);


% Prepare to query the server by opening the URL and using the 
% Java URL class to establish the connection.

if (verbose>=1);
%     disp('Contacting YAHOO server using ...');
%     disp(['url = java.net.URL(' urlString ')']);
end;
url = java.net.URL(urlString);

% Based on GETSTOCKDATA,
% Once the connection is established, create a stream object to read the
% data that the server has returned. This method creates a buffered i/o 
% stream object and then reads an entire line at a time (rather 
% than single characters).

try
    stream = openStream(url);
    ireader = java.io.InputStreamReader(stream);
    breader = java.io.BufferedReader(ireader);
    connect_query_data= 1; %connect made;
catch
    connect_query_data= -1;  %could not connect case;
%     disp(['URL: ' urlString]);
    error(['Could not connect to server. It may be unavailable. Try again later.']);
    stockdata={};
    return;
end

if (verbose>=1);
    disp(['Reading data for symbol ' symbol '...']);
end;

% First line has column header labels
line = readLine(breader);
if (verbose>=1);
    disp('Header Line');
    disp(breader);
    disp ' '
end;
    
    % Read all the available data. We know we've come to the end of the data
    % when the readLine call returns a zero length string. Store the data,
    % line by line, into a cell array. These strings will eventually be 
    % concatenated into one long string, and parsed by STRREAD, so make 
    % sure that each string ends with a comma (this uniformity makes for
    % easier parsing).
    
    not_done=1;
    ii=0;

    while not_done
        
        if (isempty(line) | prod(size(line)) == 0 ); 
            not_done=0;
            if (verbose>=1);
                disp(['... Finished, ' num2str(ii-1) ' lines of data']); 
            end;
            if ii > 0 & ~isempty(stockdata);
                connect_query_data = 2; %query processed;
            else;
                connect_query_data = -2;
            end;
            break; 
        end;
        
        ii=ii+1;  
        line = readLine(breader);
        line = char(line);
        if (verbose==2);
            disp(['Line ' num2str(ii) ': ' line]);
        end;
        
    % Add line to cell matrix if it has the full elements;
    %  try-if added to make R12 compatible
    try;
    if ( ~isempty(line) & size(line,2) > 3 & size(findstr(line,','),2) == 6 );
        line(end+1) = ','; 
        stockdata{ii} = line;
    end;
    catch; %do nothing in case of error above 
    end;
end

% Close the streams, in the opposite order in which they were opened.
%  from GETSTOCKDATA, but this caused problems so commented out   
%close(breader);
%close(ireader);
%close(stream);


% Make cell array one long string of comma-separated list of values
% grouped in sets of seven: DATE, OPEN, HIGH, LOW, CLOSE, VOLUME, CLOSE2.
% This pattern must repeat through the string in order to parse data
% correctly.
stockdata = cat(2,stockdata{:});

% Parse the string data into MATLAB numeric arrays. 
if (length(stockdata) > 0)    
    
    % Note that the order of -- open, high, low, close -- matches the YAHOO server table order,
    % not the function's output order of [date, close, open, low, high, volume, closeadj] 
    
    if matlabv >= 13;
      [dates, open, high, low, close, volume, closeadj] = strread(stockdata,'%s%f%f%f%f%n%f', 'delimiter', ',', 'emptyvalue', NaN);
    else; % R12 version of strread does not have 'emptyvalue' option;
      [dates, open, high, low, close, volume, closeadj] = strread(stockdata,'%s%f%f%f%f%n%f', 'delimiter', ',');
    end;
    
    % Reverse the data vectors to run oldest to most recent
    open=flipud(open); high=flipud(high);  low=flipud(low);
    close=flipud(close);  closeadj=flipud(closeadj);
    volume=flipud(volume);
    
    % Convert the string dates into date numeric format, '1-Jan-0000'=1
    try
        date = datenum(dates);
    catch
        date = datenum(dates,'yyyy-mm-dd');
    end
    date=flipud(date);
    
    connect_query_data = 3; %data processed;
    
    if (verbose>=1);
        disp(['Converted stock data to dates, open, high, low, close, volume, close2']); 
        disp(['Dates: ' datestr(date(1)) ' to '   datestr(date(end)) '  ' num2str(size(close,1)) ' observations']);      
    end;
end
end
%end of STOCKQUOTEQUERY function

function [urlString] = YahooUrlString(symbol, start_date, end_date, freq)
% Builds the YAHOO Stock Data query string, a specially formatted URL 
%   For retrieving stock quote data from  server = 'http://table.finance.yahoo.com' 
%   This function is used by STOCKQUOTEQUERY (& SQQ) and is based on 
%   GETSTOCKDATA by Peter Webb of Mathworks 
%
% Inputs:
%   SYMBOL: String representing the stock symbol
%   START_DATE: Serial date number
%   END_DATE: Serial date number
%   FREQ: Daily ('d'), Monthly ('m'), or Weekly('w')

% Server URL (name) should not change, query parameters tagged to the end of
% server URL string will vary according to user inputs
server = 'http://table.finance.yahoo.com/table.csv';

% Set day, month and year for the start and end dates
[startYear startMonth startDay] = datevec(start_date);
[endYear endMonth endDay] = datevec(end_date);

query = ['?a=' num2str(startMonth-1) '&b=' num2str(startDay) '&c=' num2str(startYear) ...
         '&d=' num2str(endMonth-1)   '&e=' num2str(endDay)   '&f=' num2str(endYear) ...
         '&s=' num2str(symbol) '&y=0&g=' num2str(freq) ];
% note adjustment to month number - 1, January=0, December=11

% Concatenate the server name and query parameters to complete the URL+query string
urlString = [ server query ];

%end of YAHOOURLSTRING function
end