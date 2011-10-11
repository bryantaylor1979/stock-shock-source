function [output] = DescionRpt(tablehandle);
%Written by:    Bryan Taylor
%Date Created:  4th May 2008
%Date Modified: 4th May 2008
[startdateout] = GetResult('NoOfSymbolsPerDay','StartDate');
[enddateout] = GetResult('NoOfSymbolsPerDay','EndDate');

Datenum = GetTableData(tablehandle,'DateNum');
if iscell(Datenum)
   Datenum = str2double(Datenum);
end
Currentstartdate = max(Datenum)+1

TotalNoOfDays = enddateout-startdateout;
PercentageProgress = round((Currentstartdate - startdateout)/TotalNoOfDays*10000)/100;

String = {['StartDate: ',datestr(startdateout)];...
          ['EndDate: ',datestr(enddateout)];...
          ['CurrentDate: ',datestr(Currentstartdate)];...
          ['Total Number Of Days: ',num2str(TotalNoOfDays)];...
          ['PercentageProgress: ',num2str(PercentageProgress),'%']};
      
output.StartDateStr = datestr(startdateout);
output.EndDateStr = datestr(enddateout);
output.StartDate = startdateout;
output.EndDate = enddateout;
output.CurrentDateStr = datestr(Currentstartdate);
output.CurrentDate = Currentstartdate;
      
SummaryFigure(String);