%% 
Symbols = obj.GetAllSymbols;
 %r2    P/E Ratio (Real-time) 
 %s     Symbol
 %l1    Last Trade (Price Only) 
 %d1    Last Trade Date 
 %t1    Last Trade Time 
 %o     Open 
 %h     Day's High 
 %g     Day's Low 
 %d     Dividend/Share 
 %r     P/E Ratio
 %r2    P/E Ratio (Real-time)  
 %r5    PEG Ratio 
 %r6    Price/EPS Estimate Current Year 
 %r7    Price/EPS Estimate Next Year 
 %e7    EPS Estimate Current Year 
 %e8    EPS Estimate Next Year 
 %e9    EPS Estimate Next Quarter 
Symbols = strrep(Symbols,'.L','');
Fields = {  'c1'; ...
            'p'};
DATASET = obj.GetYahooQuery(Symbols,Fields);

%% 
Change = obj.GetColumn(DATASET,'c1');
PreviousClose = obj.GetColumn(DATASET,'p');
PercentageChange = Change./PreviousClose.*100;
DATASET = [DATASET,dataset(Symbols,PercentageChange)];

n = find(isnan(PercentageChange) == 0);
DATASET = DATASET(n,:);
DATASET = sortrows(DATASET,'PercentageChange','descend');


obj.DataSet2xls(DATASET,['C:\SourceSafe\Stocks & Shares\Programs\Yahoo\Results\Winners\xls\',datestr(now,1),'.xls']);
obj.DataSet2csv(DATASET,['C:\SourceSafe\Stocks & Shares\Programs\Yahoo\Results\Winners\Winners.csv']);
% obj.SendFtp(['C:\SourceSafe\Stocks & Shares\Programs\Yahoo\Results\Winners\Winners.csv'],'httpdocs/Yahoo/','wfoote.com','shares','cormorant');
