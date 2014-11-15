%% Vars
jobName = 'Stox Decode';
jenkinsRoot = '/var/lib/jenkins/jobs/';

%% Paths
workspace = [jenkinsRoot,jobName,'/workspace'];

%%
Symbols = obj.GetSavedSymbolsFromPath([workspace,'/URL_Download/Results']);
struct = obj.GetConfig2('Stox');

%%
[DATASET, N_ErrorSymbols] = obj.DecodeALL_Jenkins(struct,[workspace,'/URL_Download/Results'],Symbols);

%%
DATASET = obj.Stox.StarRating(DATASET);
DATASET = obj.Stox.Signal(DATASET);
DATASET = obj.Stox.Stars(DATASET);

%%
try
save([workspace,'/WebDecoder/Results/DecodedDATASET.mat'],'DATASET')
catch
mkdir([workspace,'/WebDecoder/Results/']) 
save([workspace,'/WebDecoder/Results/DecodedDATASET.mat'],'DATASET')
end

%%
% obj.SaveDataSet(DATASET,ProgramName,ResultName,Date);
% obj.DataSet2xls(DATASET, [obj.InstallDir,'Results\',Folder,'\xls\',datestr(Date,1),'.xls']);
% obj.DataSet2csv(DATASET,[obj.InstallDir,'Results\',Folder,'\stoxlinebestpick.csv']);
% obj.SendFtp([obj.InstallDir,'Results\',Folder,'\stoxlinebestpick.csv'],'httpdocs/Stox/','wfoote.com','shares','cormorant');