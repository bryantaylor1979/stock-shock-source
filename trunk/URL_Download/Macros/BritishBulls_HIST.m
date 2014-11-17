%% ['http://markets.ft.com/tearsheets/analysis.asp?s=',Symbol,'%3ALSE'];
obj.sURL = 'http://www.britishbulls.com/SignalPage.aspx?lang=en&Ticker=';
obj.eURL = '.L';
obj.timeout = 2;
Method = 'URL';

obj.timeout = 2; %2 - only attempted once

ProgramName = 'BritishBulls';
ResultName = 'CurrentEvent';
MacroName = 'BritishBulls_HIST';

Date = floor(now);
Date = obj.GetStoreDate(Date);

% Should use BB ALL_STATUS Symbol Set. 
%Symbols = obj.GetRequiredSymbols(ProgramName,ResultName,Date);
[Data] = obj.III_IndexMap;
Symbols = Data(:,2);      
obj.SaveALL(Method,Symbols(1:10),ProgramName,ResultName,Date,MacroName);

