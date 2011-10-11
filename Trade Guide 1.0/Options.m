function [] = Options();
global handles DatabaseNames
f = figure;
set(f,'Resize','off');
set(f,'Name','Preferences');
set(f,'NumberTitle','off');

iconpath = [matlabroot, '/toolbox/matlab/icons/expand.gif'];
root = uitreenode('options', 'options', '', false);
% set(root,'root','on')
% root(2) = uitreenode('descion', 'Buy & Sell', '', false);

tree = uitree('Root', root, 'ExpandFcn', @myExpfcn);
treehandle = get(tree,'Tree');
set(treehandle,'ShowsRootHandles','on');
set(treehandle,'LargeModel','on')
% set(treehandle,'rootVisible','off');
set(f,'MenuBar','none');
set(f,'Position',[232,248,542,442]);
set(tree,'Position',[5,40,155,400]);

CreateButtons
CreateHeader
CreateDescionPanel

h.DatabaseObject = uicontrol();
set(h.DatabaseObject,'String',{'Local Database';'Cached Database'})
set(h.DatabaseObject,'Style','popupmenu')
set(h.DatabaseObject,'Position',[220,180,150,20]);

h.Database = uicontrol();
set(h.DatabaseObject,'String',DatabaseNames)
set(h.DatabaseObject,'Style','popupmenu')
set(h.DatabaseObject,'Position',[220,140,150,20]);

%store handles
handles.figure = f;

%load defaults
load settings settings
set(handles.descion.MinThreshold,'String',num2str(settings.descion.MinThreshold ));
set(handles.descion.MinThresholdEnable,'Value',settings.descion.MinThresholdEnable);
if settings.descion.MinThresholdEnable == 1
    set(handles.descion.MinThreshold,'Enable','on');
else 
    set(handles.descion.MinThreshold,'Enable','off');
end
set(handles.descion.ForceRefresh,'Value',settings.descion.ForceRefresh);
set(handles.descion.NoOfInvestments,'String',num2str(settings.descion.NoOfInvestments));

switch lower(settings.descion.ComObject)
    case 'cached'
       set(h.DatabaseObject,'Value',2) 
    case 'local'
       set(h.DatabaseObject,'Value',1)  
    otherwise
        
end

function [] = CreateDescionPanel()
% Descion Panel
handle.descion.panel = uipanel();
ThresholdGroupCreate();


function [] = ThresholdGroupCreate();
%This is a group of controls within the descion block selection
global handles

checkbox.width = 180;
heightall = 20;
text.width = 80;
edit.width = 50;
group.x = 180; %distance from left
group.y = 345; %distance from bottom
pulldown2textspace = 10;
text2editspace = 10;

handle.descion.uipanel = uipanel();
set(handle.descion.uipanel,'position',[0.31,0.74,0.675,0.15]);
set(handle.descion.uipanel,'Title','Min Threshold')

% mode
%text
handle.descion.text1 = uicontrol();
set(handle.descion.text1, ...
        'Style','text', ...
        'position',[group.x,group.y-3 ,text.width,heightall], ...
        'String','Min Threshold:');

%edit
handle.descion.edit1 = uicontrol();
editoffset = group.x+text.width+text2editspace;
set(handle.descion.edit1, ...
        'Style','edit', ...
        'HorizontalAlignment','left', ...
        'position',[280,group.y ,edit.width,heightall], ...
        'String','100');
    
% MinimumThreshold
handle.descion.modepulldown = uicontrol();
tickboxoffset = editoffset + edit.width + 20;
set(handle.descion.modepulldown, ...
        'Style','checkbox', ...
        'position',[tickboxoffset,group.y ,checkbox.width,heightall], ...
        'Callback','MinThreshold_Enable', ...
        'Value', 1, ...
        'String',{'Enable Minimum Threshold'});
    
% report
% number_of_investments
handle.descion.uipanel2 = uipanel();
set(handle.descion.uipanel2,'position',[0.31,0.55,0.675,0.15]);
set(handle.descion.uipanel2,'Title','No Of Investments');

%text
text2 = uicontrol();
set(text2, ...
        'Style','text', ...
        'String','No Of Investments:');
set(text2,'position',[177,255,100,20]);

%edit
edit1 = uicontrol();
set(edit1, ...
        'Style','edit', ...
        'HorizontalAlignment','left', ...
        'String','10');
set(edit1,'position',[280,260,50,20]);

% MinimumThreshold
tickbox = uicontrol();
set(tickbox, ...
        'Style','checkbox', ...
        'String',{'Force Refresh'});
set(tickbox,'position',[340,260,100,20]);

%global handles
handles.descion.MinThresholdEnable = handle.descion.modepulldown;
handles.descion.MinThreshold = handle.descion.edit1;
handles.descion.ForceRefresh = tickbox;
handles.descion.NoOfInvestments = edit1;

function [] = CreateHeader();
%header
handle.descion.text1 = uicontrol();
width = 372;
height = 28;
set(handle.descion.text1, ...
        'Style','text', ...
        'String',{'';' Preferences'}, ...
        'FontWeight','bold', ...
        'BackgroundColor',[0.82549 0.813725 0.70059], ...
        'HorizontalAlignment','left');
set(handle.descion.text1,'position',[165,411,width,height]);

function [] = CreateButtons();
%create buttons
global handles
distance2bottom = 7;

handles.help = uicontrol('String','Help');
set(handles.help,'Position',[486,distance2bottom,54,24]);
set(handles.help,'Callback','Help_Callback');

handles.apply = uicontrol('String','Apply');
set(handles.apply,'Position',[420,distance2bottom,61,24]);
set(handles.apply,'Callback','Apply_Callback');

handles.cancel = uicontrol('String','Cancel');
set(handles.cancel,'Position',[349,distance2bottom,65,24]);
set(handles.cancel,'Callback','Cancel_Callback');

handles.ok = uicontrol('String','OK');
set(handles.ok,'Position',[296,distance2bottom,48,24]);
set(handles.ok,'Callback','OK_Callback');


