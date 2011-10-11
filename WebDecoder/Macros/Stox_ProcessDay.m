%%
ProgramName = 'Stox';
ResultName = 'Best_Investments';
if not(exist('Date')), Date = today;,  Date = obj.GetStoreDate(Date);, end
% 
Symbol = obj.GetURL_Symbols(ProgramName,ResultName,Date);
struct = obj.GetConfig2('Stox');
[DATASET, N_ErrorSymbols] = obj.DecodeALL(struct,'URL',Symbol,ProgramName,ResultName,Date);

DATASET = [dataset(Symbol),DATASET];
DATASET = obj.Stox.Signal(DATASET);
DATASET = obj.Stox.StarRating(DATASET);
DATASET = obj.Stox.Star(DATASET);

obj.SaveDataSet(DATASET,ProgramName,ResultName,Date);
% obj.DataSet2xls(DATASET, [obj.InstallDir,'Results\',Folder,'\xls\',datestr(Date,1),'.xls']);
% obj.DataSet2csv(DATASET,[obj.InstallDir,'Results\',Folder,'\stoxlinebestpick.csv']);
% obj.SendFtp([obj.InstallDir,'Results\',Folder,'\stoxlinebestpick.csv'],'httpdocs/Stox/','wfoote.com','shares','cormorant');