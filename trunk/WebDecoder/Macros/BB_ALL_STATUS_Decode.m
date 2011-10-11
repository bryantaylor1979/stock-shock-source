ProgramName = 'BritishBulls';
ResultName = 'ALL_STATUS';
Date = today - 1;

%%
obj.URL_2_WQ(ProgramName,ResultName,Date);

%%
Symbols = obj.GetURL_Symbols(ProgramName,ResultName,Date);
DATASET = obj.ProcessDay_Macro(Symbols,ProgramName,ResultName,'BB_ALLSTATUS_ProcessPage',Date);

%%
DATASET = obj.BB_ALLSTATUS.SectorHeading2DatasetColumn(DATASET);           
obj.SaveDataSet(DATASET,ProgramName,ResultName,Date);