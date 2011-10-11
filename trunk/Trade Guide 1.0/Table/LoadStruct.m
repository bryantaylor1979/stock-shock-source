%% functions
function [] = LoadStruct(h,TradeStructure)

% set(h.button,'Enable','off');
drawnow;

[NoOfEntries] = size(TradeStructure,2);
Names = fieldnames(TradeStructure);
NoOfAttributes = size(Names,1);
set(h.table,'ColumnName',Names);

Data = struct2cell(TradeStructure);
Data2 = rot90(reshape(Data(:,1,:),NoOfAttributes,NoOfEntries));

set(h.table,'Data',Data2);
% set(h.button,'Enable','on');
drawnow;