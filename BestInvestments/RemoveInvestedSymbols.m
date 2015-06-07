function [DATASET, Status] = RemoveInvestedSymbols(DATASET,InvestedSymbols)   
    %%
    [x] = size(InvestedSymbols,1);
    if isempty(DATASET)
        DATASET = [];
        Status = -1;
        return                 
    end
    for i = 1:x
        try
            [Symbols] = obj.GetColumn(DATASET,'BB_HIST_Ticker');
            n = find(not(strcmpi(InvestedSymbols{i},Symbols)));
            DATASET = DATASET(n,:);
        catch
            DATASET = [];
            Status = -1;
            return 
        end
    end
    [x] = size(DATASET,1);
    if x == 0
        DATASET = [];
        Status = -1;
        return 
    else
        Status = 0;
        DATASET = DATASET;
    end
end
function Example()
    %%
    TP_DATASET = getBritishbullsHistory('BARC.L');
    [DATASET, Status] = RemoveInvestedSymbols(TP_DATASET,   {'BARC.L'}) 
end