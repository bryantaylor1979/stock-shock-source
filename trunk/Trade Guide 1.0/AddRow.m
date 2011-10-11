function [] = AddRow(RowInfo)
% Add row to table

Vs = version;
global h 

if not(strcmpi(Vs,'7.0.0.19920 (R14)'));
    Data = get(h.table,'Data');
    Data = [Data;RowInfo];
    set(h.table,'Data',Data);
    drawnow;
else
    % Add row to table
    JavaObject = get(h.table,'Data');
    Table = get(h.table,'Table');
    RowCount = get(Table,'RowCount');
    String = JavaObject(RowCount,1);

    if not(strcmp(String,''))
        [x] = size(JavaObject,1);
        JavaObject(2:x+1,:) = JavaObject(:,:);
    end

    [x] = size(RowInfo,2);
    for i = 1:x
        if ischar(RowInfo{i})     
        else
            RowInfo{i} = num2str(RowInfo{i});
        end
        JavaObject(1,i) = java.lang.String(RowInfo{i}); 
    end
    set(h.table,'Data',JavaObject);
    drawnow;
end