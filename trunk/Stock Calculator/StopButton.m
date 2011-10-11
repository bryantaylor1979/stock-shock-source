function [] = StopButton();

global handles Status
set(handles.startbutton,'Enable','on');
set(handles.pausebutton,'Enable','off');
set(handles.stopbutton,'Enable','off');

Status = 'Stop';