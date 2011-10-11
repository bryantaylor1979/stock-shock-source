function [Status] = DescionFcn(varargin);
%% Column Names Declarations
try
if strcmpi(varargin{1},'ColumnNames')
    Status = {   'Symbol'; ...
                 'Action'; ...
                 'DateNum'; ...
                 'PriceMean'; ...
                 'Close'; ...
                 'NextDayOpen'; ...
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
global h
[Symbol] = GetStageData('Descion','Symbol');
[Action] = GetStageData('Descion','Action');
[DateNum] = GetStageData('Descion','DateNum');
[PriceMean] = GetStageData('Descion','PriceMean');

[x] = size(Symbol,1);

for i = 1:x-1
    % Progress
    Status.PercentageComplete = i/(x-1)*100;
    set(h.Status,'String',[num2str(Status.PercentageComplete,3),'% Complete'])
    
    % Get new data
    [Date,pricemean,Open,Close] = StockQuote(Symbol(i),{'datenum';'pricemean';'open';'close'},[str2num(DateNum(i))]);
    
    % Add row
    RowInfo{1,1} = Symbol(i);
    RowInfo{1,2} = Action(i);
    RowInfo{1,3} = DateNum(i);
    RowInfo{1,4} = PriceMean(i);
    RowInfo{1,5} = Close{1};
    RowInfo{1,6} = Close{1}; 
    AddRow(RowInfo);
end
set(h.Status,'String',['Ready']);
Status = 1;