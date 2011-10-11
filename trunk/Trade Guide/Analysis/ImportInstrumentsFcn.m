function [Output] = ImportInstrumentsFcn(varargin)
%
%Written by:    Bryan Taylor
%Date Created:  13th June 2008
%Date Modified  13th June 2008

%% Column Name Declaration
try
if strcmpi(varargin{1},'ColumnNames')
    Output = {  'SaxoSymbol'; ...
                'SaxoCategory'; ...
                'SaxoType'; ...
                'Suffix'; ...
                'ExchangeName'; ...
                'Country'; ...
                'Delay'; ...
                'Source'; ...
                'YahooSymbol'; ...
                'LocalSymbol'; ...
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

%% Functional
global h

set(h.Status,'String',['Reading Instruments. Please Wait']);
drawnow;
[symbols,Category,Type] = ReadInstruments('Shares');
% conn = yahoo;
% profile = '(symbol TEXT, datenum NUMBER, close NUMBER, open NUMBER, low NUMBER, high NUMBER, volume NUMBER, closeadj NUMBER)';

%% Functional

[x] = size(symbols,1);
SaxoCategory = '';
SaxoType = '';

for i = 1:x
    Status.PercentageComplete = i/x*100;
    set(h.Status,'String',[num2str(Status.PercentageComplete,3),'% Complete'])

    %Summary of Event
    TradeStructure(i).symbols = symbols{i};
    TradeStructure(i).SaxoCategory = Category{i};
    TradeStructure(i).SaxoType = Type{i};
    
    try
        [output] = TickerSymbolSuffixLookup('SaxoSymbol',Category{i});
        TradeStructure(i).Suffix = output.Suffix;
        TradeStructure(i).ExchangeName = output.ExchangeName;
        TradeStructure(i).Country = output.Country;
        TradeStructure(i).Delay = output.Delay;
        TradeStructure(i).Source = output.Source;
        if strcmpi(output.Suffix,'')
            TradeStructure(i).YahooSymbol = symbols{i};
        else
            TradeStructure(i).YahooSymbol = [symbols{i},'.',output.Suffix];
        end
        [TradeStructure(i).LocalSymbol] = RemoveIlegallyChar(TradeStructure(i).YahooSymbol);
    catch
        TradeStructure(i).Suffix = 'N/A';
        TradeStructure(i).ExchangeName = 'N/A';
        TradeStructure(i).Country = 'N/A';
        TradeStructure(i).Delay = 'N/A';
        TradeStructure(i).Source = 'N/A'; 
        TradeStructure(i).YahooSymbol = 'N/A';
        TradeStructure(i).LocalSymbol = 'N/A';
    end
end
LoadStruct(h,TradeStructure);
set(h.Status,'String','Ready');
% AddRow(RowInfo);
Output.dummy = 1;

function [symbol] = RemoveIlegallyChar(symbol)
%
%Written by:    Bryan Taylor
%Date Created:  25th June 2008
symbol = strrep(symbol,'-','__');
symbol = strrep(symbol,'.','_');
