function [ output_args ] = CheckDataIntergrity( input_args )
%CheckDataIntegrity Check the is only one entry per day.
%
%This function checks that there is only one entry per day. The should
%never be a situation where there is more.
%
%Written by: Bryan Taylor
%Date Created: 2nd July 2007
%Date Modified: 2nd July 2007

global conn
if isempty(conn)
   IntialiseDatabase;
end

sqlstatement = ['SELECT ALL datenum FROM ',symbol,' ORDER BY datenum DESC, datenum ASC'];
curs=exec(conn, sqlstatement);
    
%Get the data using fetch. 
curs=fetch(curs);

%View the results. 
Data = curs.Data;