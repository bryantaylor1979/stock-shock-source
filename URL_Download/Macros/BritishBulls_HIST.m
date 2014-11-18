%% ['http://markets.ft.com/tearsheets/analysis.asp?s=',Symbol,'%3ALSE'];
obj.sURL = 'http://www.britishbulls.com/SignalPage.aspx?lang=en&Ticker=';
obj.eURL = '.L';
obj.timeout = 2; %number of attempt when exit.
obj.Method = 'url'; % url, url2, wq, xml

%Symbols = obj.GetRequiredSymbols(ProgramName,ResultName,Date);
Symbols = obj.SymbolInfo_OBJ.SymbolList(); 
obj.DownloadAllURL(Symbols,'','',1,'');