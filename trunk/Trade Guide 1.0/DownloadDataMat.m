function [DataStore,timedout,Info] = DownloadData(symbol,DateRange)
%Download Data

mode = 'yahoo-fetch'; %yahoo-fetch

%Var
if ischar(DateRange)
    Range = 365*200; %Last 200 years
    StartDate = today-Range;
    EndDate = today;
else
    StartDate = DateRange(1);
    EndDate = DateRange(2);
end
timeout = 2;

%Int Var
timedout = false;
time = 1;
DataStore=[];
complete = false;

%Get Data
%TODO: Exception workaround!
if strcmpi(symbol,'CLF') %Exception call clf function!
    timedout = true;
    DataStore=[];
else
    while complete == false
      if time == timeout
          timedout = true;
          break
      end
      try
      if  strcmpi(mode,'sqq')
        [date, close, open, low, high, volume, closeadj] = sqq(symbol,EndDate,StartDate,'d');
        DataStore = [date, close, open, low, high, volume, closeadj];
      elseif strcmpi(mode,'yahoo-fetch') %Discrete test suggest it take 4 times as long.
        [data] = fetch(yahoo,'ibm',{'Close','Open','Low','High','Volume'},StartDate,EndDate);
        DataStore = flipud(data);
        [i,j] = size(DataStore);
        DataStore(1:i,j+1) = NaN;
      end
      complete = true;
      catch
      complete = false;    
      end
      time = time + 1;
    end
end

if timedout == false
    [y] = size(date,1);
    Info.Start_Date = datestr(date(1));
    Info.End_Date = datestr(date(y));
    Info.NoOfEntriesAdded = y;
else
    Info.Start_Date = 'N/A';
    Info.End_Date = 'N/A';
    Info.NoOfEntriesAdded = 'N/A';
end
