function [startdateout,enddateout] = NumberOfSymbolsPerDay(h,MinimumThreshold,OutPutArray)
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
global h savecriteria
Names = {   'Date'; ...
            'DateNum'; ...
            'NoOfSymbols'; ...
        };
IntialiseTable(Names);

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
    set(h.Status,'String',[num2str((j-startdate)/(enddate-startdate)*100,2),'% Complete'])
    
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
    
    RowInfo{1,1} = datestr(j);
    RowInfo{1,2} = num2str(j);
    RowInfo{1,3} = num2str(count);
    AddRow(RowInfo);
end

savecriteria.NoOfSymbolsPerDay = Symbols;
savecriteria.NoOfSymbolsPerDayjavaobject = get(h.table,'Data');

if display == true
   % plot data
   Data = cell2mat(Struct2Data(Symbols,'NumberOfSymbols'));
   Date = cell2mat(Struct2Data(Symbols,'datenum'));
   h.figure = figure;
   h.line = plot(Date,Data,'r-');
   datetick;
   xlabel('Date');
   ylabel('Number Of Symbols');
   title('Number Of Symbols Vs Date')
   set(h.figure,'Name','Number Of Symbols');
   set(h.figure,'NumberTitle','off');
   
   % Find approved date range
   n = find(Data>100);
   LargerThanOneHundred = Date(n);
   [x] = size(LargerThanOneHundred,1);
   string = {['Recommended Analysis Window:'];...
             ['Minimum Threshold: ',num2str(MinimumThreshold)];...
             ['Start Date: ',datestr(LargerThanOneHundred(1))];...
             ['End Date: ',datestr(LargerThanOneHundred(x))]};
   text(Date(1),100,string);
   grid off
end
startdateout = LargerThanOneHundred(1);
enddateout = LargerThanOneHundred(x);

set(h.Status,'String',[num2str((j-startdate)/(enddate-startdate)),'% Complete']);