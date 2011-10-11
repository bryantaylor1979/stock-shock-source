function [] = BuySellGuide(SaveDataPath)
%
%Written by: Bryan Taylor
%Date Created: 23rd March 2008
%Date Modified: 24th March 2008
SaveDataPath = 'E:\StocksDatabase\';

lookfordatasource = false;

if lookfordatasource == true
    datasources = getdatasources;  
    if isempty(datasources)  %Empty datasources indicates no defined sources
      errordlg('No available data sources.');
      return
    elseif ~iscell(datasources) & datasources == -1
      errordlg('Unable to open ODBC.INI.');
      return
    end

    [s,v] = listdlg('PromptString','Select a database file:',...
                    'SelectionMode','single',...
                    'ListString',datasources);

    if v == 0 %No selection is made
      uiwait(msgbox('No Selection made program will exit'));
      return
    else 
      DatabaseName = datasources{s};
    end
else
    DatabaseName = 'SaxoTrader';
end

global h settings currentdirectory savecriteria
currentdirectory = pwd;

clear savecriteria

% IntialiseDatabase(DatabaseName,'','');
[h.figure] = CreateFigure();
[h.Status] = CreateStatusInfo();
[h.table] = CreateTable();
[h.menu] = CreateMenus(h.figure,h.table);
[h.toolbars] = CreateToolbar(h.figure);
[h.Stage] = CreatStagePopupmenu(currentdirectory);
[h.DatabaseViewer] = CreateDatabaseViewerPopupmenu(currentdirectory);
[h.DatabaseSelection] = CreateDatabaseSelectionPopupmenu(SaveDataPath);
set(h.Status,'String','Ready');

%% Set Callbacks
ToolboxCallback = {'ToolboxCallback',h};
set(h.menu.openproject,'Callback',{'OpenProject',h});
set(h.toolbars.Analysis,'ClickedCallback',[ToolboxCallback,{'Analysis_Callback',currentdirectory}])
set(h.toolbars.Stop,'ClickedCallback',[ToolboxCallback,{'Stop',currentdirectory}])
set(h.toolbars.Report,'ClickedCallback',{'Report',h});
set(h.toolbars.AutoTrade,'ClickedCallback',{'AutoTrade',h});
set(h.menu.loadtable,'Callback',{'LoadTable',h});
set(h.menu.MacroDownloadData,'Callback',{'MacroDownloadData',h});
set(h.toolbars.ConfigMode,'ClickedCallback',{@ConfigMode,h});

set(h.toolbars.Stop,'State','off');

h.path.savedata = SaveDataPath;

set(h.figure,'UserData',h);
load([currentdirectory,'\Profiles\settings'])

function [h] = CreateStatusInfo()
h = uicontrol('Style','text', ...
                     'String','Loading, Please Wait.....', ...
                     'HorizontalAlignment','left');
set(h,'Position',[5,0,200,20]);

function [NewTradeStructure] = Filter(TradeStructure,Name)
%% 

Names = fieldnames(TradeStructure);
TempTradeStructure = struct([]);
SizeOfTradeStruct = size(TradeStructure,2);

x = size(Name,1);

for j = 1:SizeOfTradeStruct
    for i = 1:x
        string = ['TempTradeStructure(',num2str(j),').',Name{i}, '= TradeStructure(',num2str(j),').',Name{i},';'];
        eval(string);
    end
end
NewTradeStructure = TempTradeStructure;

function [startdate,enddate] = VerifyStatus();
%% Verfiy status
global currentdirectory

load([currentdirectory,'\Profiles\BuySellDatabaseStatus'])
load([currentdirectory,'\Profiles\DatabaseStatus'])

if BuySellDatabaseStatus.lastupdated == DatabaseStatus.lastupdated
    startdate = DatabaseStatus.startdate;
    enddate = DatabaseStatus.enddate;
else
    [startdate,enddate] = GetSearchDateLimits;
    %update local database status
    BuySellDatabaseStatus.startdate = startdate; 
    BuySellDatabaseStatus.enddate = enddate;
    BuySellDatabaseStatus.lastupdated = DatebaseStatus.lastupdated;
    DatebaseStatus = BuySellDatabaseStatus;
    save([currentdirectory,'\Profiles\BuySellDatabaseStatus'])
    save([currentdirectory,'\Profiles\DatabaseStatus'])
end

function [h] = CreateFigure()
%% Create Figure
h = figure;
border = 10;
width = 800;
height = 200;
distanceFromBottom = 50;
set(h,'Position',[border,border,width+border*2,height+border*2]);
%% Set Title
set(h,'Name','Trade Guide - New Document.mat');
set(h,'NumberTitle','off');   
set(h,'Resize','on');
set(h,'ResizeFcn','ResizeFcn');
set(h,'MenuBar','none');
BackgroundColour = [0.8314    0.8157    0.7843];
set(h,'Color',BackgroundColour)

function [h] = CreateTable()
%% Create Table
h = uitable();
% set(h,'Editable',0)
border = 10;
width = 821;
height = 200;
distanceFromBottom = 25;
set(h,'Position',[0,distanceFromBottom,width,height-distanceFromBottom-2]);
drawnow;
% tabledata = get(h,'Table');
% set(tabledata,'SelectedRow',41);
% set(tabledata,'AutoResizeMode',0);

function [h] = CreateMenus(h,table)
%% Create Menu's

%File
h1 = h;
h.file = uimenu(h,'Label','File');
h.preferences = uimenu(h.file,'Label','Preferences','Callback','Options');
h.saveprojectas = uimenu(h.file,'Label','Save Project As','Callback','SaveProjectAs');
h.openproject = uimenu(h.file,'Label','Open Project');
h.loadtable = uimenu(h.file,'Label','Load Table');

h.Macros = uimenu(h1,'Label','Macros');
h.MacroDownloadData = uimenu(h.Macros,'Label','Download Data');

% h.Macros = uimenu(h,'Label','Macros');
% h.Continuous = uimenu(h.Macros,'Label','ContinuousDownload','Callback','ContinuousDownload');

function [handles] = CreateToolbar(h1)
%% 
global currentdirectory h 
border = 0;

handles.toolbar = uitoolbar(h1);
ToolboxCallback = {'ToolboxCallback',handles};

[RGB,k] = imread('new_ico.bmp');
RGB = ind2rgb(RGB,k);
RGB = imresize(RGB,[16 16],'nearest');
handles.New = uipushtool(handles.toolbar, ...
                                  'CData',RGB, ... 
                                  'TooltipString','New', ...
                                  'tag','New', ...
                                  'ClickedCallback',[ToolboxCallback,{'New'}]);
                              
[RGB] = imread('save2.png');
RGB = imresize(RGB,[16 16],'nearest');
handles.Save = uipushtool(handles.toolbar, ...
                                  'CData',RGB, ... 
                                  'TooltipString','Save', ...
                                  'tag','Save', ...
                                  'ClickedCallback',[ToolboxCallback,{'Save'}]);
                              
[RGB] = imread('save.png');
RGB = imresize(RGB,[16 16],'nearest');
handles.SaveAs = uipushtool(handles.toolbar, ...
                                  'CData',RGB, ...
                                  'TooltipString','SaveAs', ...
                                  'tag','SaveAs', ...
                                  'ClickedCallback',[ToolboxCallback,{'SaveAs'}]);
                              
[RGB,k] = imread('GuaranteedToRun.gif');
RGB = ind2rgb(RGB,k);
RGB = imresize(RGB,[16 16],'nearest');
handles.Analysis = uitoggletool(handles.toolbar, ... 
                                  'CData',RGB, ... 
                                  'TooltipString','Analysis', ...
                                  'tag','Analysis', ...
                                  'Separator','on');
[RGB] = imread('Stop.png');
RGB = imresize(RGB,[16 16],'nearest');
handles.Stop = uitoggletool(handles.toolbar, ...
                                  'CData',RGB, ...
                                  'TooltipString', 'Stop', ...
                                  'tag','Stop'); 
                              
[RGB] = readicon('rowsetviewer.Ico',0);
handles.Report = uipushtool(handles.toolbar, ...
                                  'CData',RGB, ...
                                  'TooltipString', 'Report', ...
                                  'tag','Report', ...
                                  'Separator','off');
BackgroundColour = [0.8314    0.8157    0.7843];                             
[RGB] = imread('Config.png');

[x,y,z] = size(RGB);
for i = 1:x
   for j = 1:y
       for k = 1:3
           Value = RGB(i,j,k);
           if Value == 0
                RGB(i,j,k) = BackgroundColour(k)*256;
           end
       end
   end
end

handles.ConfigMode = uipushtool(handles.toolbar, ...
                                  'CData',RGB, ...
                                  'TooltipString', 'Config Mode', ...
                                  'tag','ConfigMode', ...
                                  'Separator','off');
                              
[RGB] = readicon('Install.Ico',0);
handles.AutoTrade = uitoggletool(handles.toolbar, ...
                                  'CData',RGB, ...
                                  'TooltipString', 'Enable Auto Trading', ...
                                  'tag','AutoTrade', ...
                                  'Separator','on');                     
                             
function [h] = CreatStagePopupmenu(ProgramDir)
h.text = uicontrol('Style','text', ...
                 'String','Stage Selection: ');
h.pulldown = uicontrol();
set(h.pulldown,'Style','popupmenu');
[functions] = StageDeclaration();

set(h.pulldown,'String',functions);
set(h.pulldown,'enable','on');
set(h.pulldown,'Value',1);

set(h.text,'HorizontalAlignment','left');

set(h.pulldown,'Position',[90,200,160,20]);
set(h.text,'Position',[3,198,80,20]);

set(h.pulldown,'Callback',{@StageUpdateTable,ProgramDir});

function [h] = CreateDatabaseViewerPopupmenu(ProgramDir);

State = 'on';

h.text = uicontrol('Style','text', ...
                 'String','Symbol: ');
h.pulldown = uicontrol();
set(h.pulldown,'Style','popupmenu');
set(h.pulldown,'String',{'N/A'});
set(h.pulldown,'enable',State);
set(h.pulldown,'Value',1);
set(h.pulldown,'Callback',{@DatabaseViewerFcn,h});

set(h.text,'HorizontalAlignment','left');
set(h.text,'enable',State);

set(h.pulldown,'Position',[90+220,200,80,20]);
set(h.text,'Position',[3+260,198,80,20]);

set(h.pulldown,'Callback',{@StageUpdateTable,h,ProgramDir});

function [h] = CreateDatabaseSelectionPopupmenu(ProgramDir);

State = 'on';

h.text = uicontrol('Style','text', ...
                 'String','Database Name: ');
             
h.pulldown = uicontrol();
set(h.pulldown,'Style','popupmenu');

set(h.pulldown,'enable',State);
set(h.pulldown,'Value',1);

set(h.text,'HorizontalAlignment','left');
set(h.text,'enable',State);

%%
path = [ProgramDir];
try
cd(path);
catch
drawnow;
uiwait(msgbox({'Can''t connect to SEAGATE drive';'Please connect the external hardrive';'Application will now close'}))
close all
clear all
return
end
names = struct2cell(dir)';
n = find(cell2mat(names(:,4)) == 1);
names = names(n);
n = find(not(strcmpi(names,'Common')));
names = names(n);
[x] = size(names,1);
names = names(3:x,1);
set(h.pulldown,'String',names);


%%
set(h.pulldown, 'Position',[486,200,80,20]);
set(h.text,     'Position',[403,198,80,20]);

function [RGB] = readicon(Name,Border)
%Written by: Bryan Taylor

global currentdirectory h

[a,b,c] = imread([currentdirectory,'\Icons\',Name]); 
% Augment colormap for background color (white).
BackgroundColour = [0.8314    0.8157    0.7843];
b2 = [b; BackgroundColour]; 
% Create new image for display. 
d = ones(size(a)) * (length(b2) - 1); 
% Use the AND mask to mix the background and
% foreground data on the new image
d(c == 0) = a(c == 0); 
% Display new image 
RGB = ind2rgb(uint8(d),colormap(b2));

%Add border
[x] = size(RGB,1);
TopAndBottom(1:Border,1:x,1) = BackgroundColour(1);
TopAndBottom(1:Border,1:x,2) = BackgroundColour(2);
TopAndBottom(1:Border,1:x,3) = BackgroundColour(3);
newRGB = [TopAndBottom;RGB;TopAndBottom];
LeftAndRight(1:x+Border*2,1:Border,1) = BackgroundColour(1);
LeftAndRight(1:x+Border*2,1:Border,2) = BackgroundColour(2);
LeftAndRight(1:x+Border*2,1:Border,3) = BackgroundColour(3);
RGB = [LeftAndRight,newRGB,LeftAndRight];

RGB = imresize(RGB,[16 16],'nearest');