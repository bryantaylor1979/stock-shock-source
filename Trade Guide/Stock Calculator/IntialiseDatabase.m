function [conn] = IntialiseStocksDatabase(varargin)
%IntialiseDatabase() 
%  This function instialises the stocks database.
%If no password and username is specified, then the function will prompt
%the user to insert the details
%
%INPUTS:
%   DatabaseName:- Name of the catalog
%   UserName:- username for the database
%   Password:- password for the database
%
%OUTPUTS:
%   None
%
%Example:-
%IntialiseDatabase(DatabaseName,UserName,Password)
%IntialiseDatabase %this will interactively log into the database.
%
%Created by:    Bryan Taylor
%Date Created:  17th Feburary 2007
%Date Modified: 17th Feburary 2007

%parse inputs
[x] = size(varargin,2);
if x == 0;
    DatabaseName = 'Stocks';
    [username,password] = LogInDetails;
elseif x == 3;
    DatabaseName = varargin{1};
    username = varargin{2};
    password = varargin{3};
else
    error('inputs are invalid')
end

% global conn dbmeta
%check connection

% if isempty(conn)
    %make connection
    conn = database(DatabaseName,username,password);
    dbmeta = dmd(conn);
% % else
%     warning('Connection is already established')
% end
drawnow;