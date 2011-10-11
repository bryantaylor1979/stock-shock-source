function [] = CreateTable(conn,TableName,profile)
%
%profile = (ID SHORT, Name TEXT (40), Response MEMO, Class TEXT (10))
%
%Example:
%profile = '(symbol TEXT, datenum NUMBER PRIMARY KEY, close NUMBER, open NUMBER, low NUMBER, high NUMBER, closeadj NUMBER, volume NUMBER)'
%CreateTable('StockSymbol',profile);
%Profile: Types:-   SHORT, TEXT, MEMO, NUMBER

% CREATE TABLE MarketingSurvey (ID SHORT, Name TEXT (40), Response MEMO, Class TEXT (10));

% CREATE TABLE Customer 
% (SID integer PRIMARY KEY, 
% Last_Name varchar(30), 
% First_Name varchar(30));
sql = sprintf('CREATE TABLE %s %s',TableName,profile);
curs = exec(conn, sql);

%ERROR CHECKING
%Check to see if there was any errors
%Flag any errors reported in the curs object
status = curs.Message;
location = findstr(status,'No ResultSet was produced');
if isempty(location)
   disp(status)
   error(status) 
end