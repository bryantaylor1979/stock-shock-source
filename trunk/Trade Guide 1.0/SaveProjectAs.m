function [] = SaveProjectAs()
%SaveProjectAs - Save all data in project.
%Date Created:      4th January 2007
%Written by:        Bryan Taylor

mode = 'old';
global h savecriteria status currentdirectory
set(h.Status,'String','Saving Document, Please Wait...');

if strcmpi(mode,'old')
    savecriteria.stage = get(h.Stage.pulldown,'Value');
    savecriteria.status = status;
    try
    status = savecriteria.status;
    end
else
    
end

cd([currentdirectory,'\SaveData\']);

[filename, pathname] = uiputfile( ...
       {'*.mat';}, ...
        'Save Project As');
    
set(h.figure,'Name',['Trade Guide - ',filename]);    
save([pathname,filename],'savecriteria')
set(h.Status,'String','Ready');