%% ['http://markets.ft.com/tearsheets/analysis.asp?s=',Symbol,'%3ALSE'];
obj.sURL = 'http://www.shareprice.co.uk/'; 
obj.eURL = '';
obj.timeout = 2;
Method = 'URL';

ProgramName = 'SharePrice';
ResultName = 'Summary';
MacroName = 'SharePrice_Summary';

Date = today;
Date = obj.GetStoreDate(Date);

Symbols = obj.GetRequiredSymbols(ProgramName,ResultName,Date);
obj.SaveALL(Method,Symbols,ProgramName,ResultName,Date,MacroName);