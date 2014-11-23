%% Vars
jobName = 'Stox SymbolList Decode';
jenkinsRoot = '/var/lib/jenkins/jobs/';

%% Paths
workspace = [jenkinsRoot,jobName,'/workspace'];

%%
Symbols = obj.GetSavedSymbolsFromPath([workspace,'/URL_Download/Results']);

%%
file = [workspace,'/URL_Download/Results/',Symbols{1},'.mat'];
load(file)
obj.DecodeTable_OBJ.s = s;
obj.DecodeTable_OBJ.RUN();
obj.DecodeTable_OBJ.Table
% %%
% try
% save([workspace,'/WebDecoder/Results/DecodedDATASET.mat'],'DATASET')
% catch
% mkdir([workspace,'/WebDecoder/Results/']) 
% save([workspace,'/WebDecoder/Results/DecodedDATASET.mat'],'DATASET')
% end