function [] = SummaryFigure(String)
%
h.figure = figure;
set(h.figure,'position',[20,100,250,150])
set(h.figure,'Name','Summary');
set(h.figure,'NumberTitle','off');   
set(h.figure,'MenuBar','none');

h.text = uicontrol;
set(h.text,'Style','edit');
set(h.text,'Max',10);
set(h.text,'String',String);
set(h.text,'HorizontalAlignment','left');
set(h.text,'BackgroundColor',[1,1,1]);
set(h.text,'Enable','off');
drawnow
set(h.text,'position',[20,10,200,130]);