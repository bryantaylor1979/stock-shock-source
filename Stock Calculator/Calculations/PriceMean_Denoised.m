function [price] = PriceMean_Denoised(symbol)
%
%Written by:    Bryan Taylor
%Date Created:  25th Febuary 2008
%Date Modified: 25th Febuary 2008

[close,open,high,low] = StockQuote(symbol,{'close';'open';'high';'low'},'all');
P=mean([close,open,high,low],2);
[price] = NoiseRemoval(P,'softswitch',0,'noisethreshold',0.01);