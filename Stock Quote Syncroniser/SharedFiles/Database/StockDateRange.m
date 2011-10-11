function [startdate,enddate] = StockDateRange(conn,stock)
%Find date range for specifed stock in local database
%
%Example:
%[startdate,enddate] = StockDateRange('AAA');
%
%This function intergotes all the data found for that stock in the local
%database. By sorting the date in ascending order it then work out what the
%start and end date is for that stock.
%
%Created by:    Bryan Taylor
%Date Created:  17th Febuary 2007
%Date Modified: 16th May 2007

%find date range
% setdbprefs({'DataReturnFormat','ErrorHandling','NullNumberRead','NullNumberWrite','NullStringRead','NullStringWrite','JDBCDataSourceFile'},{'cellarray','store','NaN','NaN','null','null',''});
% conn = database('stocks','','');

conn = database('SaxoTrader','','');

if strcmpi(stock,'in');
    e = exec(conn,['SELECT ALL datenum FROM ',upper(stock),'_ ORDER BY datenum ASC']);
else
    e = exec(conn,['SELECT ALL datenum FROM ',upper(stock),' ORDER BY datenum ASC']);
end
try
e = fetch(e);
catch
error('Database Connection Lost:\n If the database is on a usb hardrive.... please plug it back in'); 
end
data = e.data;

if strcmp(e.Message,'Invalid Cursor')
    error(['Can''t find stock: ',upper(stock),'. It may not be in the database'])  
end
[x] = size(data,1);
startdate = data{1};
enddate = data{x};

close(e)
close(conn)

% 