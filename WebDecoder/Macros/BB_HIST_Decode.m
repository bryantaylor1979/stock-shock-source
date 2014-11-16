%% Vars
jobName = 'BritishBulls Decode';
jenkinsRoot = '/var/lib/jenkins/jobs/';

%% Paths
workspace = [jenkinsRoot,jobName,'/workspace'];
Symbols = obj.GetSavedSymbolsFromPath([workspace,'/URL_Download/Results']);
obj.BB_Hist.URL2Table_ALL(Symbols,[workspace,'/URL_Download/Results'],[workspace,'/WebDecoder/Results/']);