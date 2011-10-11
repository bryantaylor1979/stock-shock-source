%%
obj = FT_BrokersView('GUI_Mode','Full');
obj.FilterOnBestBuys
obj.GetTable
Table = obj.GetTable;

%%
objBB = BritishBulls('Visible',false);

%%
Symbols = Table(:,2);
[x] = size(Symbols,1);
Array = [];
for i = 1:x
    try
    Array = [Array;[Symbols(i),objBB.QuerySymbol(Symbols{i})]];
    end
    fprintf([Symbols{i},'.L ,'])
end
Array

%%
n = find(strcmpi(Array(:,4),'Buy'));
Array = Array(n,:);
n = find(datenum(Array(:,2)) > today-10);
Array(n,:)