%% Settings
% Symbol = 'BARC';
% Date = today-1;

%%
ProgramName = 'FinicialTimes';
ResultName = 'Analysis';
disp(Symbol)
%
struct = obj.GetConfig2('FT_Analysis');

[s, Error] = obj.LoadResult_Type(ProgramName,ResultName,Symbol,today-1,'URL');
outStruct = obj.DecodeURL(s,struct)
N_DATASET = obj.Struct2DataSet(outStruct)


%
IN_struct.TableStart   = '<table class="consensusOverview"><';
IN_struct.TableEnd     = '</table></div><div class="contentModule contain"><h2>';
IN_struct.RowStart     = '<td class="rowLabel"';
IN_struct.RowEnd       = '</tr>';
IN_struct.CellStart    = '<td';
IN_struct.CellEnd      = '</td>';
IN_struct.CellEndT     = '/>';
Table = obj.DecodeTable(s,IN_struct)

% Latest
Latest_Buy          = str2double(Table(1,2));
Latest_Outperform	= str2double(Table(1,3));
Latest_Hold         = str2double(Table(1,4));
Latest_Underperform	= str2double(Table(1,5));
Latest_Sell         = str2double(Table(1,6));
Latest_NoOpinion    = str2double(Table(1,7));

% FourWeeksAgo
FourWeeksAgo_Buy            = str2double(Table(2,2));
FourWeeksAgo_Outperform     = str2double(Table(2,3));
FourWeeksAgo_Hold           = str2double(Table(2,4));
FourWeeksAgo_Underperform	= str2double(Table(2,5));
FourWeeksAgo_Sell           = str2double(Table(2,6));
FourWeeksAgo_NoOpinion      = str2double(Table(2,7));

% TwoMonthsAgo
TwoMonthsAgo_Buy            = str2double(Table(3,2));
TwoMonthsAgo_Outperform     = str2double(Table(3,3));
TwoMonthsAgo_Hold           = str2double(Table(3,4));
TwoMonthsAgo_Underperform   = str2double(Table(3,5));
TwoMonthsAgo_Sell           = str2double(Table(3,6));
TwoMonthsAgo_NoOpinion      = str2double(Table(3,7));

% ThreeMonthsAgo
ThreeMonthsAgo_Buy            = str2double(Table(4,2));
ThreeMonthsAgo_Outperform     = str2double(Table(4,3));
ThreeMonthsAgo_Hold           = str2double(Table(4,4));
ThreeMonthsAgo_Underperform   = str2double(Table(4,5));
ThreeMonthsAgo_Sell           = str2double(Table(4,6));
ThreeMonthsAgo_NoOpinion      = str2double(Table(4,7));

% Last year
LastYear_Buy            = str2double(Table(5,2));
LastYear_Outperform     = str2double(Table(5,3));
LastYear_Hold           = str2double(Table(5,4));
LastYear_Underperform   = str2double(Table(5,5));
LastYear_Sell           = str2double(Table(5,6));
LastYear_NoOpinion      = str2double(Table(5,7));

%%
DATASET = dataset(      {{Symbol},'Symbol'}, ...
                        Latest_Buy, ...
                        Latest_Outperform, ...
                        Latest_Hold, ...
                        Latest_Underperform, ...
                        Latest_Sell, ...
                        Latest_NoOpinion, ...
                        FourWeeksAgo_Buy, ...
                        FourWeeksAgo_Outperform, ...
                        FourWeeksAgo_Hold, ...
                        FourWeeksAgo_Underperform, ...
                        FourWeeksAgo_Sell, ...
                        FourWeeksAgo_NoOpinion, ...
                        TwoMonthsAgo_Buy, ...
                        TwoMonthsAgo_Outperform, ...
                        TwoMonthsAgo_Hold, ...
                        TwoMonthsAgo_Underperform, ...
                        TwoMonthsAgo_Sell, ...
                        TwoMonthsAgo_NoOpinion, ...
                        ThreeMonthsAgo_Buy, ...
                        ThreeMonthsAgo_Outperform, ...
                        ThreeMonthsAgo_Hold, ...
                        ThreeMonthsAgo_Underperform, ...
                        ThreeMonthsAgo_Sell, ...
                        ThreeMonthsAgo_NoOpinion, ...
                        LastYear_Buy, ...
                        LastYear_Outperform, ...
                        LastYear_Hold, ...
                        LastYear_Underperform, ...
                        LastYear_Sell, ...
                        LastYear_NoOpinion);
        

DATASET = [DATASET,N_DATASET];
