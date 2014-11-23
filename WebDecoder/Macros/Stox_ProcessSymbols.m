%% Vars
jobName = 'Stox SymbolList Decode';
jenkinsRoot = '/var/lib/jenkins/jobs/';

%% Paths
workspace = [jenkinsRoot,jobName,'/workspace'];

%%
Symbols = obj.GetSavedSymbolsFromPath([workspace,'/URL_Download/Results']);

%%
load([workspace,'/URL_Download/Results/',Symbols,'.mat'])
obj.DecodeTable_OBJ.s = s;
obj.DecodeTable_OBJ.RUN();
obj.Table
% %%
% try
% save([workspace,'/WebDecoder/Results/DecodedDATASET.mat'],'DATASET')
% catch
% mkdir([workspace,'/WebDecoder/Results/']) 
% save([workspace,'/WebDecoder/Results/DecodedDATASET.mat'],'DATASET')
% end