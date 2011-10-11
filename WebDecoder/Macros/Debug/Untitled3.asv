ProgramName = 'Stox';
ResultName = 'Best_Investments';
Date = datenum('14_Jun_2011');
% Load URL
s = obj.LoadURLs(ProgramName,ResultName,N_ErrorSymbols{7},Date);
%%
s= obj.GetURL('Stox','ZYT_14_June_2011'); 

%%
struct = obj.GetConfig('stox','Decoder');
struct = struct(23)
outStruct = obj.DecodeURL(s,struct);