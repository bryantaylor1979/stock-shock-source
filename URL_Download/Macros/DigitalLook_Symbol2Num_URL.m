%% 
obj.sURL = 'http://www.digitallook.com/companysearch.cgi?select=dl&primary=y&keyword_begins=y&username=&ac=&advanced=&name=';
obj.eURL = '&stock_exchange=All+Markets';
obj.timeout = 2;
Method = 'URL';

obj.timeout = 2; %2 - only attempted once

ProgramName = 'DigitalLook';
ResultName = 'Symbol2Num';
MacroName = 'DigitalLook_Symbol2Num_URL';

Date = floor(now);
Date = obj.GetStoreDate(Date);

% Should use BB ALL_STATUS Symbol Set. 
Symbols = obj.GetRequiredSymbols(ProgramName,ResultName,Date);
        
obj.SaveALL(Method,Symbols,ProgramName,ResultName,Date,MacroName);