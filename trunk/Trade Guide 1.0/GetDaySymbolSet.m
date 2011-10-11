function [symbolset] = GetDaySymbolSet(datenumber,type)
%GETDAYSYMBOLSET List of available symbols on specified day
%  This function looks at the local database and get all avaliable symbols
%  which have valid data on the specified day.
%
%INPUTS:    
%   DateNumber  This can be one number or an array off numbers
%   type:       'Discrete'  Multiple symbol sets for every datenum
%               'Inclusive' One symbol set which is common to all datenum's
%
%OUTPUTS:
%   symbol      An array of symbol sets.
%
%Example:
%[symbolset] = GetDaySymbolSet(today-120,'discrete');
%
%Created by:    Bryan Taylor
%Date Modified: 22nd Feb 2007
%Date Created:  22nd Feb 2007
global savecriteria

[OutPutArray] = GetStageData('DateRange');

[symbolset] = DaySymbolSet(OutPutArray,datenumber);
switch lower(type)
    case 'discrete'
        return
    case 'inclusive'
    otherwise
        error('type input not recognised')
end

% %find common symbol set
% [x] = size(symbolset,1);
% count = 0;
% NewArray = {};
% mastersymbolset = symbolset{1,1};
% for i = 1:x %loop over symbol sets
%     comparesymbolset = symbolset{i,1};
%     [y] = size(comparesymbolset,1);
%     for j = 1:y
%         locations = find(strcmp(mastersymbolset,comparesymbolset{j}));
%         [x] = size(locations,1);
%         if x == 0;
%            %remove from master symbol set
%            goodsymbols = find(not(strcmp(mastersymbolset,comparesymbolset{j})));
%            mastersymbolset = mastersymbolset(goodsymbols);
%         end
%     end
% end
% symbolset = mastersymbolset;

function [symbolset] = DaySymbolSet(OutPutArray,datenumber)
[x] = size(OutPutArray,1);
count = 0;
j = 1;
for i = 1:x
    try
        startdate = datenum(OutPutArray(i,3));
        enddate = datenum(OutPutArray(i,4));
        if startdate <= datenumber(j)
            if enddate >= datenumber(j)
                count = count + 1;
                symbol{count,1} = OutPutArray(i,1);
                symbolset{j,1} = symbol;
            end
        end   
    end
end
symbolset = symbolset{1};