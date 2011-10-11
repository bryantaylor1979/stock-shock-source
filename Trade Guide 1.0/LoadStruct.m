%% functions
function [] = LoadStruct(h,TradeStructure)

% set(h.button,'Enable','off');
drawnow;
vs = version;

[NoOfEntries] = size(TradeStructure,2);
Names = fieldnames(TradeStructure);
NoOfAttributes = size(Names,1);

if strcmpi(vs,'7.6.0.324 (R2008a)')
set(h.table,'ColumnName',Names);    
else
set(h.table,'ColumnNames',Names);
end

drawnow;
h1 = waitbar(0,'Building Table Array. Please Wait...');
JavaObject = get(h.table,'Data');
for i = 1:NoOfEntries
    waitbar(i/NoOfEntries,h1);
    for j = 1:NoOfAttributes
        Val = getfield(TradeStructure,{i},Names{j});
        if strcmpi(vs,'7.6.0.324 (R2008a)')
            JavaObject{i,j} = Val;
        else
            if not(ischar(Val))
                % round to the nearest interger
                Val = round(Val*100)/100;
                JavaObject(i,j) = java.lang.Double(Val);
            else
                JavaObject(i,j) = java.lang.String(Val);
            end
        end
    end
    drawnow;
end
close(h1);

set(h.table,'Data',JavaObject);
% set(h.button,'Enable','on');
drawnow;