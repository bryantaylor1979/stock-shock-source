%% Level 1a - Check
Symbol = 'RBS';
[DataSet,Status] = obj.EPS_Single(Symbol,today)

%% Level 2a (If fail 1)
EpsDataSet = obj.GetEPS(Symbol,today) %FAILED

%% Level 2b - 
PE_Method = 'Interpolated'; %Last or Interpolated.
save([obj.InstallDir,'Results\EPS\mat\',Symbol,'.mat'])

Date = obj.GetColumn(EpsDataSet,'YearEnd')
SharePriceDataSet = obj.PriceQuote(Symbol,min(Date));

CombinedDataSet = obj.PE_Calc(SharePriceDataSet,EpsDataSet,PE_Method);
h = obj.Plot(CombinedDataSet); 

%
figsavepath = [obj.InstallDir,'Results\EPS\fig\']
saveas(h.figure, [figsavepath,Symbol], 'fig')
save([obj.InstallDir,'Results\EPS\mat\',Symbol,'.mat'])

close(h.figure)

%% Level 3a (If 2a fails) 
s = obj.SaveURL_Fundamentals(Symbol);
s = obj.LoadURL_Fundamentals(Symbol,today);
[N_DATASET2] = obj.URL_GetForecasts(s,Symbol);
[DATASET2] = obj.URL_GetFundamentals(s,Symbol);

%Combined
try
DATASET = [N_DATASET2;DATASET2];
catch
DATASET = [DATASET2];    
end