function [] = TickerScout()
%Written by:    Bryan Taylor
%Date Created:  28th January 2008
%Date Modified: 28th January 2008

global DatabaseStats h
load DatabaseStats DatabaseStats

[h.figure] = CreateFigure;
[h.tree] = CreateTree(h.figure);
h = uipanel();
[h.startbutton] = CreateStartButton;
[h.stopbutton] = CreateStopButton;
[h.statustext] = StatusText;
[h.textbox] = TextBox;
[h.pulldown] = CreatePulldown;
[h.exchangepulldown] = CreateExchangePulldown;

drawnow;
AddTextStatus('Getting Current Symbol List')
[CurrentSymbolList] = GetCurrentSymbolList();
DatabaseStats.NumberOfSymbolsInDatabase = size(CurrentSymbolList,1);

AddTextStatus('Getting Complete Symbol List')
[CompleteSymbolList] = GetSymbolList('all');
DatabaseStats.TotalNumberOfPossiblities = size(CompleteSymbolList,1);

try
DatabaseStats.DownloadSessions = DatabaseStats.DownloadSessions + 1; 
catch
DatabaseStats.DownloadSessions = 1;     
end

set(h.statustext,'String','Ready');
set(h.startbutton,'Enable','on');
save DatabaseStats DatabaseStats

function [h] = CreatePulldown;
%%
h = uicontrol();
set(h,'Style','popupmenu');
set(h,'String',{'all';'null';'failed'});
set(h,'Position',[5,420,80,20]);
set(h,'Enable','on');

function [h] = CreateExchangePulldown;
%%
h = uicontrol();
set(h,'Style','popupmenu');
set(h,'String',{'all';'null';'failed'});
set(h,'Position',[215,420,100,20]);
set(h,'String',{'US Exchange';'UK Exchange'});
set(h,'Enable','on');

function [h] = CreateStartButton;
%%
h = uicontrol();
set(h,'Style','pushbutton');
set(h,'String','Start');
set(h,'Callback','StartButtonCallback');
set(h,'Position',[400,10,60,20]);
set(h,'Enable','off');

function [h] = CreateStopButton;
%%
h = uicontrol();
set(h,'Style','pushbutton');
set(h,'String','Stop');
set(h,'Callback','StopButton');
set(h,'Position',[465,10,60,20]);
set(h,'Enable','off');

function [h] = StatusText;
%%
h = uicontrol();
set(h,'Style','edit');
set(h,'String','Intialising Database....');
set(h,'Position',[5,10,200,20]);
set(h,'Enable','off');
get(h)
set(h,'HorizontalAlignment','left');

function [h] = TextBox;
%%
h = uicontrol();
set(h,'Style','edit');
set(h,'String','Intialising Database....');
set(h,'Position',[215,40,315,375]);
set(h,'Enable','on');
set(h,'Max',1000);
set(h,'BackgroundColor',[1,1,1]);
set(h,'HorizontalAlignment','left');

function [f] = CreateFigure;
%% Create figure.
f = figure;
set(f,'Resize','on');
set(f,'Name','Ticker Scout');
set(f,'NumberTitle','off');

function [tree] = CreateTree(f)
%% Create tree node
iconpath = [matlabroot, '/toolbox/matlab/icons/expand.gif'];
root = uitreenode('Stats', 'Stats', '', false);
% set(root,'root','on')
% root(2) = uitreenode('descion', 'Buy & Sell', '', false);

tree = uitree('Root', root, 'ExpandFcn', @ExpandFcn);
treehandle = get(tree,'Tree');
set(treehandle,'ShowsRootHandles','on');
set(treehandle,'LargeModel','on')
% set(treehandle,'rootVisible','off');
set(f,'MenuBar','none');
set(f,'Position',[232,248,542,442]);
width = 200;
set(tree,'Position',[5,40,width,375]);