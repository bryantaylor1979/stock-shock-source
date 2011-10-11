function [attributes] = ColumnInformation(symbol,fieldname)
%[GETFIELDNAMETYPE(symbol,fieldname)
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
global conn
ping(conn)

sqlstatement = ['SELECT ALL ',lower(fieldname),' FROM ',upper(symbol)];
curs=exec(conn, sqlstatement);
curs=fetch(curs);
attributes = attr(curs);