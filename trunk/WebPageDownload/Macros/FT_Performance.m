%% url = ['http://markets.ft.com/tearsheets/performance.asp?s=',Symbol,'%3ALSE'];
obj.sURL = 'http://markets.ft.com/tearsheets/performance.asp?s='; 
obj.eURL = '%3ALSE';
obj.timeout = 2;
Method = 'URL';

ProgramName = 'FinicialTimes';
ResultName = 'Performance';
MacroName = 'FT_Performance';

Date = floor(now);
Date = obj.GetStoreDate(Date);

Symbols = obj.GetRequiredSymbols(ProgramName,ResultName,Date);
obj.SaveALL(Method,Symbols,ProgramName,ResultName,Date,MacroName);