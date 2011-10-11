function [fieldnames] = GetAllFieldNames(varargin)
%Returns a list of field names from specified database
%
%[TABLELIST] = GETALLTABLENAMES(DatabaseName,UserName,Password)
%This function intergotes the database specified and return
%the table names. This is a generic function and can be used for all
%databses.
%
%If there is not inputs this function will try to connect to established
%connection. conn is should be declared as a global.
%
%Example:
%IntialiseDatabase;
%[tablelist] = GetAllFieldNames();
%
%Written by: Bryan Taylor
%Date Create: 29th July 2007
%Date Modified: 29th July 2007

%parse inputs
[x] = size(varargin,1);

conn = database('SaxoTrader','','');
dbmeta = dmd(conn);

if x == 0
    l = columns(dbmeta,'SaxoTrader');
    fieldnames = l{1,2};
elseif x == 1
    l = columns(dbmeta,'SaxoTrader',varargin{1})
else
    fieldnames = l{1,2};
end