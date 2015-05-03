
obj.sURL = 'http://www.nakedtrader.co.uk/';
obj.eURL = '';
obj.timeout = 8;
Method = 'URL';

obj.timeout = 2; %2 - only attempted once

ProgramName = 'NakedTrader';
ResultName = 'Shares';
MacroName = 'NakedTrader';

Date = floor(now);
Date = obj.GetStoreDate(Date);

Symbols = { 'agree.htm?agree=1'; ...
            'trades.htm?type=sh' ; ...
            'trades.htm?type=sbs'; ...
            'trades.htm?type=sbl'};
        
obj.SaveALL(Method,Symbols,ProgramName,ResultName,Date,MacroName);