function [s] = StructureQuote(Symbol,Date);
%This function returns an structured array with ALL field found in the database
%
%Create a structure of that days information
%This function should adaptive create a structure based on the available
%fields.
%Only one date can be specified but mulitple symbols
% 
%More work required to introduce cache
%
%Example:
%[s] = StructureQuote({'AA';'ASA'},today-120)
%
%Written by: Bryan Taylor
%Date Created: 29th July 2007
%Date Modified: 29th July 2007
global settings

mode = 'fast'; %Normal


[y] = size(Symbol,1);
h = waitbar(0,['Getting Quote For Symbols (0 of ',num2str(y),')']);
for j = 1:y
    waitbar(j/y,h,['Getting Quote For Symbols (',num2str(j),' of ',num2str(y),')']);
    
    if strcmpi(mode,'fast')
        FieldNameList = CalculateParametersFcn('ColumnNames');
    else
        [FieldNameList] = GetAllFieldNames(); 
    end
        
    [x] = size(FieldNameList,2);
    
    switch lower(settings.descion.ComObject)
        case 'local'
            field = {StockQuote(Symbol{j},FieldNameList,[Date])};
        case 'cached'
            field = {CacheQuote(Symbol{j},FieldNameList,[Date])};
        otherwise
            error('Com Object Not Recognised')
    end
    field = field{1};
    
    
    try
    s(j) = cell2struct(field,FieldNameList,2);
    catch
       breakhere = 1; 
    end

    %workaround
    %only one character is return
    s(j).symbol = Symbol{j};
end
close(h)