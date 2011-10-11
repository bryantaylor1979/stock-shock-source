function [CurrentSymbolList] = GetCurrentSymbolList();

%% Get all currently recognised symbols
conn = database('Stocks','','');
[CurrentSymbolList] = GetAllTableNames(conn);