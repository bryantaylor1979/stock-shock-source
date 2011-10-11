function [Output] = CalculateProfitFcn(varargin)
%
%Written by:    Bryan Taylor
%Date Created:  25th August 2008
%Date Modified: 25th August 2008

Mode = 'fastupdate'; %or update/fastupdate

%% Column Name Declaration
try
if strcmpi(varargin{1},'ColumnNames')
    Output = {'Date'; ...
              'Symbol'; ...
              'Action'; ...
              'Close'; ...
              'MoneyPot'; ...
              'Stake'; ...
              'Growth'; ...
              'Profit'; ...
              'TotalMoney'; ...
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
global h

%% Functional

[SellCharge,InvestmentAmount,NumberOfInvestments] = GetNumberOfInvestments(); %Total Available range

Buy_Sell_Sequence = GetStageData('Buy_Sell_Sequence');
MoneyPot = InvestmentAmount;
InvestedSymbols = {};
Data = {};
Mode = 'Silent';
TotalMoney = MoneyPot;

[x] = size(Buy_Sell_Sequence,1);
for i = 1:x
      %Update GUI
      set(h.Status,'String',['Processing... ',num2str(i),' of ',num2str(x),' (',num2str(round(i/x*100)),'%)']);
      drawnow;
    
      %Info
      Date = Buy_Sell_Sequence{i,1};
      Symbol = Buy_Sell_Sequence{i,2};
      Action = Buy_Sell_Sequence{i,3};
      Close = Buy_Sell_Sequence{i,4};
      
      if strcmpi(Action,'Buy');
          %Calc Stake
          [y] = size(InvestedSymbols,1);
          NoOfStakeInMoneyPot = NumberOfInvestments-y;
          Stake = MoneyPot/NoOfStakeInMoneyPot;
          
          %New Money Pot
          MoneyPot = MoneyPot - Stake;
          
          %Build Row
          NewRow = {Date,Symbol,Action,Close,MoneyPot,Stake,'n/a','n/a',TotalMoney};
          
          %Note Symbol in Invested Array
          InvestedSymbols = [InvestedSymbols;{Symbol}];
          
      elseif strcmpi(Action,'Sell')
          
          if Date==731209
             breakhere = 1; 
          end
          
          %Find last trade
          LastSymbol = Buy_Sell_Sequence(1:i-1,2);
          LastIndex = max(find(strcmpi(LastSymbol,Symbol)));
          BoughtPrice = Buy_Sell_Sequence{LastIndex,4};
          SoldPrice = Close;
          Growth = SoldPrice/BoughtPrice;
          
          %Profit
          Profit = Growth - SellCharge;
          
          %Calculate Stake
          LastStake = Data{LastIndex,6};
          Stake = LastStake*Profit;
          
          %TotalMoney
          TotalMoney = TotalMoney - LastStake + Stake;
          
          %Build Row
          NewRow = {Date,Symbol,Action,Close,MoneyPot,Stake,Growth,Profit,TotalMoney};
          MoneyPot = MoneyPot + Stake;
          
          %Note Symbol in Invested Array
          n = find(strcmpi(InvestedSymbols,Symbol));
          sizeIn = size(InvestedSymbols,1);
          InvestedSymbols = InvestedSymbols([1:n-1,n+1:sizeIn]);
      else
      end 
      
      % Update GUI
      if strcmpi(Mode,'Visual')
         set(h.table,'Data',Data);
      end
      Data = [Data;NewRow];
end

if strcmpi(Mode,'Silent')
    set(h.table,'Data',Data);
end
set(h.Status,'String','Ready');
Output = 1;

function [SellCharge,InvestmentAmount,NumberOfInvestments] = GetNumberOfInvestments()
%Written by:    Bryan Taylor
%Date Created:  30th April 2008
prompt= {'Sell Charge (%):', ...
         'Investment Amount (£):', ...
         'Number Of Investments'};
     
name        = 'Inputs for Decsion function';
numlines    = 1;

% Get Date Range
SellCharge               = 0.01;
InvestmentAmount         = 100;
NumberOfInvestments      = 10;

% input para gui
defaultanswer   = {num2str(SellCharge),num2str(InvestmentAmount),num2str(NumberOfInvestments)};
answer          = inputdlg(prompt,name,numlines,defaultanswer);
drawnow;

% Return data
SellCharge               = str2num(answer{1});
InvestmentAmount         = str2num(answer{2});
NumberOfInvestments      = str2num(answer{3});
