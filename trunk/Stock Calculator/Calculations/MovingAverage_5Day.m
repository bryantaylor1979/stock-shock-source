function [Av] = MovingAverage_5Day(symbol)  

[C,O,H,L] = StockQuote(symbol,{'close';'open';'high';'low'},'all');

[Av] = CalcMovingAv(symbol,5);