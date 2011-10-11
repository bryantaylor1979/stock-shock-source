%%
%This is run pre-open, 10 am, 12am, and 3:30pm
MacroName = 'MasterBUYconfQuote';
BB_DATASET = obj.LoadLastResult('BritishBulls','ALL_STATUS');
Symbols = obj.GetColumn(BB_DATASET,'Ticker');


%d1    Last Trade Date 
%t1    Last Trade Time   
%a     Ask
%b     Bid
%o     Open 
%h     Day's High 
%g     Day's Low
%p     Previous Close
Fields = {'a',  'b', 'd1', 't1', 'a', 'b', 'o', 'h', 'g', 'p'}; 

 
%%
Fields = {  's'; ...
            'o'; ...
            'g'; ...
            'k2'; ...
            'p'};
%Removed b6, k3, a5

%%
DATASET = obj.GetYahooQuery(Symbols,Fields);

%% Calculations
Ask = obj.GetColumn(DATASET,'a'); %Ask
Bid = obj.GetColumn(DATASET,'b'); %Bid
Spread = (Ask./Bid-1)*100;

%%
BB_DATASET = [dataset(Symbols),DATASET,dataset(Spread)];
                                            
%%
obj.DataSet2csv(BB_DATASET,[obj.InstallDir,'Results\',MacroName,'\BuyIfTomorrow.csv']);
obj.DataSet2xls(BB_DATASET,[obj.InstallDir,'Results\',MacroName,'\xls\',strrep(datestr(now),':','_'),'.xls']);
save([obj.InstallDir,'Results\',MacroName,'\DataSet\',strrep(datestr(now),':','_')],'BB_DATASET');