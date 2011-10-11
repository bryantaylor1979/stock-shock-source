function [output] = NoOfSymbolsPerDay_MatRpt(varargin);
%MinimumThreshold (Default: 100, Class: Double/Int)
%This is the minimum number of ticker symbols available on the day of investments. 
%This is usefull to remove the older stats which only have 2-3 stocks avaiable for
%investment. 
%
%Example 1: No Inputs
%NoOfSymbolsPlot();
%
%Example 2: Report information in matlab comman space.
%NoOfSymbolsPlot(true);
%
%Written by:    Bryan Taylor
%Date Created:  6th January 2008
%Date Modified: 6th January 2008

global settings
if settings.descion.MinThresholdEnable == true
    MinimumThreshold = settings.descion.MinThreshold;
else 
    MinimumThreshold = 0;
end
MinimumThreshold = 100;

% plot 
Data = GetStageData('NoOfSymbolsPerDay_Mat','NoOfSymbols');
Data = str2double(Data);
Date = datenum(GetStageData('NoOfSymbolsPerDay_Mat','Date'));

% Find approved date range
n = find(Data>MinimumThreshold);
LargerThanOneHundred = Date(n);
LargerThanOnHundredData = Data(n);

startdateout = min(LargerThanOneHundred);
enddateout = max(LargerThanOneHundred);

string = { ['Recommended Analysis Window:'];...
           ['Minimum Threshold: ',num2str(MinimumThreshold)];...
           ['Start Date: ',datestr(startdateout)];...
           ['End Date: ',datestr(enddateout)]};
% grid off
settings.startdate = startdateout;
settings.enddate = enddateout;

%% Plot Data
h.figure = figure;
h.arealine = area(LargerThanOneHundred,LargerThanOnHundredData);
hold on
h.line = plot(Date,Data,'r-');
datetick;
hold on
h.areadottenlinemin = plot([LargerThanOneHundred(1),LargerThanOneHundred(1)],[0,LargerThanOnHundredData(1)],'k:');
hold on
[x] = size(LargerThanOnHundredData,1);
h.areadottenlinemax = plot([LargerThanOneHundred(x),LargerThanOneHundred(x)],[0,LargerThanOnHundredData(x)],'k:');
xlabel('Date');
ylabel('Number Of Symbols');
title('Number Of Symbols Vs Date')
set(h.figure,'Name','Number Of Symbols');
set(h.figure,'NumberTitle','off');
set(h.arealine,'FaceColor',[0.9,0.9,0.9])
set(h.arealine,'EdgeColor',[0,0,0]);
set(h.arealine,'LineStyle','none');
text(Date(1),max(Data)*0.8,string);
h.axes = gca;
YLim = get(h.axes,'YLim');
YLim(1) = 0;
set(h.axes,'YLim',YLim);

output.StartDate = startdateout;
output.EndDate   = enddateout;
output.MinThreshold = MinimumThreshold;
