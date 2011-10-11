%Things to Add
%1.  Profit from historical Analysis
%2.  Index state, remove sells by category
%3.  Profit from benchmark. 

%%
[BB_DATASET, DateNum] = obj.LoadLastBB_SellIF();
NoOfDaysAgo = today - DateNum;
disp(['Last updated: ',datestr(DateNum)])
disp(['NoOfDaysAgo: ',num2str(NoOfDaysAgo)])
disp(' ')

Symbols = obj.GetColumn(BB_DATASET,'Ticker');
%  s     Symbol
%  o     Open 
%  h     Day's High 
%  g     Day's Low
%  p     Previous Close
 
%%
Fields = {  's'; ...
            'o'; ...
            'h'; ...
            'c1'; ...
            'p'};
DATASET = obj.GetYahooQuery(Symbols,Fields);
DATASET = obj.Yahoo_SellCalcConfirmed(DATASET);

%%
BB_DATASET = obj.ColumnFiltering(BB_DATASET,{   'Ticker', ...
                                                'Description', ...
                                                'Signal', ...
                                                'Sector'});
DATASET2 = [BB_DATASET,DATASET];
DATASET2 = obj.ColumnStr(DATASET2,'Conf','TRUE');
% DATASET2 = sortrows(DATASET2,'Profit','descend');

%%
% obj.DataSet2xls(DATASET2,[obj.InstallDir,'Results\Confirmation\',datestr(Date,1),'.xls']);
obj.DataSet2csv(DATASET2,[obj.InstallDir,'Results\SellConfirmation\Confirmation.csv']);

%%
obj.SendFtp([obj.InstallDir,'Results\SellConfirmation\Confirmation.csv'],'httpdocs/britishbulls/SellConfirmedRealTime/','wfoote.com','shares','cormorant');