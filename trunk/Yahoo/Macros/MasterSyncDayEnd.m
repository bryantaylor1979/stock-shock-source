%%
MacroName = 'MasterSyncDayEnd';
BB_DATASET = obj.LoadLastResult('BritishBulls','ALL_STATUS');
Symbols = obj.GetColumn(BB_DATASET,'Ticker');


%d1    Last Trade Date 
%t1    Last Trade Time   
%a     Ask
%b     Bid
Fields = {      'a',   'b',  'b4', 'c1', 'c8', 'd2', 'e7', 'f6', 'j',  'g3', 'g6', 'j1', 'j5', 'k2', ...    
                'k5',  'l2', 'm2', 'm5', 'm8', 'o',  'p2', 'q',  'r2', 'r7', 's7', 't7', 'v1', 'w1', ...    
                'y',   'a2', 'b2', 'c3', 'd',  'e',  'e8', 'g',  'k',  'g4', 'i',  'j3', 'j6', ...    
                'l',  'l3', 'm3', 'm6', 'n',  'p',  'p5', 'r',  'r5', 's',  't1', 't8', 'v7', ...    
                'w4', 'b3', 'c',  'c6', 'd1', 'e1', 'e9', 'h',  'g1', 'g5', 'i5', 'j4', 'k1', ...    
                'k4',  'l1', 'm',  'm4', 'm7', 'n4', 'p1', 'p6', 'r1', 'r6', 's1', 't6', 'v',  'w', ...     
                'x'}; 
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
obj.DataSet2xls(BB_DATASET,[obj.InstallDir,'Results\',MacroName,'\xls\',datestr(today,1),'.xls']);
save([obj.InstallDir,'Results\',MacroName,'\DataSet\',datestr(today,1)],'BB_DATASET');