function [s] = StructureQuote(Symbol,Date);
%This function returns an structured array with ALL field found in the
%database
%
%Create a structure of that days information
%This function should adaptive create a structure based on the available
%fields.
%Only one date can be specified but mulitple symbols
%
%Example:
%[s] = StructureQuote({'AA';'ASA'},today-120)
[y] = size(Symbol,1);
h = waitbar(0,'building structure');
for j = 1:y
    waitbar(j/y,h);
    [FieldNameList] = GetAllFieldNames();
    [x] = size(FieldNameList,2);

    for i = 1:x
        field(i) = {StockQuote(Symbol{j},FieldNameList(i),[Date])};
    end
    s(j) = cell2struct(field,FieldNameList,2);

    %workaround
    %only one character is return
    s(j).symbol = Symbol{j};
end
close(h)