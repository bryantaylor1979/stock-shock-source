function [TableNames] = GetAllTableNamesMat()
%Written by:    Bryan Taylor
%Date Created:  24th August 2008
Symbol = GetStageData('VerfiyYahoo','Yahoo Symbol');
SymbolUnkown = GetStageData('VerfiyYahoo','SymbolUnknown');

n = find(strcmpi(SymbolUnkown,'False'));
TableNames = Symbol(n);