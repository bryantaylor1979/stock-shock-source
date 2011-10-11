function [] = DescionStatus();

global savecriteria
[startdateout,enddateout] = NoOfSymbolsPlot(false);
Currentstartdate = savecriteria.DescionCurrentDate;
TotalNoOfDays = enddateout-startdateout;
PercentageProgress = round((Currentstartdate - startdateout)/TotalNoOfDays*10000)/100;

String = {['StartDate: ',datestr(startdateout)];...
          ['EndDate: ',datestr(enddateout)];...
          ['CurrentDate: ',datestr(Currentstartdate)];...
          ['Total Number Of Days: ',num2str(TotalNoOfDays)];...
          ['PercentageProgress: ',num2str(PercentageProgress),'%']};
SummaryFigure(String);