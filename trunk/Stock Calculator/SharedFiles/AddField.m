function [] = AddField(conn,TableName,fieldname,DataType)
%Add a new field to a table
%
%INPUTS:
%   TableName:  Name of the table you would like to add a field.
%   Fieldname:  Fieldname you want to add.
%   DataType:   Type of data associated with the filed name
%               'Type(FieldSize)
%               'TEXT(40)'  40 character max length.
%               'TEXT(20)'
%               'TEXT(10)'
%               'NUMBER'    defaults to double (not sure how to do interger
%                           at the moment.
%
% Example:
% conn = database('SaxoTrader','','');
% AddField(conn,TableName,fieldname,DataType);
%
%Written by:    Bryan Taylor
%Date Created:  9th July 2008
%Date Modified: 9th July 2008

% CREATE TABLE MarketingSurvey (ID SHORT, Name TEXT (40), Response MEMO, Class TEXT (10));
% ALTER TABLE MyTable ADD COLUMN NewColumn TEXT (20);
sql = sprintf('ALTER TABLE %s ADD COLUMN %s %s',TableName,fieldname,DataType);
curs = exec(conn, sql);

%ERROR CHECKING
%Check to see if there was any errors
%Flag any errors reported in the curs object
status = curs.Message;
location = findstr(status,'No ResultSet was produced');
if isempty(location)
   error(status) 
end
