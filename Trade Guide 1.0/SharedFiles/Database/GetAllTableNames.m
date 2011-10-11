function [tablelist] = GetAllTableNames(varargin)
%[TABLELIST] = GETALLTABLENAMES(DatabaseName,UserName,Password)
%This function intergotes the database specified and return
%the table names. This is a generic function and can be used for all
%databses.
%
%If there is not inputs this function will try to connect to established
%connection. conn is should be declared as a global.
%
%Example:
%[tablelist] = GetAllTableNames(conn);
%[tablelist] = GetAllTableNames();

%parse inputs
[x] = size(varargin,2);
if x == 1
    conn = varargin{1};
elseif x == 0
    global conn;
else
    error('Wrong number of input variables');
end  
try
    ping(conn);
catch
    error('Please Intialise Database')
end

dbmeta = dmd(conn);
t = tables(dbmeta, 'cata');

%***********************************
%get all tables
[x] = size(t,1);
count = 1;
for i = 1:x
    if strcmp(t(i,2),'TABLE') 
       tablelist(count,1) = t(i,1);
       count = count + 1; 
    end
end
%***********************************
%end all tables