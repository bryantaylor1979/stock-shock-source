function [CurrentDate,TradeStructure,Complete] = Descion(varargin);
%Descion - Buy and sell stocks
%
%Inputs: - None: Will work out buy and sell stocks
%          'Verfication', Will verfiy ouput stucture
%
%StartDate (Class: datenum, Default:- Whole database)
%EndDate (Class: datenum, Default:- Whole database)
%
%Optional Inputs:
%================
%Mode (Default:- 'thresholded', Class: Char, Values: 'all'/'thresholded')
%This is the minimum number of ticker symbols available on the day of investments. 
%This is usefull to remove the older stats which only have 2-3 stocks avaiable for
%that day. This program is proven to work well when it has lots of available
%stocks avaliable. If 'all' is selected the descion is made on all available
%data. If the 'threholded' is selected the algo will work on the specfied
%'MinimumThreshold'
%
%NoOfInvestments (Default: 10, Class: Int)
%This specifies the number of investments required for that day. For
%example if this value is specifed as 10. The will always ten stakes
%invested in different stocks.
%
%ForceRefresh (Default: false, Class: Logical)
%This forces the function to reassess the database to see if the a new
%startdate and enddate is required. This could be done automatically in the
%future by using a check sum.
%
%
%Example:- Changing an optional input from it's default.
%   [TradeStructure] = Descion('Mode','thresholded','MinimumThreshold',100);
%
%Example: Normal mode
%   [TradeStructure] = Descion();
%
%Example: Verification 
%   Descion('Verfication',TradeStructure);
%
%Written by:    Bryan Taylor
%Date Created:  28th October 2007
%Date Modified: 27th December 2007
global h savecriteria status

[startdate,enddate,number_of_investments,h] = ParseInputs(varargin);

Names = {   'Symbol'; ...
            'Action'; ...
            'DateNum'; ...
        };
IntialiseTable(Names);
TradeStructure = [];
InvestedSymbols = [];

try
startdate = savecriteria.DescionCurrentDate;
TradeStructure = savecriteria.DescionTradeStruct;
set(h.table,'Data',savecriteria.DescionJavaData); 
InvestedSymbols = savecriteria.DescionInvestedSymbolArray;
end
Complete = true;
% StatusBar(h.statusbar,0);
%     try
for date = startdate:enddate
    set(h.Status,'String',[num2str((date-startdate)/(enddate-startdate))*100,'% Complete'])
%     Value = get(h.stop,'Value');
    Value = 0;
    if Value == 1 
       CurrentDate = date;
       Complete = false;
       savecriteria.DescionTradeStruct = TradeStructure;
       savecriteria.DescionJavaData = get(h.table,'Data');
       savecriteria.DescionCurrentDate = CurrentDate;
       savecriteria.DescionInvestedSymbolArray = InvestedSymbols;
       set(h.stop,'Value',0);
       status.CalculateStake.updaterequired = true;
       return
    end
%     StatusBar(h.statusbar,(date-startdate+1)/(enddate-startdate+1));

    %%SELL
    SellSymbols = DaySellSymbols(InvestedSymbols,date); 

    if not(isempty(SellSymbols))
        [x] = size(SellSymbols,2);
        for i = 1:x
            RowInfo{1,1} = SellSymbols(i).symbol;
            RowInfo{1,2} = SellSymbols(i).action;
            RowInfo{1,3} = SellSymbols(i).datenum;
            AddRow(RowInfo);
        end
    end

    %update tradeStructure
    TradeStructure = [TradeStructure,SellSymbols];

    %remove invested symbols from list
    Sell = Struct2Data(SellSymbols,'symbol');
    InvestedSymbols = removesymbol(InvestedSymbols,Sell);

    %%BUY
    %% Keep Investing Until We have the required number of investments
    [Symbols] = GetDayInvestments(date,InvestedSymbols,number_of_investments);

    if not(isempty(Symbols))
%                 DispStruct(Symbols,{'symbol';'action';'datenum'});
        TradeStructure = [TradeStructure,Symbols];

        [x] = size(Symbols,2);

        for i = 1:x
            RowInfo{1,1} = Symbols(i).symbol;
            RowInfo{1,2} = Symbols(i).action;
            RowInfo{1,3} = Symbols(i).datenum;
            AddRow(RowInfo);
        end

        %note invested symbols
        InvestedSymbols = [InvestedSymbols;Struct2Data(Symbols,'symbol')];
    end
end
savecriteria.DescionTradeStruct = TradeStructure;
savecriteria.DescionJavaData = get(h.table,'Data');
savecriteria.DescionCurrentDate = CurrentDate;
savecriteria.DescionInvestedSymbolArray = InvestedSymbols;

status.CalculateStake.updaterequired = true;

function [startdate,enddate,noofinvestments,handles] = ParseInputs(varargin);
% Parse inputs
varargin = varargin{1};

%compulsory inputs
startdate = varargin{1};
enddate = varargin{2};

%defaults
noofinvestments = 10;

[x] = size(varargin,2);
for i = 3:2:x
   switch lower(varargin{i})
       case 'noofinvestments'
           noofinvestments = varargin{i+1};
       case 'handles'
           handles = varargin{i+1};
       otherwise
           error('optional paramter not recognised');
   end
end