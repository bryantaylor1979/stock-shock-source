%% Vars
jobName = 'Stox SymbolList Decode';
jenkinsRoot = '/var/lib/jenkins/jobs/';

%% Paths
workspace = [jenkinsRoot,jobName,'/workspace'];

%%
Symbols = obj.GetSavedSymbolsFromPath([workspace,'/URL_Download/Results']);

%%
x = max(size(Symbols));
for i = 1:x
    file = [workspace,'/URL_Download/Results/',Symbols{1},'.mat'];
    load(file)
    obj.DecodeTable_OBJ.s = s;
    obj.DecodeTable_OBJ.RUN();
    if i == 1
        Table = obj.DecodeTable_OBJ.Table;
    else
        Table = [Table;obj.DecodeTable_OBJ.Table];  
    end
end
Table
% %%
% try
% save([workspace,'/WebDecoder/Results/DecodedDATASET.mat'],'DATASET')
% catch
% mkdir([workspace,'/WebDecoder/Results/']) 
% save([workspace,'/WebDecoder/Results/DecodedDATASET.mat'],'DATASET')
% end