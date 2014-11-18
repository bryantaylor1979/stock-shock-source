%%
obj.sURL = 'http://uk.stoxline.com/q_uk.php?s='; 
obj.eURL = '';
obj.timeout = 2; %number of attempt when exit.
obj.Method = 'url'; % url, url2, wq, xml

%Symbols = obj.GetRequiredSymbols(ProgramName,ResultName,Date);
Symbols = obj.SymbolInfo_OBJ.SymbolList();
obj.DownloadAllURL(Symbols,'','',1,'');