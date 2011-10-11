%%
BB_DATASET = obj.LoadLastBB_BuyIF();
Symbols = obj.GetColumn(BB_DATASET,'Ticker');
 %s     Symbol
 %r     P/E Ratio
 
Fields = {  's'; ...
            'j1'};
DATASET = obj.GetQuery(Symbols,Fields);
