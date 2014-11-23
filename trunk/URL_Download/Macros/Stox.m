%% Vars
jobName = 'Stox Download';
jenkinsRoot = '/var/lib/jenkins/jobs/';

%% Paths
workspace = [jenkinsRoot,jobName,'/workspace'];

%%
obj.sURL = 'http://uk.stoxline.com/q_uk.php?s='; 
obj.eURL = '';
obj.timeout = 2; %number of attempt when exit.
obj.Method = 'url2'; % url, url2, wq, xml
obj.t1 = 6000; 

%Symbols = obj.GetRequiredSymbols(ProgramName,ResultName,Date);
%Symbols = obj.SymbolInfo_OBJ.SymbolList();
load([workspace,'/WebDecoder/Results/SymbolList.mat']) 
Symbols = DATASET(:,1)
obj.DownloadAllURL(Symbols,'','',1,'');