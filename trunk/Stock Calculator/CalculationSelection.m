function [] = CalculationSelection();
%Written by:    Bryan Taylor
%Date Created:  4th March 2008

global h

[h.figure] = CreateFigure();

Border.Bottom = 50;
Border.Top = 10;
Border.Sides = 10;
ListBoxWidth = 180;
ListBoxHeight = 400;
ListboxSpacing = 100;

CompleteList = CalculationDeclartion;
load CalcSetting CalcSetting

%Remove selected
Selected = CalcSetting.CalculationsSelected;
if ischar(Selected)
    NewSelected{1} = Selected;  
else
    NewSelected = Selected; 
end
[x] = size(NewSelected,1);
for i = 1:x
    n = find(not(strcmp(NewSelected{i},CompleteList)));
    CompleteList = CompleteList(n);
end

h.CompleteListbox = uicontrol(  'Style','listbox', ...
                                'Position',[Border.Sides,Border.Bottom,ListBoxWidth,ListBoxHeight], ...
                                'String',CompleteList);
                    
h.SelectedListbox = uicontrol(  'Style','listbox', ...
                                'Position',[Border.Sides+ListBoxWidth+ListboxSpacing,Border.Bottom,ListBoxWidth,ListBoxHeight]);
                            
h.AddButton = uicontrol(   'Style','pushbutton', ...
                           'String','Add>', ...
                           'Callback','AddButton');                   
set(h.AddButton,'Position',[210,300,60,30]);

h.RemoveButton = uicontrol('Style','pushbutton', ...
                           'String','<Remove', ....
                           'Callback','RemoveButton');
set(h.RemoveButton,'Position',[210,150,60,30]);

h.OkButton = uicontrol('Style','pushbutton', ...
                           'String','OK', ....
                           'Enable','on', ...
                           'Callback','SaveButton');
set(h.OkButton,'Position',[400,10,60,30]);

h.CancelButton = uicontrol('Style','pushbutton', ...
                           'String','Cancel', ...
                           'Callback','close');
set(h.CancelButton,'Position',[330,10,60,30]);

%load current settings
String = CalcSetting.CalculationsSelected;
set(h.SelectedListbox,'String',String);
                            
Position = get(h.figure,'Position');
Position(3) = Border.Sides*2+ListBoxWidth*2+ListboxSpacing;
Position(4) = Border.Bottom+Border.Top+ListBoxHeight;
set(h.figure,'Position',Position);

function [f] = CreateFigure()
f = figure;
set(f,'MenuBar','none');
set(f,'NumberTitle','off');
set(f,'Name','Calculation Selection');
set(f,'Resize','off')