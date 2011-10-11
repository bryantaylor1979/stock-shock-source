function [varargout] = StockQuote(varargin)
%STOCKQUOTE
%   This is similiar to stockquotequery but in gets data from local
%   database
%
%INPUTS
%   Conn -  Connection Object 
%   symbol- symbol of data required.
%           {'datenum';'close';'open';'high';'low'} or
%           'close'
%   fieldname- field name or column name of data set.
%   D1- Start Date (Datevec)
%   D2- End Date (Datevec)
%
%OUTPUTS
%   Data = Data with selected stocks.
%
%Example:- 
%   [Close] = StockQuote(conn,'AAA','close','all');
%   [Close] = StockQuote('AAA','close','all');
%   [Close] = StockQuote('AAA','close',[D1,D2])
%   [Date,Close,Open,High,Low] = StockQuote('AAA',{'datenum';'close';'open';'high';'low'},'all')
%
%   [startdate,enddate] = StockDateRange('AAA');
%   IntialiseDatabase('Stocks','admin','tango224')
%   [Close] = StockQuote('AAA','close',[startdate,enddate-30]);
%
%Optional:
%   Report:  See Internal Worrking of this function
%
%Created by:    Bryan Taylor
%Date Created:  17th Febuary 2007
%Modified Date: 23rd Febuary 2007
%Revision:      1.2

[conn,symbol,fieldname,range,report,outputs] = parseinputs(varargin);

conn = database('SaxoTrader','','');
 
%CREATE SQL STATEMENT
if ischar(fieldname)
    fieldname = varargin{2};
elseif iscell(fieldname)
    %build string
    %'datenum,open,close,low,high'
    [x,y] = size(fieldname);
    x = max([x,y]);
    string = '';
    for i = 1:x
       string = [string,fieldname{i},','];
    end
    [x] = size(string,2);
    fieldnames = string(1,1:x-1);
end

datafound = false;
time = 1;
while datafound == false;
    timeout = 30;
    if time == timeout;
       break 
    end
    try
        if ischar(range)
        sqlstatement = ['SELECT ALL ',lower(fieldnames),' FROM ',upper(symbol),' ORDER BY datenum ASC'];
        else
            [x] = size(range,2);
            if x == 2;
                sqlstatement = ['SELECT ALL ',lower(fieldnames),' FROM ',upper(symbol),' WHERE datenum BETWEEN ',num2str(range(1)),' AND ',num2str(range(2)),' ORDER BY datenum'];
            else
                sqlstatement = ['SELECT ALL ',fieldnames,' FROM ',upper(symbol),' WHERE datenum LIKE ',num2str(range(1))];
            end
        end
    end
    curs=exec(conn, sqlstatement);
    curs=fetch(curs);
    Data = curs.Data;
    if strcmp(Data,'No Data')
        if ischar(range)
           error([upper(symbol),' is empty']); 
        end
%         disp('No date found, searching previous dates')
        range(1) = range(1)-1;
        time = time + 1;
    else
        datafound = true;
    end
end

%% Build output argument
[x] = size(Data,2);
warning off
for i = 1:x
    if iscell(Data)
        varargout{i} = cell2mat(Data(:,i));
    else
        varargout{i} = Data(:,i);
    end
    if report == true
        Value = Data{:,i};
        if isnumeric(Value)
            Value = num2str(Value);
        end
        if isnan(Value)
           Value = 'NaN'; 
        end
        fprintf([fieldname{i},': ',Data{:,i},' ']);
    end
end
fprintf(['\n'])
warning on

if strcmpi(outputs,'single');
    varargout = {varargout};
end

function [conn,symbol,fieldname,range,report,outputs] = parseinputs(varargin)
%Make inputs
varargin = varargin{1};
[x] = size(varargin,2);

%try first input to see if its the connection
temp = varargin{1};
try %try to see it's a valid connection. 
    Message = temp.Message;
    if isempty(Message)
        disp('valid')
        varargin = varargin{2:x};
        conn = varargin{1};
    end
catch
%    %look for global connection
%    global conn
%    try
%        Message = conn.Message;
%    catch
%        error('Global connection is invalid, Please use IntialiseDatabase')   
%    end
%    if isempty(conn)
%        error('No database connection found') 
%    end
conn = -1;
end

try
    symbol = varargin{1};
    fieldname = varargin{2};
    range = varargin{3};
catch
    error('problem with complusory fields')
end 

%defaults
[x] = size(varargin,2);
report = true;
outputs = 'single';

%optional parameters
for i = 4:2:x
   switch lower(varargin{i})
       case 'report'
            report = varargin{i+1};
       case 'outputs' %or single
            outputs = varargin{i+1};
       otherwise
           error('Optional parameter was not recognised')
           
   end
end