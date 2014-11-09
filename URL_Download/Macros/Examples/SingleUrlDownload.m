%%
obj.sURL = 'http://uk.stoxline.com/q_uk.php?s='; 
obj.eURL = '';

Symbol = 'CON';
ProgramName = 'Stox';
ResultName = 'Best_Investments';
Date = today;
[s,Error] = obj.SaveURL(Symbol,ProgramName,ResultName,Date);