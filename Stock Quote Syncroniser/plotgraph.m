function [varargout] = plotgraph(varargin)
%plot
[x] = size(varargin,2);
if x == 1
    NumberOfDaysOutOfSync = varargin{1};
elseif x == 2
    h = varargin{1};
    NumberOfDaysOutOfSync = varargin{2};
else
    error('');
end

for i = 1:7
    n = find(cell2mat(NumberOfDaysOutOfSync) == i-1);
    AmountOfSymbols(i) = size(n,1);
    DayOutOfSync(i) = i-1;
end
if  exist('h')
    set(h.line,'XDATA',DayOutOfSync);
    set(h.line,'YDATA',AmountOfSymbols);
else
    h.figure = figure; 
    h.line = plot(DayOutOfSync,AmountOfSymbols);
    h.dcm_obj = datacursormode(h.figure);
    xlabel('Number Of Days');
    ylabel('Number Of Symbols');
    set(h.figure,'NumberTitle','off');
    set(h.figure,'Name','Update Status');
    set(h.dcm_obj,    'DisplayStyle','datatip',...
                     'SnapToDataVertex','off','Enable','on',...
                     'Updatefcn',@UpdateCursor);                 
end

if x == 1
    varargout{1} = h;
elseif x == 2
    varargout{1} = [];
else
    error('')
end