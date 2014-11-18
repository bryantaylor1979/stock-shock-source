%%
obj.sURL = 'http://uk.stoxline.com/q_uk.php?s='; 
obj.eURL = '';
obj.timeout = 2;

%Symbols = obj.GetRequiredSymbols(ProgramName,ResultName,Date);
Symbols = obj.SymbolInfo_OBJ.SymbolList();
obj.DownloadAllURL('',Symbols,'','',1,'');