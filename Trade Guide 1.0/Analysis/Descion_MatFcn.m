function [Status] = DescionFcn(varargin);
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

%% Column Names Declarations
try
if strcmpi(varargin{1},'ColumnNames')
    Status = {   'Symbol'; ...
                 'Action'; ...
                 'DateNum'; ...
                 'PriceMean'; ...
             };
    return
end
end

%% Config Declarations
try
if strcmpi(varargin{1},'Config')
   Status = false; 
   return
end
end

%% Functional
[x] = size(varargin,2);
h = varargin{1};
set(h.Status,'String','Getting Variables. Please Wait...');
drawnow;
if x == 1
    disp('Start')
    [startdate,enddate,number_of_investments] = GetNumberOfInvestments();
    Status.number_of_investments = number_of_investments;
    Status.StartDate = startdate;
    Status.EndDate = enddate;
    mindate = startdate;
%     TradeStructure = [];
    InvestedSymbols = [];
elseif x == 2
    disp('Continue')
    Status = varargin{2};
    startdate = Status.StartDate;
    enddate = Status.EndDate;
    mindate = Status.currentdate;
    number_of_investments = Status.number_of_investments;
    InvestedSymbols = Status.InvestedSymbols;
end


for date = mindate:enddate
    % progress update
    Status.PercentageComplete = (date-startdate)/(enddate-startdate)*100;
    set(h.Status,'String',[num2str(Status.PercentageComplete,3),'% Complete'])
    drawnow;
    
    %% If Stop button is pressed. Save all data and exit.
    State = get(h.toolbars.Stop,'State')
    if strcmpi(State,'on')
        Status.currentdate = date;
        Status.InvestedSymbols = InvestedSymbols;
       return
    end
    
    %%SELL
    SellSymbols = DaySellSymbols(InvestedSymbols,date); 
    if not(isempty(SellSymbols))
        [x] = size(SellSymbols,2);
        for i = 1:x
            RowInfo{1,1} = SellSymbols(i).symbol;
            RowInfo{1,2} = SellSymbols(i).action;
            RowInfo{1,3} = SellSymbols(i).datenum;
            RowInfo{1,4} = SellSymbols(i).PriceMean;
            AddRow(RowInfo);
        end
    end

%     %update tradeStructure
%     TradeStructure = [TradeStructure,SellSymbols];

    %remove invested symbols from list
    Sell = Struct2Data(SellSymbols,'symbol');
    InvestedSymbols = removesymbol(InvestedSymbols,Sell);

    %%BUY
    %% Keep Investing Until We have the required number of investments
    [Symbols] = GetDayInvestments(date,InvestedSymbols,number_of_investments);

    if not(isempty(Symbols))
%         TradeStructure = [TradeStructure,Symbols];

        [x] = size(Symbols,2);
        for i = 1:x
            RowInfo{1,1} = Symbols(i).symbol;
            RowInfo{1,2} = Symbols(i).action;
            RowInfo{1,3} = Symbols(i).datenum;
            RowInfo{1,4} = Symbols(i).PriceMean;
            AddRow(RowInfo);
        end

        %note invested symbols
        InvestedSymbols = [InvestedSymbols;Struct2Data(Symbols,'symbol')];
    end
end

function [startdate,enddate,NumberOfInvestments] = GetNumberOfInvestments()
%Written by:    Bryan Taylor
%Date Created:  30th April 2008
prompt={'Start Date:','End Date:','Number Of Investments'};
name='Inputs for Decsion function';
numlines=1;
[enddate] = GetResult('NoOfSymbolsPerDay_Mat','EndDate');
[startdate] = GetResult('NoOfSymbolsPerDay_Mat','StartDate');
defaultanswer={datestr(startdate),datestr(enddate),num2str(10)};
answer=inputdlg(prompt,name,numlines,defaultanswer);
drawnow;
startdate = datenum(answer{1});
enddate = datenum(answer{2});
NumberOfInvestments = str2num(answer{3});