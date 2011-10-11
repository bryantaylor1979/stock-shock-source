%%
Date = obj.Today;
Symbols = obj.GetBBSymbols(Date);
Symbols = strrep(Symbols,' ','');
Symbols = strrep(Symbols,'.L','');
BB_DATASET = obj.LoadLastResult('BritishBulls','SystemConfirmed');

%%
%d1    Last Trade Date 
%t1    Last Trade Time   
%a     Ask
%b     Bid
Fields = {  'a'; ...
            'b'; ...
            'd1'; ...
            't1'};
DATASET = obj.GetYahooQuery(Symbols,Fields);

%%
Ask = obj.GetColumn(DATASET,'a'); %Ask
Bid = obj.GetColumn(DATASET,'b'); %Bid

Spread = (Ask./Bid-1)*100;

%%
BB_DATASET = [BB_DATASET,dataset(Spread)];
PercentageThreshold = 1;   BB_DATASET = obj.RemoveSpread(BB_DATASET, PercentageThreshold);

%%
obj.DataSet2xls(BB_DATASET,[obj.InstallDir,'Results\BB_Spread\xls\',datestr(Date,1),'.xls']);
obj.DataSet2csv(BB_DATASET,[obj.InstallDir,'Results\BB_Spread\britishbulls.csv']);
obj.SendFtp([obj.InstallDir,'Results\BB_Spread\britishbulls.csv'],'httpdocs/britishbulls/','wfoote.com','shares','cormorant');