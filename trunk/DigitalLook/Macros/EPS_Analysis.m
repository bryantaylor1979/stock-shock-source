%% RENE
Date = today - 7;
Symbols = obj.GetSymbols;

%%
obj.DownloadAllEPS(Symbols);

%%
DataSet = obj.EPS_All(Symbols,today-7);

%%
filename = [obj.InstallDir,'Results\EPS\DataSet\',datestr(date),'.mat'];
save(filename,'DataSet');
