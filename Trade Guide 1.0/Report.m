function [] = Report(obj,event,handles)

global savecriteria

%% Run Analysis
Stage = get(handles.Stage.pulldown,'Value');
% GuiStruct = savecriteria.GuiStruct;

set(handles.Status,'String','Analysis Of Table, Please Wait...')
drawnow;

%% Get Stage Name
String = get(handles.Stage.pulldown,'String');
Value = get(handles.Stage.pulldown,'Value');
Selection = String{Value};

output = feval([Selection,'Rpt'],handles.table);
% TableHandle = handles.table;
% location = publish('WriteReport');

% %% Save Information
% GuiStruct(Stage).rptoutput = output;
% savecriteria.GuiStruct = GuiStruct;

set(handles.Status,'String','Ready')
