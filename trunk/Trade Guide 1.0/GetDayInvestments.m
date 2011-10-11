function [Symbols] = GetDayInvestments(date,InvestedSymbols,number_of_investments)
% get the best investments for that day and ensure they haven't been
% invested in.

report = false;
[x] = size(InvestedSymbols,1);
insy = x;
%if the structure is the same size as the required number of investments
%then we can return with an empty array
Symbols = struct([]);

if x > number_of_investments;
    return
end

% intialise variables
BuySymbolsArray = [];
OutSymbolsArray = [];

[symbols] = DayBestInvestments(date);

%% No Current Investments
% if there is not already any symbols invested the Day best symbols should
% be cropped and returned.
[x] = size(InvestedSymbols,1);
if x == 0;
    Symbols = symbols;
    [y] = size(Symbols,2);
    for i = 1:y
        Symbols(i).action = 'Buy';
    end
    if y > number_of_investments
       Symbols = Symbols(1:number_of_investments);
    end
    return
end
if report == true
    disp('Day''s best investments are:')
    DispStruct(symbols,{'symbol'});
end

%% Has Investments
SymbolsArray = Struct2Data(symbols,'symbol');
SymbolsArray1 = SymbolsArray;
[x] = size(InvestedSymbols,1);
for i = 1:x
    try
    n = find(not(strcmp(InvestedSymbols(i),SymbolsArray1)));
    [SymbolsArray1] = SymbolsArray1(n);
    end
end
OutSymbolsArray = SymbolsArray1;
if isempty(OutSymbolsArray)
    Symbols = [];
    return
end
[x] = size(OutSymbolsArray,1);
for i = 1:x
    n = find(strcmp(SymbolsArray,OutSymbolsArray(i)));
    Symbols = [Symbols,symbols(n)];
end

[x] = size(Symbols,2);
for i = 1:x
    Symbols(i).action = 'Buy';
end
if x+insy > number_of_investments
    Symbols = Symbols(1:number_of_investments-insy);
end

%% Report Section
if report == true
    disp(['Searching Date: ',datestr(date)]);
    disp('The best found investments are:')
    DispStruct(Symbols,{'symbol';'action';'datenum'});
end