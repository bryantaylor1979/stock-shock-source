%% 
obj.sURL = 'http://uk.stoxline.com/symbols.php?fl='; 
obj.eURL = '';
obj.timeout = 2; %number of attempt when exit.
obj.Method = 'url2'; % url, url2, wq, xml
obj.t1 = 6000; 

%% Symbols = obj.GetRequiredSymbols(ProgramName,ResultName,Date);
Symbols = { 'A';'B';'C';'D';'E';'F';'G';'H';'I';'J';'K';'L'; ...
            'M';'N';'O';'P';'Q';'R';'S';'T';'U';'V';'W'; ...
            'X';'Y';'Z'};   
%%
obj.DownloadAllURL(Symbols,'','',1,'');