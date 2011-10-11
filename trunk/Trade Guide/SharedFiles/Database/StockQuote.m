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

[conn,symbol,fieldname,range] = parseinputs(varargin);

try %wrapper to catch any errors

    
%CREATE SQL STATEMENT
if ischar(fieldname)
    fieldname = varargin{2};
elseif iscell(fieldname)
    %build string
    %'datenum,open,close,low,high'
    [x] = size(fieldname,1);
    string = '';
    for i = 1:x
       string = [string,fieldname{i},','];
    end
    [x] = size(string,2);
    fieldname = string(1,1:x-1);
end

datafound = false;
while datafound == false;
    try
        if range == 'all';
        sqlstatement = ['SELECT ALL ',lower(fieldname),' FROM ',upper(symbol),' ORDER BY datenum ASC'];
        else
            [x] = size(range,2);
            if x == 2;
                sqlstatement = ['SELECT ALL ',lower(fieldname),' FROM ',upper(symbol),' WHERE datenum BETWEEN ',num2str(range(1)),' AND ',num2str(range(2)),' ORDER BY datenum'];
            else
                sqlstatement = ['SELECT ALL ',lower(fieldname),' FROM ',upper(symbol),' WHERE datenum LIKE ',num2str(range(1))];
            end
        end
    end
    curs=exec(conn, sqlstatement);
    curs=fetch(curs);
    Data = curs.Data;
    if strcmp(Data,'No Data')
%         disp('No date found, searching previous dates')
        range(1) = range(1)-1;
    else
        datafound = true;
    end
end

%Data massaging
NewDate = cell2mat(Data);
[x] = size(NewDate,2);

for i = 1:x
varargout{i} = NewDate(:,i);
end

%*******************************************************
%ERROR REPORTING
catch %this means there is no data found in the database
    %try and find a reason for there not being data
    disp('No Data was found...')
%     disp('Detecting Reason Error:')
%     %check stock name is correct
%     [tablelist] = GetAllTableNames(conn);
%     [x] = size(tablelist,1);
%     tablenamepreset = false;
%     for i = 1:x
%         if strcmp(upper(tablelist{i,1}),upper(symbol));
%             tablenamepreset = true;
%             break
%         end
%     end
%     if tablenamepreset == false;
%         error(['Symbol: ',upper(symbol),' Does not exist in the local databse'])
%     else
%         disp(['Symbol: ',upper(symbol),' Was Successfully found in the local database'])
%     end
%     %check stock name is correct
%     [FieldNames] = GetAllFieldNames()
%     [x] = size(FieldNames,1);
%     FieldNamePreset = false;
%     for i = 1:x
%         if strcmp(upper(FieldNames{i,1}),upper(fieldname));
%             FieldNamePreset = true;
%             break
%         end
%     end 
%     if FieldNamePreset == false;
%         error(['FieldName: ',upper(fieldname),' Does not exist in the local databse'])
%     else
%         disp(['FieldName: ',upper(fieldname),' Was Successfully found in the local database'])
%     end
%     if and(tablenamepreset == false,FieldNamePreset == false)
%         error('Cause of error not found.');
%     end
end
%ERROR REPROTING END

function [conn,symbol,fieldname,range,report] = parseinputs(varargin)
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
   %look for global connection
   global conn
   try
       Message = conn.Message;
   catch
       error('Global connection is invalid, Please use IntialiseDatabase')   
   end
   if isempty(conn)
       error('No database connection found') 
   end
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
report = false;

%optional parameters
for i = 4:2:x
   switch lower(varargin)
       case 'report'
            report = varargin{i+1};
       otherwise
           error('Optional parameter was not recognised')
           
   end
end