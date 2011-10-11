function [fieldnames] = GetAllFieldNames(varargin)
%[TABLELIST] = GETALLTABLENAMES(DatabaseName,UserName,Password)
%This function intergotes the database specified and return
%the table names. This is a generic function and can be used for all
%databses.
%
%If there is not inputs this function will try to connect to established
%connection. conn is should be declared as a global.
%
%Example:
%[tablelist] = GetAllFieldNames(conn);
%[tablelist] = GetAllFieldNames();

%parse inputs
[x] = size(varargin,2);
if x == 1
    conn = varargin{1};
elseif x == 0
    global conn
else
    error('Wrong number of variables');
end  
conn = database('SaxoTrader','','');

dbmeta = dmd(conn);
l = columns(dbmeta,'SaxoTrader');
% if isempty(l)
%     clear global conn
%     IntialiseDatabase
%     global conn
%     dbmeta = dmd(conn);
%     l = columns(dbmeta,'Stocks');
%     warning('Lost database connection. Re-attempt connection');
%     if isempty(l)
%         error('Re-attempt failed')
%     end
% end
fieldnames = l;