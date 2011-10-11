function [TradeStructure] = CalculateStake(TradeStructure)
%This function works out what stake to put on each investment
%Example: [TradeStructure] = CalculateStake(TradeStructure)
%
%Added Fields:
%   stake:  When it is a buy action, this ammount is equal to the amount of
%   money invested.
%
%   NoOfStakes: This number is equal to the number of stakes not in use on
%   the day of the investment.
%
%   MoneyPot: Amount of money not invested on that day.
global h
[x] = size(TradeStructure,2);
investment = 100;
number_of_investments = 10;

intial_investement = investment/number_of_investments;
StatusBar(h.statusbar,0);

symbolsinvested = [];
MoneyPot = investment; %money not currently invested
Stakes = number_of_investments; %number of stakes not invested
TotalMoney = investment; % total current assets

for i = 1:x
    StatusBar(h.statusbar,i/x);
    profit(i).symbol = TradeStructure(i).symbol;
    profit(i).datenum = TradeStructure(i).datenum;
    profit(i).pricemean = TradeStructure(i).PriceMean;
    if strcmp(TradeStructure(i).action,'Buy')
        %firstly we need to check the stakes avaliable
        profit(i).action = 'Buy';
        if Stakes<1
            error('Not enough stakes to buy stock')
        end
        %Calculate what the new stake should be
        profit(i).stake = MoneyPot/Stakes;
        TradeStructure(i).stake = MoneyPot/Stakes;
        
        %update the MoneyPot and number of stakes
        MoneyPot = MoneyPot - profit(i).stake;
        Stakes = Stakes - 1;
        TradeStructure(i).NoOfStakes = Stakes;
        TradeStructure(i).MoneyPot = MoneyPot;
        TradeStructure(i).TotalMoney = TotalMoney;  
        %Calculate totalprofit
        %not required nothing has changed
        
    elseif strcmp(TradeStructure(i).action,'Sell')
%        symbolsinvested = removesymbol(symbolsinvested,TradeStructure(i).symbol)

        % find price the stock was bought for
        symbols = struct2cell(profit);
        symbols = symbols(1,:,:);
        n = find(strcmp(symbols,TradeStructure(i).symbol));
        %last one is this Sell signal, so last minus 1
        [y] = size(n,1);
        loc = n(y-1);
        bought = profit(loc);
        
        % Calculate new stake price
        ratio = (TradeStructure(i).PriceMean/bought.pricemean);
        NewStake = bought.stake*ratio;
        TradeStructure(i).stake = NewStake;
        
        %Update pot of money
        MoneyPot = MoneyPot + NewStake;
        Stakes = Stakes + 1;
        TotalMoney = TotalMoney - bought.stake + NewStake;
        
        TradeStructure(i).NoOfStakes = Stakes;
        TradeStructure(i).MoneyPot = MoneyPot;
        TradeStructure(i).TotalMoney = TotalMoney;        
%         disp(['Action: Sell  Symbol:',TradeStructure(i).symbol,' Stake:',num2str(TradeStructure(i).stake),' TotalMoney: ',num2str(TotalMoney),' MoneyPot: ',num2str(MoneyPot),' Stakes: ',num2str(Stakes)])
    else
        error('action is not recognised') 
    end
    %Summary of Event
    RowInfo{1,1} = TradeStructure(i).symbol;
    RowInfo{1,2} = TradeStructure(i).action;
    RowInfo{1,3} = TradeStructure(i).datenum;
    RowInfo{1,4} = TradeStructure(i).stake;
    RowInfo{1,5} = TradeStructure(i).NoOfStakes;
    RowInfo{1,6} = TradeStructure(i).MoneyPot;
    RowInfo{1,7} = TradeStructure(i).TotalMoney;
    AddRow(RowInfo);
end