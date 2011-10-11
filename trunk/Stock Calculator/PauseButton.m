function [] = PauseButton();
%
%Written by:    Bryan Taylor
%Date Created:  5th March 2008
%Date Modified: 5th March 2008

global handles Status
set(handles.startbutton,'Enable','on');
set(handles.pausebutton,'Enable','off');
set(handles.stopbutton,'Enable','on');

Status = 'Paused';