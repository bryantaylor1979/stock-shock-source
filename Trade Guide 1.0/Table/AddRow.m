function [] = AddRow(RowInfo)
% Add row to table
global h count
Data = get(h.table,'Data');
% Table = get(h.table,'Table');
% RowCount = get(Table,'RowCount');
% String = JavaObject(RowCount,1);

% if not(strcmp(String,''))
%     [x] = size(JavaObject,1);
%     JavaObject(2:x+1,:) = JavaObject(:,:);
% end

Data = [Data;RowInfo];
set(h.table,'Data',Data);
drawnow;