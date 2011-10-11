function [] = OpenProject(obj,events,h)
%Written by: Bryan Taylor
%Date Created: 5th January 2008

global savecriteria 

path = h.path.savedata
cd([path]);
[filename, pathname] = uigetfile( ...
       {'*.mat';'*.*'}, ...
        'Open Project');
    
if filename == 0 %user didn't select a file
   set(h.Status,'String','Ready');
   drawnow;
   return 
end
    
set(h.Status,'String','Opening Document, Please Wait...')
drawnow;

load([pathname,filename])
set(h.Stage.pulldown,'Value',savecriteria.stage)
Stage = savecriteria.stage

set(h.figure,'Name',['Trade Guide - ',filename]);
drawnow;

% String = get(h.DatabaseSelection.pulldown,'String')
% Value =  get(h.DatabaseSelection.pulldown,'Value')
% Database = String{Value};

% path = [path,Database]
StageUpdateTable(1,h,path)

set(h.Status,'String','Ready');
drawnow;