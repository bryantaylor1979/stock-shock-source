%% Trying to decode british bulls without the web query

%% Settings
Page = 'BasicMaterials';
Date = today-1;

%%
ProgramName = 'BritishBulls';
ResultName = 'ALL_STATUS';
disp(Page)

%%
[s, Error] = obj.LoadResult_Type(ProgramName,ResultName,Page,Date,'URL');
%
IN_struct.TableStart   = '<table width="940" valign=top border="0" cellpadding="0" cellspacing="0" bordercolor="green">';
IN_struct.TableEnd     = ' <td><strong><font color="#FFFFFF">Disclaimer</font></strong></td>';
IN_struct.RowStart     = '<td align="left"><font size=1>   <b>';
IN_struct.RowEnd       = '<tr align=right>';
IN_struct.CellStart    = '<td';
IN_struct.CellEnd      = '</td>';
IN_struct.CellEndT     = '/>';
Table = obj.DecodeTable(s,IN_struct)