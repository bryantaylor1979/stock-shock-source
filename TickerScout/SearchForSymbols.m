function [FoundSymbol] = SearchForSymbols(Symbols)
%Search yahoo for available data symbol set
%
%The following function searches for the yahoo database to find out if the
%data avaliable for the even the given symbol set. The function returns a
%subset of the orginal array which corresponds to the symbols that have
%avaliable data on yahoo server.
%
%Example:-
%
%SymbolsToSearch = {'ibm';'aaa';ghnt'};
%[FoundSymbol] = SearchForSymbols(Symbols);
%
%this would reutrn:
%
%FoundSymbol = {'ibm','aaa'}
%
%Since 'ghnt' is not a valid symbol or it is not found on the yahoo server
%TODO: Use the Datafeed toolbox not sqq. Problems with this on living room
%pc.
%TODO: Maybe have a choice as to which fetch function is used'.

progressbar = false;
report = false;

if progressbar == true
    h=waitbar(0,'Intialising Please Wait..');
end

[x] = size(Symbols,1);
% START data available?
count = 1;
FoundSymbol = [];

for i = 1:x
    try
        StockQuoteQuery(Symbols{i,1}, today-365*100, today, 'd'); %search the last 100 years
        FoundSymbol{count,1} = Symbols{i,1};
        count = count + 1;
        string = [num2str(i),' of ',num2str(x),': ',upper(Symbols{i,1}),' Successful'];
    catch
        string = [num2str(i),' of ',num2str(x),': ',upper(Symbols{i,1}),' Failed'];
    end
    if progressbar == true
        waitbar(i/x,h,string)
    end
    clear present
end
% END data available

if report == true
    %Summary of findings
    [y] = size(FoundSymbol,1);
    disp([num2str(y),' Symbols found out of ',num2str(x),' possible combinations']);
end