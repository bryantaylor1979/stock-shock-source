%% Settings
Symbol = 'HAWK';
Date = today;
struct.TableStart   = 'class="searchTable">';
struct.TableEnd     = '</table>';
struct.RowStart     = '<tr>';
struct.RowEnd       = '</tr>';
struct.CellStart    = '<t';
struct.CellEnd      =  '</t';
struct.CellEndT     = '/>';
 
%%
[s, Error] = obj.LoadResult_Type('DigitalLook','Symbol2Num',Symbol,Date,'URL');
Table = obj.DecodeTable(s,struct);