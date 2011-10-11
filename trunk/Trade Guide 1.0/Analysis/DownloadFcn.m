function [Output] = NumberOfSymbolsPerDayFcn(varargin)
%Calculate the number of symbols on each day.
%
%InputArray - Output from symbol information.
%Database must be intialised.
%
%Example: 
%IntialiseDatabase;
%[OutPutArray] = SymbolInformation();
%[startdateout,enddateout] = NumberOfSymbolsPerDay(MinimumThreshold,InputArray)
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
                'Status'; ...
                'DataPreset'; ...
                'DataAdded'; ...
                'NoOfEntriesAdded'; ...
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

conn = yahoo;
conn2 = database('SaxoTrader','','');
[tablelist] = GetAllTableNames(conn2);

[x] = size(tablelist,1);
% StatusBar(h.statusbar,0);
h1 = waitbar(0);
for j = 1:x
      set(h.Status,'String',['Processing... ',num2str(j),' of ',num2str(x),' (',num2str(round(j/x*100)),'%)']);
      waitbar(j/x,h1,['Processing... ',num2str(j),' of ',num2str(x),' (',num2str(round(j/x*100)),'%)']);
      
      YahooBaseSymbol = strrep(tablelist{j},'_','.');
      
      try %Catch excemptions
      [startdate,LastDateEntry] = StockDateRange(conn2,tablelist{j});
      catch
      startdate = 'failed'; 
      LastDateEntry = 'failed';
      Status = 'failed';
      end
      
      if strcmpi(startdate,'No Data')
          Status = 'empty';
      else
          Status = 'update';
      end
      try
          status = DownloadData(conn2,tablelist(j),Status);
          DataFound = status.datapresent;
          NoOfEntriesAdded = status.NoOfEntriesAdded;
          DataAdded = status.DataAdded;
      catch
          DataFound = 'n/a';
          NoOfEntriesAdded = 'n/a';
          DataAdded = 'n/a';
      end
      
      TradeStructure(j).LocalBaseSymbol = tablelist{j};
      TradeStructure(j).YahooSymbol = YahooBaseSymbol;
      TradeStructure(j).StartDate = startdate;
      TradeStructure(j).EndDate = LastDateEntry; 
      TradeStructure(j).Status = Status;
      TradeStructure(j).DataPreset = DataFound; 
      TradeStructure(j).DataAdded = DataAdded;
      TradeStructure(j).NoOfEntriesAdded = NoOfEntriesAdded; 
      TradeStructure(j).DateTime = datestr(now); 
%       AddRow(RowInfo);
end
LoadStruct(h,TradeStructure);
close(conn2)
set(h.Status,'String',['100% Complete']);
Output = 1;