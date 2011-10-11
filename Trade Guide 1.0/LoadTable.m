function [] = LoadTable(obj,event,handles)
%
%Written by:    Bryan Taylor
%Date Created:  2nd July 2008

global h currentdirectory savecriteria

cd([currentdirectory,'\SaveData\Download'])
[filename, pathname, filterindex] = uigetfile( ...
       {'*.mat','MAT-files (*.mat)'}, ...
        'Pick a file', ...
        'MultiSelect', 'off');
load([pathname,filename])

Names = feval(['DownloadFcn'],'ColumnNames');
IntialiseTable(Names);
set(h.table,'Data',Data);

% Set Mode
[functions] = StageDeclaration();
Stage = find(strcmpi(functions,'Download'));
set(h.Stage.pulldown,'Value',Stage);

%% Save Information
GuiStruct(Stage).tabledata = get(h.table,'Data');
GuiStruct(Stage).stagename = functions{Stage};
savecriteria.GuiStruct = GuiStruct;
savecriteria.stage = Stage;
savecriteria.currentstagename = functions{Stage}; 