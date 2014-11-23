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
    file = [workspace,'/URL_Download/Results/',Symbols{i},'.mat'];
    load(file)
    obj.DecodeTable_OBJ.s = s;
    obj.DecodeTable_OBJ.RUN();
    if i == 1
        DATASET = obj.DecodeTable_OBJ.Table;
    else
        DATASET = [DATASET;obj.DecodeTable_OBJ.Table];  
    end
end
%%
try
save([workspace,'/WebDecoder/Results/SymbolSet.mat'],'DATASET')
catch
mkdir([workspace,'/WebDecoder/Results/']) 
save([workspace,'/WebDecoder/Results/SymbolSet.mat'],'DATASET')
end