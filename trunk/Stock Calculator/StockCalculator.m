function [] = StockCalculator()
% Stock Calulator
global handles Status

addpath('C:\SourceSafe\Stocks & Shares\Programs\Trade Guide\Callback');
addpath('C:\SourceSafe\Stocks & Shares\Programs\Stock Calculator\Calculations');
addpath('C:\SourceSafe\Stocks & Shares\Programs\Stock Calculator\SharedFiles');
addpath('C:\SourceSafe\Stocks & Shares\Programs\Stock Calculator');

Status = 'Ready';
IntialiseDatabase;

[h.figure] = CreateFigure;
% h = uipanel;

load CalcSetting CalcSetting
Calculation = CalcSetting.CalculationsSelected;

subplot(2,1,1); handles.totalprogress = waitbar2(0);
subplot(2,1,2); handles.taskprogress = waitbar2(0);

DistanceFromLeftAndRight = 0.13;
Spacing = 0.3;
DistanceFromBottom = 0.1;

width = 1 - DistanceFromLeftAndRight*2;
set(handles.totalprogress.axis,'position',[DistanceFromLeftAndRight,DistanceFromBottom+Spacing,width,0.34]);
set(handles.taskprogress.axis,'position',[DistanceFromLeftAndRight,DistanceFromBottom,width,0.34]);

DistanceFromBottom = 150;
DistanceFromLeft = 75;
handles.symboltext = uicontrol( 'Style','text', ...
                                'position',[DistanceFromLeft,DistanceFromBottom,400,15], ...
                                'String','Analysis Of Available Symbols....           ', ...
                                'HorizontalAlignment','left');
                            
handles.tasktext = uicontrol( 'Style','text', ...
                                'position',[DistanceFromLeft,DistanceFromBottom-70,400,15], ...
                                'String',['Progress: 0 of 0'], ...
                                'HorizontalAlignment','left');  
tic;                                
handles.elapsedtime = uicontrol( 'Style','text', ...
                                'position',[DistanceFromLeft+300,DistanceFromBottom-140,200,15], ...
                                'String',['Elapsed Time: '], ...
                                'HorizontalAlignment','left');
                            
f = uimenu('Label','File');
uimenu(f,'Label','Calculation Selection','Callback','CalculationSelection');

%% Start Button
handles.startbutton = uicontrol( 'Style','pushbutton', ...
                                'String',['Start'], ...
                                'Callback','StartButton', ...
                                'Enable','on', ...
                                'HorizontalAlignment','left');
set(handles.startbutton,'position',[76,10,60,20]);
    
%% Pause Button
handles.pausebutton = uicontrol('Style','pushbutton', ...
                                'String',['Pause'], ...
                                'Callback','PauseButton', ...
                                'Enable','off', ...
                                'HorizontalAlignment','left');
set(handles.pausebutton,'position',[141,10,60,20]);

%% Stop Button
handles.stopbutton = uicontrol('Style','pushbutton', ...
                                'String',['Stop'], ...
                                'Callback','StopButton', ...
                                'Enable','off', ...
                                'HorizontalAlignment','left');
set(handles.stopbutton,'position',[206,10,60,20]);

drawnow;

function [f] = CreateFigure;
% Create Figure

f = figure;
height = 220;
set(f,'Position',[232,248,560,height]);
set(f,'MenuBar','none');
set(f,'NumberTitle','off');
set(f,'Name','Stock Calculator');