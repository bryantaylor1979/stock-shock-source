function [Output] = Download_MatFcn(varargin)
%
%Written by: Bryan Taylor
%Date Created: 3rd January 2008
%Date Modified: 3rd January 2008

global h

%% Column Names Declarations
try
if strcmpi(varargin{1},'ColumnNames')
    Output = {  'LocalBase Symbol'; ...
                'Yahoo Symbol'; ...
                'Start Date'; ...
                'End Date'; ...
                'NoOfEntriesAdded'; ...
                'Status'; ...
                'Date/Time'; ...
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

try 
   tablelist = varargin{2}; %Quick Download
catch
   [tablelist] = GetAllTableNamesMat(); 
end

Mode = 'Silent';
path = 'C:\SourceSafe\Stocks & Shares\Programs\Trade Guide\SaveData\Download_Mat\Database\';

[x] = size(tablelist,1);
for j = 1:x
      %Update GUI
      set(h.Status,'String',['Processing... ',num2str(j),' of ',num2str(x),' (',num2str(round(j/x*100)),'%)']);
      drawnow;
      
      %Symbol Create
      YahooBaseSymbol = strrep(tablelist{j},'_','.');
      LocalBase_Symbol = strrep(tablelist{j},'.','_');
      
      [LocalStatus,DataStore] = DetermineDownloadState(LocalBase_Symbol);
      if LocalStatus == 1 %%UPDATE
          [startdate,enddate] = StockDateRangeMat(LocalBase_Symbol,DataStore);
          [Status] = Update2Date(enddate);
          if strcmpi(Status,'OutOfDate')
            [NewDataStore,Info,ErrorCode] = DownloadData(tablelist{j},[enddate+1,today]);
            if ErrorCode == 0 %Download ok
                %pad new data
                [DataStore] = CombineArray(DataStore,NewDataStore);
                save([path,LocalBase_Symbol],'DataStore');
                Info.Start_Date = datestr(startdate);
                [Status] = Update2Date(datenum(Info.End_Date));
            else % Download fail
                Info.Start_Date = datestr(startdate);
                Info.NoOfEntriesAdded = 'N/A';
                Info.End_Date = datestr(enddate);
                Status = 'ErrorDownloading';  
            end
          else %UpToDate.
              Info.NoOfEntriesAdded = 'N/A';
              Info.End_Date = datestr(enddate);
              Info.Start_Date = datestr(startdate);
          end
      else %% FULL DOWNLOAD
          [DataStore,Info,ErrorCode] = DownloadData(tablelist{j},'all'); 
          if ErrorCode == 0 %Download good, save data and update date range
              %Save Data
              save([path,LocalBase_Symbol],'DataStore');
              [Status] = Update2Date(Info.End_Date);
          else %Download not good.
              Info.NoOfEntriesAdded = 'N/A';
              Info.End_Date = datestr(enddate);
              Info.Start_Date = datestr(startdate);
              Status = 'ErrorDownloading';
          end
      end
      
      %Log Information
      Date_Time = datestr(now);
      if j == 1
        Data = {LocalBase_Symbol,YahooBaseSymbol,Info.Start_Date,Info.End_Date,Info.NoOfEntriesAdded,Status,Date_Time};
      else
        Data = [Data;{LocalBase_Symbol,YahooBaseSymbol,Info.Start_Date,Info.End_Date,Info.NoOfEntriesAdded,Status,Date_Time}];   
      end
      
      %Update GUI
      if strcmpi(Mode,'Visual')
        set(h.table,'Data',Data)
      end
end
if strcmpi(Mode,'Silent')
    set(h.table,'Data',Data)
end
set(h.Status,'String',['Ready']);
Output = Data;
end
function [DataStore] = CombineArray(DataStore,NewDataStore)
%Combine the downloaded data with the data locally stored.

%pad new data
[width] = size(DataStore,2);
[len,wid] = size(NewDataStore);
NewData = nan(len,width);
NewData(:,1:wid) = NewDataStore;
%append
DataStore = [DataStore;NewData];
end
function [Status,DataStore] = DetermineDownloadState(Symbol)
% Does stock require update or complete download
% Status -  0 Full Download Required.
%           1 Update Download Required.
%DataStore is empty unless update download status is 1.
path = 'C:\SourceSafe\Stocks & Shares\Programs\Trade Guide\SaveData\Download_Mat\Database\';
try
    DataStore = load([path,Symbol]); %if mat file exsit the rest of the code is executed. i.e update sequence
    if isstruct(DataStore)
    DataStore = DataStore.DataStore;
    end
    Status = 1;
    if isempty(DataStore)
       Status = 0;  
    end
catch
DataStore = [];  
Status = 0;
end
end
function [Status] = Update2Date(Date)
%Will return if stock is up to date. It understand the last working day.
%% 
switch datestr(today,8)
    case 'Mon'
        LastWorkingDay = today - 3;
    case 'Sun'
        LastWorkingDay = today - 2;
    otherwise
        LastWorkingDay = today - 1;
end
if LastWorkingDay == Date
    Status = 'UpToDate';
else
    Status = 'OutOfDate';
end
end
