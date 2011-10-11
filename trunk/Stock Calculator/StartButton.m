function [] = StartButton();
%Written by:    Bryan Taylor
%Date Created:  5th March 2008
%Date Modified: 5th March 2008

tic
global handles Status
set(handles.startbutton,'Enable','off');
set(handles.pausebutton,'Enable','on');
set(handles.stopbutton,'Enable','on');

if or(strcmp(Status,'Ready'),strcmp(Status,'Stop'))
    disp('Starting again.')
    load CalcSetting CalcSetting
    Status = 'Ready';
    Calculation = CalcSetting.CalculationsSelected;
    CalculateWrapper('all',Calculation);
end