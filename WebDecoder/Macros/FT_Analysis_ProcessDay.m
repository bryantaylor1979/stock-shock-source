%%
ProgramName = 'FinicialTimes';
ResultName = 'Performance';
Symbols = obj.GetURL_Symbols(ProgramName,ResultName,Date);
DATASET = obj.ProcessDay_Macro(Symbols,ProgramName,ResultName,'FT_Analysis_ProcessPage',today-1);
DATASET = obj.Add_Signal(DATASET);
DATASET = obj.Add_Targets(DATASET);
close(gcf)