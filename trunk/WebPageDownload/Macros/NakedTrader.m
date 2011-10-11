
obj.sURL = 'http://www.nakedtrader.co.uk/trades.htm?type=';
obj.eURL = '';
obj.timeout = 8;
Method = 'URL';

obj.timeout = 2; %2 - only attempted once

ProgramName = 'NakedTrader';
ResultName = 'Shares';
MacroName = 'NakedTrader';

Date = today;
Date = obj.GetStoreDate(Date);

Symbols = { 'sh' ; ...
            'sbs'; ...
            'sbl'};
        
obj.SaveALL(Method,Symbols,ProgramName,ResultName,Date,MacroName);