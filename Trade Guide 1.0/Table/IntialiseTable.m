function [] = IntialiseTable(Names)
% Intialise Table
global h   


% set(h.table,'NumRows',0);
% set(h.table,'NumRows',1);

[x] = size(Names,1);
set(h.table,'ColumnName',Names);
set(h.table,'Data',[]);
% set(Table,'CellViewerEnabled','off');
% set(Table,'rowSelectionAllowed','on');
drawnow;