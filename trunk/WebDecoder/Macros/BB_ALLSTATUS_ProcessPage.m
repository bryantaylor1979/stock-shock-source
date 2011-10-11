%%
% DataSet = obj.WQ_DecodeALL(ProgramName,MacroName,Date,tableloc,tableclasses);
% Symbol = 'BasicMaterials';
% Date = today-1;

ProgramName = 'BritishBulls';
ResultName = 'ALL_STATUS';

[wq, Error] = obj.LoadResult_Type(ProgramName,ResultName,Symbol,Date,'WQ');


struct.ColumnName_Row = 4;
struct.ColumnName_Range = [3:12];
struct.End_Row = 2; %Number of rows removed at end


[Table,ColumnNames] = obj.TableCrop(wq,struct) %OR [Headings,Data] = obj.GetTableArray(raw,struct);
DATASET = obj.Table2DataSet(Table,ColumnNames);
