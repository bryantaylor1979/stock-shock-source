function [tradesignal] = TradeSignal(symbol)  

[C,O,H,L] = StockQuote(symbol,{'close';'open';'high';'low'},'all','report',false,'outputs','multiple');
[buy,sell,tradesignal,changemarker,PercentageChange]=tradeguide(C,O,H,L,'Report',false);