function [Output] = CalculateStake(varargin)
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
%
%Written by:    Bryan Taylor
%Date Created:  5th May 2008
%Date Modified: 5th May 2008

%% Column Name Declaration
try
if strcmpi(varargin{1},'ColumnNames')
    Output = {  'Symbol'; ...
                'Action'; ...
                'DateNum'; 
                'Stakes'; ...
                'NoOfStakes'; ...
                'MoneyPot'; ...
                'TotalMoney'; ...
                'PriceMean'; ...
            };
    return
end
end

%% Config Declarations
try
if strcmpi(varargin{1},'Config')
   Output = true; 
   return
end
end

%% Functional
global h
investment = 100;
number_of_investments = 10;

intial_investement = investment/number_of_investments;

symbolsinvested = [];
MoneyPot = investment; %money not currently invested
NoOfStakes = number_of_investments; %number of stakes not invested
TotalMoney = investment; % total current assets

[OutPutArray] = GetStageData('Descion');
OutPutArray = flipdim(OutPutArray,1);
[x] = size(OutPutArray,1);

for i = 2:x
    Status.PercentageComplete = i/x*100;
    set(h.Status,'String',[num2str(Status.PercentageComplete,3),'% Complete'])
%     StatusBar(h.statusbar,i/x);
    symbol = OutPutArray(i,1);
    datenum = OutPutArray(i,3);
    PriceMean = OutPutArray(i,4);
    action = OutPutArray(i,2);
    if strcmp(action,'Buy')
        
        %firstly we need to check the stakes avaliable
        if NoOfStakes<1
            error('Not enough stakes to buy stock')
        end
        %Calculate what the new stake should be
        stake = MoneyPot/NoOfStakes;
        
        %update the MoneyPot and number of stakes
        MoneyPot = MoneyPot - stake;
        NoOfStakes = NoOfStakes - 1; 
        
    elseif strcmp(action,'Sell')
        
        % find price the stock was bought for
        ResultsSoFar = get(h.table,'Data');
        symbols = ResultsSoFar(:,1);
        [symbols] = Java2Cell(symbols);
        n = find(strcmp(symbols,symbol));
        n = n(1);
        boughtpricemean = str2num(ResultsSoFar(n,8));
        boughtstake = str2num(ResultsSoFar(n,4));
        
        % Calculate new stake price
        ratio = (str2num(PriceMean)/boughtpricemean);
        NewStake = boughtstake*ratio;
        stake = NewStake;
        
        %Update pot of money
        MoneyPot = MoneyPot + NewStake;
        NoOfStakes = NoOfStakes + 1;
        TotalMoney = TotalMoney - boughtstake + NewStake;
    else
        error('action is not recognised') 
    end
    %Summary of Event
    RowInfo{1,1} = symbol;
    RowInfo{1,2} = action;
    RowInfo{1,3} = datenum;
    RowInfo{1,4} = stake;
    RowInfo{1,5} = NoOfStakes;
    RowInfo{1,6} = MoneyPot;
    RowInfo{1,7} = TotalMoney;
    RowInfo{1,8} = PriceMean;
    AddRow(RowInfo);
end

Output.dummy = 1;