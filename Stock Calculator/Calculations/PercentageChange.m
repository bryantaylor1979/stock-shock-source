function [Value] = PercentageChange(symbol)
%UNTITLED1 Summary of this function goes here
%  Detailed explanation goes here

[Close,Open,High,Low] = StockQuote(symbol,{'close';'open';'high';'low'},'all','report',false,'outputs','multiple');
%Calculate mean
PriceMean = mean([Close,Open,High,Low],2);
%Calculate mean
DayDiff=[0;diff(PriceMean)];    
   
%% Calculation
Value = DayDiff./PriceMean;  %percent change