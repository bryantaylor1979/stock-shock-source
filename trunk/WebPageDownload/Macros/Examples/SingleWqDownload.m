%%
obj.sURL = 'http://www.shareprice.co.uk/'; 
obj.eURL = '';

Symbol = 'OTC';
ProgramName = 'SharePrice';
ResultName = 'Summary';
Date = today;

%%
[s,Error] = obj.SaveWQ(Symbol,ProgramName,ResultName,Date);

%%
s = obj.ReadWebQuery([obj.sURL,Symbol,obj.eURL])

%%
string = 'http://www.shareprice.co.uk/OTC'
obj.WriteWebQuery(string);