function [PriceMean] = PriceMean(symbol)
%
%Written by:    Bryan Taylor
%Date Created:  25th Febuary 2008
%Date Modified: 25th Febuary 2008

[Close,Open,High,Low] = StockQuote(symbol,{'close';'open';'high';'low'},'all','report',false,'outputs','multiple');
%Calculate mean
PriceMean = mean([Close,Open,High,Low],2);