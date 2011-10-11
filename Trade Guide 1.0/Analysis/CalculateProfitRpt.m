function [output] = CalculateProfitRpt(tablehandle);
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

% plot 
global h

Data = get(h.table,'Data');
ColumnName = get(h.table,'ColumnName');

%% Get Parameters
TotalMoney = cell2mat(Data(:,find(strcmpi(ColumnName,'TotalMoney'))));
DateNum = str2num(cell2mat(Data(:,find(strcmpi(ColumnName,'Date')))));

%% Plot Fig
figure, plot(DateNum,TotalMoney,'r:');
datetick
xlabel('Date');
ylabel('Total Money');

%% Yearly Growth
StartDate = min(DateNum);
EndDate = max(DateNum);
count = 1;
while StartDate<EndDate
    EndDateTemp = StartDate + 365;
    
    %
    n = find(DateNum>StartDate);
    WindowedTotalMoney = TotalMoney(n);
    DateNumTemp = DateNum(n);
    
    %
    n = find(DateNumTemp<EndDateTemp);
    WindowedTotalMoney = WindowedTotalMoney(n);
    DateNumTemp = DateNumTemp(n);
    [x] = size(WindowedTotalMoney,1);
    
    PC(count) = WindowedTotalMoney(x)/WindowedTotalMoney(1);
    
    count = count + 1;
    StartDate = StartDate + 365;
end
figure, plot(PC)
ylabel('Percentage Growth');
xlabel('Year');

output = 1;
