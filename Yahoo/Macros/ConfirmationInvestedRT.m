%Things to Add
%1.  Profit from historical Analysis
%2.  Index state, remove sells by category
%3.  Profit from benchmark.
InvestedSymbols = obj.LoadInvestedSymbols('InvestedSymbolList.txt');

%%
[BB_DATASET, DateNum, Error] = obj.LoadLastWorkingDaysResult('BritishBulls','ALL_STATUS');
NoOfDaysAgo = today - DateNum;
disp(['Last updated: ',datestr(DateNum)])
disp(['NoOfDaysAgo: ',num2str(NoOfDaysAgo)])
disp(' ')
if Error == -1,  disp('No British Bulls Data Available'), disp('See Log:  C:\SourceSafe\Stocks & Shares\Programs\BritishBulls\Results\BUY_IF\log'), end

%% Filter on Invested
Symbols = obj.GetColumn(BB_DATASET,'Ticker');
%%
InvestedSymbols = strrep(InvestedSymbols,'.L','');
InvestedSymbols = strrep(InvestedSymbols,'.','_');
DATASET = obj.ColumnStr(BB_DATASET,'Ticker',InvestedSymbols);
%  s     Symbol
%  o     Open 
%  h     Day's High 
%  g     Day's Low
%  p     Previous Close
Symbols = strrep(Symbols,'_',''); %Workaround for TW.  

%% SELLIF
disp('SELL-IF')
disp('=======')
SELL_DATASET = obj.ColumnStr(DATASET,'Signal','SELL-IF')
disp(['Number with condition: ',num2str(size(SELL_DATASET,1))])
Symbols = obj.GetColumn(SELL_DATASET,'Ticker');
Fields = {  'Ask', ...
            'Bid', ...
            'Open', ...
            'DayHigh', ...
            'PriceChange', ...
            'Price', ...
            'PercentageChange', ...
            'PrevClose'};  
        
Symbols2 = strrep(Symbols,'BP_','BP'); %Workaround for BP. 
Symbols2 = strrep(Symbols2,'TW_','TW.'); %Workaround for BP. 
Y_DATASET = obj.GetSharePriceQuery(rot90(Symbols2),Fields);
Y_DATASET = obj.SP_SellCalcConfirmed(Y_DATASET);
SELL_DATASET = obj.ColumnFiltering(SELL_DATASET,{   'Ticker', ...
                                                'Description', ...
                                                'Signal', ...
                                                'Sector'});
                                            
SELL_DATASET_ = [SELL_DATASET,Y_DATASET];

SELL_DATASET1 = obj.ColumnFiltering(SELL_DATASET_,{ 'Ticker', ...
                                                    'Signal', ...
                                                    'Conf'});                                                
disp(SELL_DATASET1)

SELL_DATASET = obj.ColumnStr(SELL_DATASET_,'Conf','TRUE');
disp(['Number confirmed: ',num2str(size(SELL_DATASET,1))]) 
disp(' ')
% DATASET2 = sortrows(DATASET2,'Profit','descend');

%% BUY_IF
disp('BUY_IF')
disp('=======')
BUY_DATASET = obj.ColumnStr(DATASET,'Signal','BUY-IF');
disp(['Number with condition: ',num2str(size(BUY_DATASET,1))])

logic = isempty(BUY_DATASET);
if logic == 0, Symbols = obj.GetColumn(BUY_DATASET,'Ticker');, else, Symbols = [];, end
if logic == 0, Symbols = strrep(Symbols,'_','.'), end %Workaround for TW.  
if logic == 0, Y_DATASET = obj.GetSharePriceQuery(rot90(Symbols),Fields), end
if logic == 0, Y_DATASET = obj.SP_BuyCalcConfirmed(Y_DATASET);, end
if logic == 0, BUY_DATASET = obj.ColumnFiltering(BUY_DATASET,{   'Ticker', 'Description', 'Signal', 'Sector'});, end
if logic == 0, BUY_DATASET_ = [BUY_DATASET,Y_DATASET];, end
if logic == 0, BUY_DATASET2 = obj.ColumnFiltering(BUY_DATASET_,{   'Ticker', 'Signal', 'Conf'});, disp(BUY_DATASET2),  end                                                
if logic == 0, BUY_DATASET = obj.ColumnStr(BUY_DATASET_,'Conf','TRUE');, end
if logic == 1, BUY_DATASET = [];, BUY_DATASET_ = dataset([]);, end
disp(['Number confirmed: ',num2str(size(BUY_DATASET,1))]) 
disp(' ')

%% Combine Events
DATASET3 = obj.CombineDataSets(BUY_DATASET,SELL_DATASET)

%% Log a summary
HOLD_DATASET = obj.ColumnStr(DATASET,'Signal','HOLD');
WAIT_DATASET = obj.ColumnStr(DATASET,'Signal','WAIT');
BUYCONF_DATASET = obj.ColumnStr(DATASET,'Signal','BUY CONF');
SELLCONF_DATASET = obj.ColumnStr(DATASET,'Signal','SELL CONF');

OTHER = [HOLD_DATASET;WAIT_DATASET;BUYCONF_DATASET;SELLCONF_DATASET];
OTHER = obj.ColumnFiltering(OTHER,{   'Ticker', ...
                                      'Description', ...
                                      'Signal', ...
                                      'Sector'});
Symbols = obj.GetColumn(OTHER,'Ticker');
Symbols = strrep(Symbols,'_','.'); %Workaround for TW.  
Y_DATASET = obj.GetSharePriceQuery(rot90(Symbols),Fields);
Y_DATASET = obj.SP_BuyCalcConfirmed(Y_DATASET);
OTHER = [OTHER,Y_DATASET];
n = find(strcmpi(get(OTHER,'VarNames'),'Conf'));
p = size(OTHER,1);
for i = 1:p
    OTHER{i,n} = 'N/A';
end
if isempty(BUY_DATASET_), MAIN = [SELL_DATASET_;OTHER];, else, MAIN = [BUY_DATASET_;SELL_DATASET_;OTHER];, end

%%
obj.DataSet2xls(MAIN,['C:\SourceSafe\Stocks & Shares\Programs\Yahoo\Results\BB_RT_Confirmation\xls\',strrep(datestr(now),':','_'),'.xls']);

%%
obj.SendSMS_Alert(DATASET3);
diary off
