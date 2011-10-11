function [Status] = DayBestInvestments_MatFcn(varargin);
%The Days Investment Recommendation's
%
%Written by:    Bryan Taylor
%Date Created:  28th October 2007
%Date Modified: 27th December 2007

%% Column Names Declarations
try
if strcmpi(varargin{1},'ColumnNames')
    Status = {  'Symbol'; ...
                'datenum'; ...
                'close'; ...
                'open'; ...
                'low'; ...
                'high'; ...
                'volume'; ...
                'closeadj'; ...
                'PriceMean'; ...
                'PercentageChange'; ...
                'TradeSignal'; ...
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
[Date] = LastWorkingDay(today);
h = varargin{1};
HistSave = false;
try
    Date = varargin{2};
    [Date] = LastWorkingDay(Date);
    HistSave = varargin{3};
    clear h
    global h
    path = 'C:\SourceSafe\Stocks & Shares\Programs\Trade Guide\SaveData\HistoricalDayBestInvestments_Mat\';
end
if HistSave == false
	set(h.Status,'String','Getting Variables. Please Wait...');
	drawnow;
end

InvestedSymbols = [];
[symbolset] = DaySymbolSetMat(Date);
[symbolset] = StockQuoteMatQuery(symbolset,Date); %Parrellel Tasking? 
[symbolset] = DayBestInvestmentsMat(symbolset);

if HistSave == true
    String = [path,'Histroical_',strrep(num2str(Date),'.','_'),'.mat'];
    save(String,'symbolset');
else
    set(h.table,'Data',symbolset);
end

if HistSave == false
    set(h.Status,'String','Ready');
end
Status = 1;

function [Date] = LastWorkingDay(Date)
%
switch datestr(Date,8)
    case 'Mon'
        Date = Date - 3;
    case 'Sun'
        Date = Date - 2;
    otherwise
        Date = Date - 1;
end


