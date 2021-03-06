function [Output] = DatabaseViewerFcn(varargin)
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
conn = database('SaxoTrader','','');

Value = get(h.DatabaseViewer.pulldown,'Value');
String = get(h.DatabaseViewer.pulldown,'String');
symbol = String{Value};
sqlstatement = ['SELECT ALL datenum,close,open,low,high,volume,closeadj,PriceMean,PercentageChange,TradeSignal FROM ',symbol,' ORDER BY datenum ASC'];

curs=exec(conn, sqlstatement);
curs=fetch(curs);
Data = curs.Data;
try
% [DataOut] = Array2Java(Data);
set(h.table,'Data',Data);
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