%% ['http://markets.ft.com/tearsheets/analysis.asp?s=',Symbol,'%3ALSE'];
obj.sURL = 'http://www.britishbulls.com/StockPage.asp?CompanyTicker=';
obj.eURL = '&MarketTicker=Financials&Typ=S';
obj.timeout = 2;
Method = 'URL';

obj.timeout = 2; %2 - only attempted once

ProgramName = 'BritishBulls';
ResultName = 'CurrentEvent';
MacroName = 'BritishBulls_HIST';

Date = today;
Date = obj.GetStoreDate(Date);

% Should use BB ALL_STATUS Symbol Set. 
Symbols = obj.GetRequiredSymbols(ProgramName,ResultName,Date);
        
obj.SaveALL(Method,Symbols,ProgramName,ResultName,Date,MacroName);

