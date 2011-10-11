obj.sURL = 'http://www.iii.co.uk/rss/news/cotn:'; 
obj.eURL = '.L.xml';
obj.timeout = 2;
Method = 'URL';

ProgramName = 'NewsAlerts';
ResultName = 'RNS';
MacroName = 'NewsAlerts_RNS';

Date = today;
Date = obj.GetStoreDate(Date);

Symbols = obj.GetRequiredSymbols(ProgramName,ResultName,Date);
obj.SaveALL(Method,Symbols,ProgramName,ResultName,Date,MacroName);
