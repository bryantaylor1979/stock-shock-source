function [] = RemoveColumn(TableName,ColumnName)
%Remove column from table from database
%
%This function needs to have a global database intialised.

global conn
if isempty(conn)
   error('Please Intialise Database') 
end

e = exec(conn,['ALTER TABLE ',TableName,' DROP COLUMN ',ColumnName]);
e = fetch(e);
close(conn)
