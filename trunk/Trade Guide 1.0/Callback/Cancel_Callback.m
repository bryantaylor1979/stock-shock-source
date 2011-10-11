function [] = Cancel_Callback()
global handles settings

load settings settings
close(handles.figure)