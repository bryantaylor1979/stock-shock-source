function [changemarker] = ChangeMarker(symbol)  

[C,O,H,L,date] = StockQuote(symbol,{'close';'open';'high';'low';'datenum'},'all');
try
[buy,sell,tradesignal,changemarker,PercentageChange]=tradeguide(C,O,H,L,'Report',false);
catch
x = 1;
end

