function [] = Downloader()

%% Stock Quote Syncronisation
close all
global handles
IntialiseDatabase;
handles.figure = waitbar(0,'Status: Ready');
set(handles.figure,'Name','Stock Quote Syncroniser');
Position = get(handles.figure,'Position');
Position(4) = Position(4)+100;
set(handles.figure,'Position',Position);

%% table 
handles.textbox = uicontrol(handles.figure);
Position = get(handles.textbox,'Position');
Position(4) = Position(4)+90; %height
Position(3) = Position(3)+260; %width
Position(2) = Position(2)+55; %hiegth from menu
Position(1) = Position(1);
set(handles.textbox,'Position',Position);
set(handles.textbox,'Style','edit');
set(handles.textbox,'Enable','inactive');
set(handles.textbox,'Selected','off');
set(handles.textbox,'Style','edit');
set(handles.textbox,'Max',10000000000);
set(handles.textbox,'HorizontalAlignment','left');

%% Pull Down 
handles.Popupmenu = uicontrol(handles.figure);
Position = get(handles.Popupmenu,'Position');
Position(4) = Position(4)+90; %height
Position(3) = Position(3)+260; %width
Position(2) = Position(2)+80; %hiegth from menu
Position(1) = Position(1);
set(handles.Popupmenu,'Position',Position);
set(handles.Popupmenu,'Style','Popupmenu');
set(handles.Popupmenu,'String',{'All Information';'Summary Only'});
set(handles.Popupmenu,'Callback','LoggingLevelCallback');
global LoggingLevel 
LoggingLevel = 2;
set(handles.Popupmenu,'Value',LoggingLevel);

%% menus
handles.Intergrity = uimenu(handles.figure,'Label','Intergrity');
handles.DoubleEntries = uimenu(handles.Intergrity,'Label','Remove Double Entries','Callback','RemoveAllDoubleEntries');
handles.RemoveAllDataFromDatabase = uimenu(handles.Intergrity,'Label','Delete All Data','Callback','RemoveAllDataFromDatabase');

handles.download = uimenu(handles.figure,'Label','Download');
handles.DownloadEmpty = uimenu(handles.download,'Label','Download Empty','Callback','DownloadEmpty');
handles.DownloadEmpty = uimenu(handles.download,'Label','Update','Callback','DownloadUpdate');

handles.download = uimenu(handles.figure,'Label','Window');
handles.DownloadEmpty = uimenu(handles.download,'Label','Clear Window','Callback','ClearWindow');
handles.DownloadEmpty = uimenu(handles.download,'Label','Save','Callback','SaveWindow');

