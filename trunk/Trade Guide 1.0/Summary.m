function [] = Summary()
%Summary of information
global savecriteria

OutPutArray = savecriteria.symbolinfotable;

[x] = size(OutPutArray,1);
FullCount = 0;
EmptyCount = 0;

Count = 1;
for i = 1:x
    if strcmp(OutPutArray{i,2},'FULL')
        FullCount = FullCount + 1;
        StartDates(Count) = datenum(OutPutArray{i,3});
        EndDates(Count) = datenum(OutPutArray{i,4});
        Count = Count + 1;
    else
        EmptyCount = EmptyCount + 1;
    end
end



String = {['Table Summary:']; ...
          ['Full Tables: ',num2str(FullCount)]; ... 
          ['Empty Tables: ',num2str(EmptyCount)]; ...
          ['Total No Of Tables: ',num2str(FullCount+EmptyCount)]; ...
          ['']; ...
          ['Database Date Range: ']; ...
          ['Start Date: ',datestr(min(StartDates))]; ...
          ['End Date: ',datestr(max(EndDates))]};

SummaryFigure(String);
