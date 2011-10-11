function [] = AddText(text)

global handles
String = get(handles.textbox,'String');
string = [String;{text}];
set(handles.textbox,'String',string);
[x] = size(string,1);
set(handles.textbox,'Value',x);