%% ['http://markets.ft.com/tearsheets/analysis.asp?s=',Symbol,'%3ALSE'];
obj.sURL = 'http://www.britishbulls.com/members/Default.aspx?lang=en'; 
obj.eURL = '';
obj.timeout = 2; %2 - only attempted once
Method = 'WQ';

ProgramName = 'BritishBulls';
ResultName = 'ALL_STATUS';
MacroName = 'BritishBulls_ALLSTATUS';

Date = floor(now);
Date = obj.GetStoreDate(Date);

PageList = {''};
        
obj.SaveALL(Method,PageList,ProgramName,ResultName,Date,MacroName);