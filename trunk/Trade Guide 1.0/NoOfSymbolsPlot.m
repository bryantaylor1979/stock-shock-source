function [startdateout,enddateout] = NoOfSymbolsPlot(varargin);
%MinimumThreshold (Default: 100, Class: Double/Int)
%This is the minimum number of ticker symbols available on the day of investments. 
%This is usefull to remove the older stats which only have 2-3 stocks avaiable for
%investment. 
%
%Written by: Bryan Taylor
%Date Created: 6th January 2008
%Date Modified: 6th January 2008

report = true;
if isempty(varargin)  
else
    report = varargin{1};
end

global savecriteria settings
if settings.descion.MinThresholdEnable == true
    MinimumThreshold = settings.descion.MinThreshold;
else 
    MinimumThreshold = 0;
end
Symbols = savecriteria.NoOfSymbolsPerDay;

% plot data
Data = cell2mat(Struct2Data(Symbols,'NumberOfSymbols'));
Date = cell2mat(Struct2Data(Symbols,'datenum'));

% Find approved date range
n = find(Data>MinimumThreshold);
LargerThanOneHundred = Date(n);
LargerThanOnHundredData = Data(n);
[x] = size(LargerThanOneHundred,1);

string = {['Recommended Analysis Window:'];...
         ['Minimum Threshold: ',num2str(MinimumThreshold)];...
         ['Start Date: ',datestr(LargerThanOneHundred(1))];...
         ['End Date: ',datestr(LargerThanOneHundred(x))]};
grid off

startdateout = LargerThanOneHundred(1);
enddateout = LargerThanOneHundred(x);

if report == true
h.figure = figure;
h.arealine = area(LargerThanOneHundred,LargerThanOnHundredData);
hold on
h.line = plot(Date,Data,'r-');
datetick;
hold on
h.areadottenlinemin = plot([LargerThanOneHundred(1),LargerThanOneHundred(1)],[0,LargerThanOnHundredData(1)],'k:')
hold on
[x] = size(LargerThanOnHundredData,1);
h.areadottenlinemax = plot([LargerThanOneHundred(x),LargerThanOneHundred(x)],[0,LargerThanOnHundredData(x)],'k:')
xlabel('Date');
ylabel('Number Of Symbols');
title('Number Of Symbols Vs Date')
set(h.figure,'Name','Number Of Symbols');
set(h.figure,'NumberTitle','off');
set(h.arealine,'FaceColor',[0.9,0.9,0.9])
set(h.arealine,'EdgeColor',[0,0,0]);
set(h.arealine,'LineStyle','none');
text(Date(1),100,string);
h.axes = gca;
YLim = get(h.axes,'YLim');
YLim(1) = 0;
set(h.axes,'YLim',YLim);
end