function [] = Apply_Callback()
global handles settings

settings.descion.MinThreshold = str2num(get(handles.descion.MinThreshold,'String'));
settings.descion.MinThresholdEnable = get(handles.descion.MinThresholdEnable,'Value');
settings.descion.ForceRefresh = get(handles.descion.ForceRefresh,'Value');
settings.descion.NoOfInvestments = str2num(get(handles.descion.NoOfInvestments,'String'));