function [Output] = PennyStocksFcn(varargin)
%
%Written by: Bryan Taylor
%Date Created: 4th January 2009
%Date Modified: 4th January 2009

global h
RemovalThreshold = 50;
NumberOfDaysStale = 10;

%% Column Names Declarations
try
if strcmpi(varargin{1},'ColumnNames')
    Output = {  'Symbol'; ...
                'Date'; ...
                'LastPrice'; ...
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
set(h.Status,'String',['Busy']);
drawnow;
Mode = 'Silent';
DataObj = LocalDatabase;
[DataObj,tablelist] = DataObj.GetDownloadedSymbolList();

[x] = size(tablelist,1);
start = 1;
for j = start:x
      %Update GUI
      try
      set(h.Status,'String',['Processing... ',num2str(j),' of ',num2str(x),' (',num2str(round(j/x*100)),'%)']);
      end
      drawnow;
      
      DataObj.Symbol = tablelist{j};
      [LastValue,Date] = DataObj.LastDayClose;
      
      %Log Information
      Date_Time = datestr(now);
      if isnan(Date)
          Date = NaN;
      else
          Date = datestr(Date);
      end
      if j == start
        Data = {DataObj.Symbol,Date,LastValue};
      else
        Data = [Data;{DataObj.Symbol,Date,LastValue}];   
      end
      
      %Update GUI
      if strcmpi(Mode,'Visual')
        set(h.table,'Data',Data)
      end
end

%Sort in price order
Data = sortrows(Data,3);
n = find(RemovalThreshold>cell2mat(Data(:,3)));
Data = Data(n,:);

%Remove stale stocks
n = find(today-NumberOfDaysStale<datenum(Data(:,2)));
Data = Data(n,:);

if strcmpi(Mode,'Silent')
    try
    set(h.table,'Data',Data)
    end
end
try
set(h.Status,'String',['Ready']);
drawnow;
end
Output = Data;
end


