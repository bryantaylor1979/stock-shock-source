function [] = IntialiseTable(Names)
% Intialise Table
global h   

vs = version;

if strcmpi(vs,'7.6.0.324 (R2008a)')
    set(h.table,'ColumnName',Names);
else
    set(h.table,'NumRows',0);
    set(h.table,'NumRows',1);

    [x] = size(Names,1);
    set(h.table,'ColumnNames',Names);
    set(h.table,'NumColumns',x);
    set(h.table,'NumRows',1);
    Table = get(h.table,'Table');
    set(Table,'CellViewerEnabled','off');
    set(Table,'rowSelectionAllowed','on');
    drawnow;
end