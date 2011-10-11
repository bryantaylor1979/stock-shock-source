function [] = MinThreshold_Enable(varargin)

global handles settings
Value = get(handles.descion.MinThresholdEnable,'Value');

if Value == 1
   settings.descion.MinThresholdEnable = true;
   set(handles.descion.MinThreshold,'Enable','on');
elseif Value == 0
   settings.descion.MinThresholdEnable = false;
   set(handles.descion.MinThreshold,'Enable','off');
else
   error('Error reading MinThreshold ticker box value')
end