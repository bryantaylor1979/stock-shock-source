%%
obj.sURL = 'http://uk.stoxline.com/q_uk.php?s='; 
obj.eURL = '';
obj.timeout = 2;
Method = 'URL';

ProgramName = 'Stox';
ResultName = 'Best_Investments';
MacroName = 'Stox';

Date = floor(now);
Date = obj.GetStoreDate(Date);

Symbols = obj.GetRequiredSymbols(ProgramName,ResultName,Date);
obj.SaveALL(Method,Symbols,ProgramName,ResultName,Date,MacroName);