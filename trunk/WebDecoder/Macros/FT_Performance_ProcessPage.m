ProgramName = 'FinicialTimes';
ResultName = 'Performance';
Symbol = 'HAWK';
struct = obj.GetConfig2('FT_Performance');

[s, Error] = obj.LoadResult_Type(ProgramName,ResultName,Symbol,today-1,'URL');
outStruct = obj.DecodeURL(s,struct);