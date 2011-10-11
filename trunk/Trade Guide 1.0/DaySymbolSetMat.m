function [OutPutArray] = DaySymbolSetMat(varargin)
%
%Written by:    Bryan Taylor
%Date Created:  25th August 2008
%Date Modified: 25th August 2008

mode = 'ReadSavedData';
mode = 'ReadAutoTradeData';
[x] = size(varargin,2);
if x == 1
    datenumber = varargin{1};
    if strcmpi(mode,'ReadSavedData')
        [OutPutArray] = GetStageData('DateRange_Mat');
    else
        Path = ['C:\SourceSafe\Stocks & Shares\Programs\Trade Guide\SaveData\AutoTrade\',num2str(today),'\'];
        cd(Path)
        names = dir;
        name = struct2data(names,'name');
        name1 = strmatch('DateRange_Mat',name);
        name1 = name1(size(name1,1)); %take most recent entry (last)
        load([Path,name{name1}],'Data');
        OutPutArray = Data;
    end
    StartDate = OutPutArray(:,3);
    n = find(not(strcmpi(StartDate,'N/A')));
    OutPutArray = OutPutArray(n,:);
else
    datenumber = varargin{1};
    OutPutArray = varargin{2};
end

%Remove greater than start date
StartDate = datenum(OutPutArray(:,3));
n = find(datenumber>=StartDate);
OutPutArray = OutPutArray(n,:);

%Remove less than end date
NewEndDate = datenum(OutPutArray(:,4));
n = find(datenumber<=NewEndDate);
OutPutArray = OutPutArray(n,:);

%Read symbols to output
OutPutArray = OutPutArray(:,1);