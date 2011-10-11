function [newsymbolset] = StockQuoteMatQuery(symbolset,date);

if isempty(symbolset)
   error('Input symbol set is empty'); 
end

[x] = size(symbolset,1);
path = 'C:\SourceSafe\Stocks & Shares\Programs\Trade Guide\SaveData\Download_Mat\Database\';

for i = 1:x
    load([path,symbolset{i},'.mat']);
    try
        Datenum = DataStore(:,1);
        n = find(Datenum <= date);
        n = n(size(n,1));
        newrow = [symbolset(i),num2cell((DataStore(n,:)))];
        empty = false;
    catch
        empty = true;
    end
    if empty == false  
        if i == 1
        newsymbolset = newrow;
        else
        newsymbolset = [newsymbolset;newrow];   
        end
    else
        %do append to new symbol array.
    end
end