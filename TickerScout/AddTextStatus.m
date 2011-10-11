function [] = AddTextStatus(text)
%%
global h
String = get(h.textbox,'String');
if not(iscell(String))
    String = {String};
end
String = [String;{text}];
set(h.textbox,'String',String);
drawnow