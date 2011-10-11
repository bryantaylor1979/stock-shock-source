function [output] = DateRangeRpt(tablehandle)
%Summary of information
%
%Written by:    Bryan Taylor
%Date Created:  1st April 2008
%Date Modified: 1st April 2008

% OutPutArray = savecriteria.symbolinfotable;
Status = GetStageData('DateRange','Status');
StartDate = GetStageData('DateRange','Start Date');
EndDate = GetStageData('DateRange','End Date');

%time to process
DateTime = GetStageData('DateRange','Date/Time Processed');
[x] = size(DateTime,1);
TimeProcessed = datenum(DateTime{1}) - datenum(DateTime{x});
DateStr = datestr(TimeProcessed+1,13);

full = find(strcmpi('full',Status));
FullCount = size(full,2);

empty = find(strcmpi('empty',Status));
EmptyCount = size(empty,2);

StartDates = datenum(StartDate(full));
EndDates = datenum(EndDate(full));

NoOfDays_OutOfDate = GetStageData('DateRange','NoOfDays_OutOfDate');
% NoOfDays_OutOfDate = cell2mat(GetTableData(tablehandle,'NoOfDays_OutOfDate'));
[x] = size(NoOfDays_OutOfDate,1);

for i = 5147:x-2
   if not(ischar(NoOfDays_OutOfDate{i}))
    NoOfDays_OutOfDate_Num(i) = NoOfDays_OutOfDate{i};
   else
    NoOfDays_OutOfDate_Num(i) = NaN;    
   end
end

Days0 = size(find(NoOfDays_OutOfDate_Num == 0),2);
Days1 = size(find(NoOfDays_OutOfDate_Num == 1),2);
Days2 = size(find(NoOfDays_OutOfDate_Num == 2),2);
Days3 = size(find(NoOfDays_OutOfDate_Num == 3),2);
Days3p = size(find(NoOfDays_OutOfDate_Num > 3),2);

String = {'Table Summary:'; ...
          '=============='; ...
          ['Full Tables: ',num2str(FullCount)]; ... 
          ['Empty Tables: ',num2str(EmptyCount)]; ...
          ['Total No Of Tables: ',num2str(FullCount+EmptyCount)]; ...
          ''; ...
          'Database Date Range: '; ...
          ['Start Date: ',datestr(min(StartDates))]; ...
          ['End Date: ',datestr(max(EndDates))]; ...
          ''; ...
          'Days Old'; ...
          '========'; ...
          ['0 Day old: ',num2str(Days0)]; ...
          ['1 Day old: ',num2str(Days1)]; ...
          ['2 Days old: ',num2str(Days2)]; ...
          ['3 Days old: ',num2str(Days3)]; ...
          ['3+ Days old: ',num2str(Days3p)]; ...
          ''; ...
          ['Time to Process: ',num2str(DateStr)]; ...
          };
      
h = figure;
Position = get(h,'Position');
Position(3) = Position(3)*1.3;
set(h,'Position',Position)

pie([Days0 Days1 Days2 Days3 Days3p],{'0 Day old','1 Day old','2 Days old','3 Days old','3+ Days old'})
set(h,'Name','Pie Chart Of Data Staleness', ...
      'NumberTitle','off')
  
text(-2.4,0,String)
      
output.NoOfFullTables = FullCount;
output.NoOfEmptyTables = EmptyCount;
output.TotalNoOfTables = FullCount + EmptyCount;

output.StartDateDateNum = min(StartDates);
output.StartDateStr = datestr(output.StartDateDateNum);
output.EndDateDateNum = max(EndDates);
output.EndDateStr = datestr(output.EndDateDateNum);