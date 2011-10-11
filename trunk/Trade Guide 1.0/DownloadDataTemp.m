function [DataStore,Info,ErrorCode] = DownloadData(symbol,DateRange)
%Download Data
%Error code:  0 - Download ok
%            -1 - Error occured.

%% Variables

mode = 'sqq'; %yahoo-fetch or sqq

try
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
    else
        try
        [DataStore] = downloaddata(symbol,StartDate,EndDate,mode);
        [y] = size(DataStore,1)
        Info.Start_Date = datestr(DataStore(1,1));
        Info.End_Date = datestr(DataStore(y,1));
        Info.NoOfEntriesAdded = y;
        ErrorCode = 0;
        catch
        disp([symbol,': error downloading'])  
        DataStore = [];
        Info.Start_Date = 'N/A';
        Info.End_Date = 'N/A';
        Info.NoOfEntriesAdded = 'N/A';
        ErrorCode = -1; 
        end
    end
catch
    disp([symbol,': exception downloading'])  
    DataStore = [];
    Info.Start_Date = 'N/A';
    Info.End_Date = 'N/A';
    Info.NoOfEntriesAdded = 'N/A';
    ErrorCode = -2;     
end