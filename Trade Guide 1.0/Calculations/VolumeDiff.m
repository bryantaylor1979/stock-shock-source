function [VolumeDiff] = VolumeDiff(symbol)
%
%Written by:    Bryan Taylor
%Date Created:  25th Febuary 2008
%Date Modified: 25th Febuary 2008

[Volume] = StockQuote(symbol,{'Volume'},'all');
%Calculate mean
VolumeDiff=[0;diff(Volume)];    

