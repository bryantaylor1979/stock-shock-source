function [] = StartButtonCallback()
%%
global h
String = get(h.pulldown,'String');
Value = get(h.pulldown,'Value');
Group = String{Value};
SearchAndAddSymbols(Group);