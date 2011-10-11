function [DataStore,Info,ErrorCode] = DownloadData(symbol,DateRange)
%Download Data
%Error code:  0 - Download ok
%            -1 - Error occured.
%            -2 - Symbol Name Exception

%% Variables

mode = 'sqq'; %yahoo-fetch or sqq

%% Daterange
if ischar(DateRange)
    Range = 365*200; %Last 200 years
    StartDate = today-Range;
    EndDate = today;
else
    StartDate = DateRange(1);
    EndDate = DateRange(2);
end

%% Get Data
if strcmpi(symbol,'CLF') %Exception call clf function!
    DataStore   = [];
    Info.Start_Date = 'N/A';
    Info.End_Date = 'N/A';
    Info.NoOfEntriesAdded = 'N/A';
    ErrorCode = -2;
else
    try
    [DataStore] = downloaddata(symbol,StartDate,EndDate,mode);
    [y] = size(DataStore,1);
    Info.Start_Date = datestr(DataStore(1,1));
    Info.End_Date = datestr(DataStore(y,1));
    Info.NoOfEntriesAdded = y;
    ErrorCode = 0;
    catch
    DataStore = [];
    Info.Start_Date = 'N/A';
    Info.End_Date = 'N/A';
    Info.NoOfEntriesAdded = 'N/A';
    ErrorCode = -1; 
    end
end
end
function [DataStore] = downloaddata(symbol,StartDate,EndDate,mode)
%Download data from yahoo        
if  strcmpi(mode,'sqq')
    [date, close, open, low, high, volume, closeadj] = sqq(symbol,EndDate,StartDate,'d');
    DataStore = [date, close, open, low, high, volume, closeadj];
elseif strcmpi(mode,'yahoo-fetch') %Discrete test suggest it take 4 times as long.
    [data] = fetch(yahoo,symbol,{'Close','Open','Low','High','Volume'},StartDate,EndDate);
    DataStore = flipud(data);
    [i,j] = size(DataStore);
    DataStore(1:i,j+1) = NaN;
end
end