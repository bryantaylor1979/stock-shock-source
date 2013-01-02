%% ['http://markets.ft.com/tearsheets/analysis.asp?s=',Symbol,'%3ALSE'];

obj.sURL = 'http://www.advfn.com/p.php?pid=financials&symbol=LSE%3A'; 
obj.eURL = '';
Method = 'URL';
obj.timeout = 2;

ProgramName = 'ADVFN';
ResultName = 'Finacials';
MacroName = 'ADVFN_URL_CompanyInfo';

Date = floor(now);
Date = obj.GetStoreDate(Date);

Symbols = obj.GetRequiredSymbols(ProgramName,ResultName,Date);
obj.SaveALL(Method,Symbols,ProgramName,ResultName,Date,MacroName);