%%
Date = today-1;

ProgramName = 'BritishBulls';
MacroName = 'CurrentEvent';
Symbol = 'HAWK';

%%
Symbols = obj.GetSaveType_Symbols('URL',   ProgramName,   MacroName, Date);
CE_DataSet = obj.BB_Hist.Hist_URL2Data_Sync(Symbols,Date);
obj.SaveDataSet(CE_DataSet,ProgramName,MacroName,Date);