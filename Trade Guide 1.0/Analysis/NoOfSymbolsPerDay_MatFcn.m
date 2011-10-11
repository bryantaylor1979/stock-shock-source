function [Output] = NumberOfSymbolsPerDayFcn(varargin)
%Calculate the number of symbols on each day.
%
%InputArray - Output from symbol information.
%Database must be intialised.
%
%Example: 
%IntialiseDatabase;
%[OutPutArray] = SymbolInformation();
%[startdateout,enddateout]=NumberOfSymbolsPerDay(MinimumThreshold,InputArray)
%
%Written by: Bryan Taylor
%Date Created: 3rd January 2008
%Date Modified: 3rd January 2008

global h

%% Column Names Declarations
try
if strcmpi(varargin{1},'ColumnNames')
    Output = {  'Date'; ...
                'DateNum'; ...
                'NoOfSymbols'; ...
                 };
    return
end
end

%% Config Declarations
try
if strcmpi(varargin{1},'Config')
   Output = false; 
   return
end
end

UpdateMode = 'Silent'; %or Visual

%% Functional
MinimumThreshold = 100;
global savecriteria
Names = {   'Date'; ...
            'DateNum'; ...
            'NoOfSymbols'; ...
        };
IntialiseTable(Names);

set(h.table,'Data',{});

display = false;

%% Get Date Range
uiwait(msgbox('This function assumes DataRange_Mat is uptodate'));
[OutPutArray] = GetStageData('DateRange_Mat');

StartDate = OutPutArray(:,3);
n = find(not(strcmpi(StartDate,'N/A')));
LargeOutPutArray  = OutPutArray(n,:);

StartDate = datenum(LargeOutPutArray(:,3));
EndDate = datenum(LargeOutPutArray(:,4));
enddate = max(EndDate);
startdate = min(StartDate);

count2 = 1;
for j = startdate:enddate
    waitfor(h.toolbars.Stop,'State','off');
    set(h.Status,'String',[num2str((j-startdate)/(enddate-startdate)*100,3),'% Complete']);
    drawnow;
    
    [OutPutArray] = DaySymbolSetMat(j,LargeOutPutArray);
    count = size(OutPutArray,1);
    
    Symbols(count2).date = datestr(j);
    Symbols(count2).datenum = j;
    Symbols(count2).NumberOfSymbols = count;
    
    if strcmpi( UpdateMode , 'Visual')
        RowInfo{1,1} = datestr(j);
        RowInfo{1,2} = num2str(j);
        RowInfo{1,3} = num2str(count);
        AddRow(RowInfo);
    else
        RowInfo{count2,1} = datestr(j);
        RowInfo{count2,2} = num2str(j);
        RowInfo{count2,3} = num2str(count);
    end
    count2 = count2 + 1;
end

if strcmpi( UpdateMode , 'Visual')
else
    set(h.table,'Data',RowInfo);
end
set(h.Status,'String',['Ready']);
Output = 1;