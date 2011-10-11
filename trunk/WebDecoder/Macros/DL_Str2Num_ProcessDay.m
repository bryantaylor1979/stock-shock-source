%% Settings
ProgramName = 'DigitalLook';
ResultName = 'Symbol2Num';
Date = today-1;
struct.TableStart   = 'class="searchTable">';
struct.TableEnd     = '</table>';
struct.RowStart     = '<tr>';
struct.RowEnd       = '</tr>';
struct.CellStart    = '<t';
struct.CellEnd      =  '</t';
struct.CellEndT     = '/>';
 
%%
Date = obj.GetStoreDate(Date);
Symbols = obj.GetSaveType_Symbols('URL',ProgramName,ResultName,Date);
obj.ProcessTable_Single(struct,Symbols,ProgramName,ResultName,Date);

%%
Symbols = obj.GetSaveType_Symbols('TABLE',ProgramName,ResultName,Date);
[DATASET] = obj.DL_Sym2Num.ProcessALL(ProgramName,ResultName,Symbols,Date);
obj.SaveDataSet(DATASET,ProgramName,ResultName,Date);