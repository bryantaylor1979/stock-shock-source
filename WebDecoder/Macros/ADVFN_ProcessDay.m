%%
ProgramName = 'ADVFN';
ResultName = 'Finacials';
% Date = today;
% Date = obj.GetStoreDate(Date);
Date = today;
struct = obj.GetConfig2(ProgramName);
obj.ProcessSingle(struct,ProgramName,ResultName,Date);