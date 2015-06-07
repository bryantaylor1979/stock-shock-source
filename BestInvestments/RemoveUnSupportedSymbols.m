function [DATASET] = RemoveUnSupportedSymbols(DataSet,Date)
    %Remove symbols that you won't beable to get a quote on yahoo
    %from.
    Symbol = DataSet.Symbol;
    x = size(DataSet,1);
    for i = 1:x
        Found(i) = GetSymbolQuote(Symbol{i},Date+1);
    end
    n = find(Found==true);
    DATASET = DataSet(n,:);         
end
function [Found] = GetSymbolQuote(Symbol,Date)
   startdate = Date;
   enddate = Date-10;
   timeout = 2;
   time = 1;

   while time < timeout
       try
           [    date, ...
                close, ...
                open, ...
                low, ...
                high, ...
                volume, ...
                closeadj] = ...
                sqq(Symbol,startdate,enddate,'d');
            break
       catch
           disp(['Pause for ',num2str(time),' seconds'])
           pause(time)
           time = time*2; 
       end
   end
   if time >= timeout
       Found = false;
       return
   end

   x = size(date,1);
   if x > 1
      Found = true;
   else
      Found = false;
   end
end
function Example()
    %%
    Symbol = {'BARC.L'; ...
              'RBS.L'; ...
              'SHT.L'};
    DATASET = dataset({Symbol,'Symbol'})
    [DATASET] = RemoveUnSupportedSymbols(DATASET,today)
end