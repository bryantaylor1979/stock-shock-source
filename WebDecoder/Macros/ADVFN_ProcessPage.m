ProgramName = 'ADVFN';
Symbol = 'HAWK';
struct = obj.GetConfig2(ProgramName);
s = obj.Load(Symbol,ProgramName,'Symbol2Num','URL',Date); 
outStruct = obj.DecodeURL(s,struct)