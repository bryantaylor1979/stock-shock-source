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

Mode = 'Mat'; %or Access
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

if strcmpi(Mode,'Mat')
    [OutPutArray] = GetStageData('DateRange');
else
    [OutPutArray] = GetStageData('DateRange_Mat');
end

display = false;
[x] = size(OutPutArray,1);
count = 1;
for i = 1:x
    try
        StartDate(count) = datenum(OutPutArray(i,3));
        EndDate(count) = datenum(OutPutArray(i,4));
        count = count + 1;
    end
end
enddate = max(EndDate);
startdate = min(StartDate);

% StatusBar(h.statusbar,0);
count2 = 1;
for j = startdate:enddate
%     StatusBar(h.statusbar,(j-startdate)/(enddate-startdate));
    waitfor(h.toolbars.Stop,'State','off');
    set(h.Status,'String',[num2str((j-startdate)/(enddate-startdate)*100,3),'% Complete']);
    
    n = find(j>=StartDate);
    NewStartDate = StartDate(n);
    NewEndDate = EndDate(n);
    
    n = find(j<=NewEndDate);
    count = size(n,2);
    
    Symbols(count2).date = datestr(j);
    Symbols(count2).datenum = j;
    Symbols(count2).NumberOfSymbols = count;
    count2 = count2 + 1;
%     DispStruct(Symbols(j),'all');
    
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
end

if strcmpi( UpdateMode , 'Visual')
else
    set(h.table,'Data',RowInfo);
end
set(h.Status,'String',['100% Complete']);
Output = 1;