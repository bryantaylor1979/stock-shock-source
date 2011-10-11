function [Output] = DatabaseViewer_MatFcn(varargin)
%Calculate Parameters
%
%Written by:    Bryan Taylor
%Date Created:  12th August 2008
%Date Modified: 12th August 2008

Mode = 'fastupdate'; %or update

%% Column Name Declaration
try
if strcmpi(varargin{1},'ColumnNames')
    load CalcSetting CalcSetting
    Output = {  'datenum'; ...
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
   Output = false; 
   return
end
end

global conn h

Value = get(h.DatabaseViewer.pulldown,'Value');
String = get(h.DatabaseViewer.pulldown,'String');
symbol = String{Value};

path = 'C:\SourceSafe\Stocks & Shares\Programs\Trade Guide\SaveData\Download_Mat\Database\';

if strcmpi(symbol,'N/A')
    
else
    load([path,symbol,'.mat'])
    try
    % [DataOut] = Array2Java(Data);
    set(h.table,'Data',DataStore);
    end
end
Output = 1;

function [DataOut] = Array2Java(DataIn)
%Written by:    Bryan Taylor
%Date Created:  Bryan Taylor

[x,y] = size(DataIn);
for i = 1:x
    for i = 1:y
        Value = DataIn{i,j};
        if isnumeric(Value)
            JavaObject(i,j) = java.lang.Double(DataIn{i,j});
        elseif ischar(Value)
            JavaObject(i,j) = java.lang.String(DataIn{i,j});
        else
            error('Java Class not recognised'); 
        end
    end
end