function [] = UpdateData(symbol,Valid,NoOfTimesSearched)
%update data
global h conn2

if isnan(Valid)
   x=1;
end
[suffix] = GetSuffix();
suffix = strrep(suffix,'.','_');
string = ['where symbol = ''',symbol,''''];
ValidT = ['Valid',suffix];
NoOfTimesSearchedT = ['NoOfTimesSearched',suffix]
update(conn2, 'Symbols', {ValidT,NoOfTimesSearchedT}, [Valid,NoOfTimesSearched], string);