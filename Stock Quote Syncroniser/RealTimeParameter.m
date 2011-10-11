function [varargout] = RealTimeParameter(varargin)

[x] = size(varargin,2);

if x == 1 %intialise
    
    %read values
    Struct = varargin{1};

    names = fieldnames(Struct);
    [x] = size(names,1);
    
    handles.figure = figure;
    for i = 1:x
    [h(i)] = intplot(Struct,names{i});
    colour = [0, 0, 0];
    colour(i) = 1;
    set(h(i).line,'Color',colour)
    end
    set(handles.figure,'Name',['History of Update'])
    maxi = max(cell2mat(Struct2Data(h(i),'maxi')));
    set(h(1).axes,'Ylim',[0,maxi+1]);
    legend(names)
elseif x == 2 %update
    h = varargin{1};
    Struct = varargin{2};
    
    %read values
    names = fieldnames(Struct);
    [x] = size(names,1);
 
    for i = 1:x
        [h(i)] = updateplot(h(i),Struct,names{i});
    end
    maxi = max(cell2mat(Struct2Data(h(i),'maxi')));
    set(h(1).axes,'Ylim',[0,maxi+1]);       
else
    
end
varargout = {h};
drawnow

function [h] = intplot(Struct,parameter)
value = getfield(Struct,parameter);
h.xdata = [0,value];
h.ydata = [now-0.0001,now];
hold on
h.line = plot(h.ydata,h.xdata);
h.axes = gca;
xlabel('Time (24H)')
ylabel(['Number ',parameter])
h.maxi = max(h.xdata);
set(h.axes,'Xlim',[min(h.ydata),today+1])
datetick

function [h] = updateplot(h,Struct,parameter)
value = getfield(Struct,parameter);
h.ydata = [h.ydata,now];
h.xdata = [h.xdata,value];
set(h.line,'YData',h.xdata);
set(h.line,'XData',h.ydata);
set(h.axes,'Xlim',[min(h.ydata),today+1])
datetick
h.maxi = max(h.xdata);