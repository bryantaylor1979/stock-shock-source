%%
obj.sURL = 'http://uk.stoxline.com/q_uk.php?s='; 
obj.eURL = '';

ProgramName = 'Stox';
ResultName = 'Best_Investments';
Date = today;


obj.ReadMap('III_IndexMap');
Symbols = obj.Data(:,2)

obj.SaveALLURL(Symbols,ProgramName,ResultName,Date);