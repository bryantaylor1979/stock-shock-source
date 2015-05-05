% http://www.quantatrisk.com/2013/08/28/yahoo-stock-data-in-matlab-and-a-model-for-dividend-backtesting/

%%
% Yahoo! Stock Data in Matlab and a Model for Dividend Backtesting
% (c) 2013 QuantAtRisk.com, by Pawel Lachowicz
 
function [adjClose, div] =getdata(stock)
% It is a well known opinion (based on many years of market observations) 
% that one may expect the drop of stock price within a short timeframe 
% (e.g. a few days) after the day when the stock’s dividends have been 
% announced. And probably every quant, sooner or later, is tempted to 
% verify that hypothesis. It’s your homework. However, today, let’s look 
% at a bit differently defined problem based on the omni-working reversed 
% rule: what goes down, must go up. Let’s consider an exchange traded fund 
% of SPDR S&P 500 ETF Trust labelled in NYSE as SPY.
% 
% First, let’s pull out the Yahoo! data of adjusted Close prices of SPY 
% from Jan 1, 2009 up to Aug 27, 2013
date_from=datenum('Jan 1 2009');
date_to=datenum('Aug 27 2013');
 
adjClose = fetch(yahoo,stock,'adj close',date_from,date_to);
div = fetch(yahoo,stock,date_from,date_to,'v'); %v is dividends

returns=(adjClose(2:end,2)./adjClose(1:end-1,2)-1);
 
% plot adjusted Close price of  and mark days when dividends
% have been announced
plot(adjClose(:,1),adjClose(:,2),'color',[0.6 0.6 0.6])
hold on;
plot(div(:,1),min(adjClose(:,2))+10,'ob');
ylabel('SPY (US$)');
xlabel('Jan 1 2009 to Aug 27 2013');
end