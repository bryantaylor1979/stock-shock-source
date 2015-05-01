% %%
% obj.timeout = 2; %2 - only attempted once
% Method = 'WQ';
% ProgramName = 'BritishBulls';
% ResultName = 'ALL_STATUS';
% MacroName = 'BritishBulls_ALLSTATUS';
url =  'https://www.britishbulls.com/members/Default.aspx?lang=en'; 
[s,Error] = download(url)
