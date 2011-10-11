function [Summary,h] = Verify(symbols)
%Written by:    Bryan Taylor
%Date Created: 
global h 

saxosymbols = symbols; %Saxo Symbol
display = false;

% [symbols] = FailedLookUp(symbols);

%% Check yahoo is available
conn = yahoo;
conn2 = database('SaxoTrader','','');
[x] = size(symbols,1);
profile = '(symbol TEXT, datenum NUMBER, close NUMBER, open NUMBER, low NUMBER, high NUMBER, volume NUMBER)';

% if display == true   
%     Array{1,1} = 'Saxo Symbol'; %Saxo Symbol
%     Array{1,2} = 'Yahoo Symbol'; %yahoo Symbol
%     Array{1,3} = 'Status'; %Test Status
%     disp(Array(1,:));
% end

if isempty(h)
h = waitbar(0);
end
countpass = 0;
countfail = 0;
for i = 1:x
    waitbar(i/x,h,[num2str(i),' of ',num2str(x)]);
    yahoostr = symbols{i};
    try 
        D = fetch(conn,yahoostr,'open',today-365,today,'m');
        Status = 'PASS';
        yahoostr = strrep(yahoostr,'.','_');
        CreateTable(conn2,yahoostr,profile);
        countpass = countpass + 1;
    catch
        Status = 'FAIL';
        countfail = countfail + 1;
    end

%     if display == true
%         Array{1,1} = saxosymbols{i};
%         Array{1,2} = yahoostr; %yahoo Symbol
%         Array{1,3} = Status; %Test Status
%         disp([Array{1,1},', ',num2str(Array{1,2}),', ',num2str(Array{1,3})]);
%     end
%     clear D Array  
end
Summary.CountPass = countpass;
Summary.CountFail = countfail;