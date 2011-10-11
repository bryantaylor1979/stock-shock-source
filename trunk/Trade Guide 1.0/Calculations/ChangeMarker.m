function [changemarker] = ChangeMarker(symbol)  

[C,O,H,L,date] = StockQuote(symbol,{'close';'open';'high';'low';'datenum'},'all');
[buy,sell,tradesignal,changemarker,PercentageChange]=tradeguide(C,O,H,L,'Report',false);

size(buy); %buy can't be used without padding
size(sell); %sell can't be used withou padding, all this information is esstially in tradesignal anyway.
size(tradesignal); %OK
size(changemarker); %OK
size(PercentageChange); %OK

