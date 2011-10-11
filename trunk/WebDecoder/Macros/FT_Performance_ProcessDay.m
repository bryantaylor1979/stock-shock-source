ProgramName = 'FinicialTimes';
ResultName = 'Performance';
if not(exist('Date')), Date = today;,  Date = obj.GetStoreDate(Date);, end
% 
Symbol = obj.GetURL_Symbols(ProgramName,ResultName,Date);
struct = obj.GetConfig2('FT_Performance');
[DATASET, N_ErrorSymbols] = obj.DecodeALL(struct,'URL',Symbol,ProgramName,ResultName,Date);

%
DATASET = [dataset(Symbol),DATASET];
DATASET = obj.FT_Perf.Add_CurrencyAndMarketCapAmount(DATASET1);
DATASET = obj.Add_MarketCapNum(DATASET2);
DATASET = obj.Add_MarketCapInDollars(DATASET3);
DATASET = obj.Add_MarketCapCategory(DATASET4);

obj.SaveDataSet(DATASET,ProgramName,ResultName,Date);