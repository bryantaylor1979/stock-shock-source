%% Vars
jobName = 'BritishBulls Decode';
jenkinsRoot = '/var/lib/jenkins/jobs/';

%% Paths
workspace = [jenkinsRoot,jobName,'/workspace'];
Symbols = obj.GetSavedSymbolsFromPath([workspace,'/URL_Download/Results']);
CE_DataSet = obj.BB_Hist.Hist_URL2Data_Sync(Symbols,floor(now));

%%
try
save([workspace,'/WebDecoder/Results/DecodedDATASET.mat'],'CE_DataSet')
catch
mkdir([workspace,'/WebDecoder/Results/']) 
save([workspace,'/WebDecoder/Results/DecodedDATASET.mat'],'CE_DataSet')
end