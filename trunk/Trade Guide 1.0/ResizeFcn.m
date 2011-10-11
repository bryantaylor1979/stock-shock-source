function [] = ResizeFcn()

global h

%% Create Figure
distanceFromBottom = 25;
distanceFromTop = 25;

Position = get(h.figure,'Position');
figuresize = Position;
Position(1) = 0;
Position(2) = distanceFromBottom;
Position(4) = Position(4) - distanceFromBottom - distanceFromTop;

try
set(h.table,'Position',Position);

% Move stage pulldown
pulldownsize = get(h.Stage.pulldown,'Position');
pulldownsize(2) = figuresize(4)-20;
set(h.Stage.pulldown,'Position',pulldownsize);

% Move stage pulldown
textsize = get(h.Stage.text,'Position');
textsize(2) = figuresize(4)-23;
set(h.Stage.text,'Position',textsize);

% Move stage pulldown
pulldownsize = get(h.DatabaseViewer.pulldown,'Position');
pulldownsize(2) = figuresize(4)-20;
set(h.DatabaseViewer.pulldown,'Position',pulldownsize);

% Move stage pulldown
textsize = get(h.DatabaseViewer.text,'Position');
textsize(2) = figuresize(4)-23;
set(h.DatabaseViewer.text,'Position',textsize);

%% Move Database Name pulldown.
pulldownsize = get(h.DatabaseSelection.pulldown,'Position');
pulldownsize(2) = figuresize(4)-20;
set(h.DatabaseSelection.pulldown,'Position',pulldownsize);

textsize = get(h.DatabaseSelection.text,'Position');
textsize(2) = figuresize(4)-23;
set(h.DatabaseSelection.text,'Position',textsize);
end
