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

%% Load Objects
DataObj = LocalDatabase;
SymbolSourceMode = 'InDataBase';   %Verfied or InDataBase
%Verfied - The symbols 

try 
    tablelist = varargin{2}; %Quick Download
catch
    if strcmpi(SymbolSourceMode,'Verfied')
        [tablelist] = GetAllTableNamesMat(); 
    elseif strcmpi(SymbolSourceMode,'InDataBase')
        [DataObj,tablelist] = DataObj.GetDownloadedSymbolList();
    end
end

Mode = 'Silent';
path = h.path.savedata;

[x] = size(tablelist,1);
for j = 1:x
      %Update GUI
      try
      set(h.Status,'String',['Processing... ',num2str(j),' of ',num2str(x),' (',num2str(round(j/x*100)),'%)']);
      end
      drawnow;
      
      DataObj.Symbol = tablelist{j};
      [Info] = DataObj.Sync();
      
      %Log Information
      Date_Time = datestr(now);
      if j == 1
        Data = {DataObj.Symbol,Info.Start_Date,Info.End_Date,Info.NoOfEntriesAdded,Info.Status,Date_Time};
      else
        Data = [Data;{DataObj.Symbol,Info.Start_Date,Info.End_Date,Info.NoOfEntriesAdded,Info.Status,Date_Time}];   
      end
      
      %Update GUI
      if strcmpi(Mode,'Visual')
        set(h.table,'Data',Data)
      end
end
if strcmpi(Mode,'Silent')
    try
    set(h.table,'Data',Data)
    end
end
try
set(h.Status,'String',['Ready']);
end
Output = Data;
end

