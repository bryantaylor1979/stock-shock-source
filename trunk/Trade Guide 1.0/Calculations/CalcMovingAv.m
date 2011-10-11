function [Out] = CalcMovingAv(symbols,NumberOfDays)
%Calculate stock price moving average
%  Detailed explanation goes here
%
%Example:
%Calculate a month moving average
%[MovingAv] = CalcMovingAv('AA',30);
%
%Example:
%Calculate all the moving averages for the whole database.
%
%Copyright 2007, CoLogic, Inc

%TODO: Add resulting data to local database
%TODO: Allow the user to specify date range.
%TODO: Add optional plot.

h = waitbar(0,'Intialising Database');
display = true;

if strcmp(lower(symbols),'all') %if all get a list of tables preset.
    [symbols] = GetAllTableNames();
elseif ischar(symbols)
    symbols = {symbols};
end

%%Template: Check Connection
global ConnectionName
[conn] = PingDatabase(ConnectionName);

%% Template: Add new data to databse
%should only need to change this section.
Name = ['MovingAv_',num2str(NumberOfDays),'_Day'];

x = size(symbols,1);
for i = 1:x
   symbol = symbols{i,1};
   waitbar(i/x,h,['Analysis on symbol: ',symbol]);
   
   %Check field exists
   [fieldnames] = GetFieldNames(symbol);
   n = find(strcmp(fieldnames,Name));
   if isempty(n)
       AddField({symbol},Name,'NUMBER');
   end
   
   %get data
   try
        [Date,OldMovingAv,Open,Close,High,Low] = StockQuote(symbol,{'datenum';Name;'open';'close';'high';'low'},'all');
        empty = false;
        [s] = size(Date,1);
        if s<=NumberOfDays
            empty = true;
        end
   catch
        empty = true;
   end
   
   if empty == false;
        %Calculate mean
        P=mean([Close,Open,High,Low],2);
        [MovingAv,LONG] = movavg(P,NumberOfDays,NumberOfDays,0);
   
        %Check the field name is there
        h2 = waitbar(0,'Updating Symbol');
   
        n1 = find(isnan(OldMovingAv));
        
        %Crop all data acordingly
        MovingAv = MovingAv(n1); %only update the NaN
        Date = Date(n1);
        Open = Open(n1);
        Close = Close(n1);
        High = High(n1);
        Low = Low(n1);
        
        [y] = size(MovingAv,1)
        
        if isempty(n1)
            disp([symbol,': Up-To-Date'])
        else
            for j = 1:y
                waitbar(j/y,h2,['Updating Symbol: ',symbol]);
                whereclause = ['WHERE datenum = ',num2str(Date(j))];
                try
                    update(conn, symbol, {Name}, MovingAv(j), whereclause);
                catch 
                    error('can''t update table')
                end
            end
        end
        close(h2)
        Out = MovingAv;
   end
      
   %%Template : display calculation
   if and(display == true,empty == false)
        try
        close(h5)
        end
        h5 = Display(Date,P,MovingAv,NumberOfDays);
   end
   clear P
   clear Date
   clear MovingAv
end
close(h)

function [h] = Display(date,P,MovingAv,NumberOfDays)
%
h = figure;
hline = plot(date,P,'k-',date,MovingAv,'r--');
set(h,'Name',[num2str(NumberOfDays),' Day, Moving Average'])
set(h,'NumberTitle','off');
datetick

function [conn] = PingDatabase(database)
%% Update database
switch lower(database)
    case 'local'
        global conn
        if isempty(conn)
             IntialiseDatabase;
        end
    case 'yahoo'
        error('Yahoo database not currently supported')
    case 'bloomberg'
        error('Bloomberg database not currently supported')
    otherwise        
end
