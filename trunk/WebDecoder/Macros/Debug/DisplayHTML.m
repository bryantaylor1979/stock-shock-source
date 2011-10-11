ProgramName = 'Stox';
ResultName = 'Best_Investments';
Date = datenum('14_Jun_2011');
% Load URL
s = obj.LoadURLs(ProgramName,ResultName,'ZYT',Date);

%
Path = [obj.InstallDir,'temp.html']
obj.DisplayHTML(s,Path)

%% Decode
struct = obj.GetConfig(ProgramName,'Decoder');
outStruct = obj.DecodeURL(s,struct); 
N_DATASET = obj.Struct2DataSet(outStruct);