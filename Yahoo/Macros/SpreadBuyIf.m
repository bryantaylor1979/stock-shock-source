%%
BB_DATASET = obj.LoadLastBB_BuyIF();
Symbols = obj.GetColumn(BB_DATASET,'Ticker');
%d1    Last Trade Date 
%t1    Last Trade Time   
%a     Ask
%b     Bid
Fields = {  'a'; ...
            'b'; ...
            'd1'; ...
            't1'};
        
%%
DATASET = obj.GetYahooQuery(Symbols,Fields);
%%
Ask = obj.GetColumn(DATASET,'a'); %Ask
Bid = obj.GetColumn(DATASET,'b'); %Bid
Spread = (Ask./Bid-1)*100;

%%
BB_DATASET = [BB_DATASET,dataset(Ask,Bid,Spread)];

%%
PercentageThreshold = 1;   BB_DATASET = obj.RemoveSpread(BB_DATASET, PercentageThreshold);

%%
BB_DATASET = obj.ColumnFiltering(BB_DATASET,{   'Ticker', ...
                                                'Description', ...
                                                'Signal', ...
                                                'Sector', ...
                                                'Ask', ...
                                                'Bid', ...
                                                'Spread', ...
                                                'Profit'});
                                            
                                            %%
BB_DATASET = sortrows(BB_DATASET,'Profit','descend');

%%
obj.DataSet2csv(BB_DATASET,[obj.InstallDir,'Results\BB_BuyIF_Spread\BuyIfTomorrow.csv']);
obj.DataSet2xls(BB_DATASET,[obj.InstallDir,'Results\BB_BuyIF_Spread\xls\',datestr(today,1),'.xls']);
save([obj.InstallDir,'Results\BB_BuyIF_Spread\DataSet\',datestr(today,1)],'BB_DATASET');

%%
obj.SendFtp([obj.InstallDir,'Results\BB_BuyIF_Spread\BuyIfTomorrow.csv'],'httpdocs/britishbulls/BuyIf_Tommorrow/Stage2/','wfoote.com','shares','cormorant');