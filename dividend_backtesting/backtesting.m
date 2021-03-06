function regression_result = backtesting(adjClose,div,TotalNumberOfDays)
%Having the data ready for backtesting, let’s look for the most profitable 
%period of time of buying-holding-and-selling SPY assuming that  
% find the most profitable period of holding SPY (long position)
    neg=[];
    for NoOfDays=1:TotalNumberOfDays
        [buy_price,sell_price] = create_trade_signal(NoOfDays,adjClose,div);
        struct = eval_trade_signal(buy_price,sell_price);
        regression_result.NoOfDays(NoOfDays) = NoOfDays;
        regression_result.TotalNoNegativeTrades(NoOfDays) = struct.TotalNoNegativeTrades;
        regression_result.TotalPerOfNegTrades(NoOfDays) = struct.TotalPerOfNegTrades;
        regression_result.AverageProfitPerDay(NoOfDays) = struct.AverageProfitPerDay;
    end
end
function [buy,sell] = create_trade_signal(Days2Hold,adjClose,div)
%we buy SPY one day after the dividends have been announced (at the market price), and 
%we hold for dt days (here, tested to be between 1 and 40 trading days).
    buy=[]; sell=[];
    for i=1:size(div,1)
        % find the dates when the dividends have been announced
        [r,c,v]=find(adjClose(:,1)==div(i,1));
        % mark the corresponding SPY price with blue circle marker
        hold on; plot(adjClose(r,1),adjClose(r,2),'ob');
        % assume you buy long SPY next day at the market price (close price)
        buy=[buy; adjClose(r-1,1) adjClose(r-1,2)];
        % assume you sell SPY in 'dt' days after you bought SPY at the market
        % price (close price)
        sell=[sell; adjClose(r-1-Days2Hold,1) adjClose(r-1-Days2Hold,2)];
    end
end
function struct = eval_trade_signal(buy,sell)
    Profits = sell(:,2)./buy(:,2)-1;
    struct.TotalProfit = sum(Profits);
    struct.AverageProfitPerDay = struct.TotalProfit/length(Profits);
    struct.TotalNoNegativeTrades = sum(Profits<0);
    struct.TotalPerOfNegTrades = sum(Profits<0)/length(Profits);
end