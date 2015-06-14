function DATASET = queryWinners()
obj = readsymbolslist('iii_map_v2.m')
Symbols = obj.SymbolList()

%%
Fields = {  'c1'; ...
            'p'};
DATASET = getYahooQuery(Symbols,Fields)


%% 
ChangeCell = cellfun(@str2num,DATASET.c1,'UniformOutput',false)
x = size(ChangeCell,1)
for i = 1:x
    try
        Change(i,1) = ChangeCell{i};
    catch
        Change(i,1) = NaN;    
    end
end


%%
PreviousClose = DATASET.p
PercentageChange = Change./PreviousClose.*100

%%
DATASET = [DATASET,dataset(Symbols,PercentageChange)];

n = find(isnan(PercentageChange) == 0);
DATASET = DATASET(n,:);
DATASET = sortrows(DATASET,'PercentageChange','descend');
end