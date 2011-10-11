%% ['http://markets.ft.com/tearsheets/analysis.asp?s=',Symbol,'%3ALSE'];
obj.sURL = 'http://markets.ft.com/tearsheets/analysis.asp?s='; 
obj.eURL = '%3ALSE';
obj.timeout = 2;
Method = 'URL';

ProgramName = 'FinicialTimes';
ResultName = 'Analysis';
MacroName = 'FT_Analysis';

Date = today;
Date = obj.GetStoreDate(Date);

Symbols = obj.GetRequiredSymbols(ProgramName,ResultName,Date);
obj.SaveALL(Method,Symbols,ProgramName,ResultName,Date,MacroName);