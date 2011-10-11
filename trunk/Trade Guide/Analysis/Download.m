classdef Download
    properties
        ColumnNames = { 'LocalBase Symbol'; ...
                        'Yahoo Symbol'; ...
                        'Start Date'; ...
                        'End Date'; ...
                        'Status'; ...
                        'DataPreset'; ...
                        'DataAdded'; ...
                        'NoOfEntriesAdded'; ...
                        'Date/Time'; ...
                        };
        Config = true;
        mode = 'sqq'; %yahoo-fetch or sqq
    end
    methods
        function [Output] = Process(varargin)
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
        end
        function [output] = Report(varargin)
            %Written by:    Bryan Taylor
            %Date Created:  4th May 2008
            %Date Modified: 4th May 2008

            [x] = size(varargin,2);
            if x == 2
                display = varargin{2};
                DataAdded = [];
            elseif x == 3
                display = varargin{2}; 
                DataAdded = varargin{2}; 
            else
                DataAdded = [];
                display = true;
            end
            tablehandle = varargin{1};

            if isempty(DataAdded)
            DataAdded = GetTableData(tablehandle,'DataAdded');
            end
            [TotalNoOfSymbolsInBase] = size(DataAdded,1);

            %Number Updated
            n = find(strcmpi(DataAdded,'true'));
            NoOfTablesUpdated = size(n,1);

            %Number Failed
            n = find(strcmpi(DataAdded,'false'));
            NoOfTablesFailed = size(n,1);
            n = find(strcmpi(DataAdded,'n/a'));
            NoOfTablesFailed = size(n,1) + NoOfTablesFailed;

            %Fail symbols analysis
            DataPreset = GetTableData(tablehandle,'DataPreset');
            n = find(strcmpi(DataPreset,'n/a'));
            NoNotFoundOnYahoo = size(n,1);

            n = find(strcmpi(DataAdded,'false'));
            NoOfTablesFailAddToLocalBase = size(n,1);

            %Time to download
            Time = GetTableData(tablehandle,'Date/Time');
            [x] = size(Time,1);
            StartTime = datenum(Time(1));
            EndTime = datenum(Time(x));
            Duration.datenum = EndTime-StartTime;
            Duration.hoursnum = 24*Duration.datenum;
            Duration.hours = floor(Duration.hoursnum);
            Duration.minutesnum = 60*rem(Duration.hoursnum,1);
            Duration.min = floor(Duration.minutesnum);
            Duration.secsnum = 60*rem(Duration.minutesnum,1);
            Duration.secs = floor(Duration.secsnum);

            String = {  ...
                        'Overall Stats:'; ...
                        '========='; ...
                        ['Total Number Of Symbols In Local Database: ',num2str(TotalNoOfSymbolsInBase)]; ...
                        ['Number of symbols updated: ',num2str(NoOfTablesUpdated),' (',num2str(NoOfTablesUpdated/TotalNoOfSymbolsInBase*100),'%)']; ...
                        ['Number of symbols failed to update: ',num2str(NoOfTablesFailed),' (',num2str(NoOfTablesFailed/TotalNoOfSymbolsInBase*100),'%)']; ...
                        ''; ...
                        'Reason for Failures:'; ...
                        '================'; ...
                        ['Data Found on yahoo: ',num2str(NoNotFoundOnYahoo),' (',num2str(NoNotFoundOnYahoo/NoOfTablesFailed*100),'%)']; ...
                        ['Not Added to Local Base: ',num2str(NoOfTablesFailAddToLocalBase),' (',num2str(NoOfTablesFailAddToLocalBase/NoOfTablesFailed*100),'%)']; ...
                        ''; ...
                        'Simulation Time:'; ...
                        '================'; ...
                        ['Download Time: ',num2str(Duration.hours),'h ',num2str(Duration.min),'m ',num2str(Duration.secs),'s']; ...
                        };

            if display == true
                uiwait(msgbox(String))
            end

            output.TotalNoOfSymbolsInBase = TotalNoOfSymbolsInBase;
            output.NoOfTablesUpdated = NoOfTablesUpdated;
            output.NoOfTablesFailed = NoOfTablesFailed;
            output.NoNotFoundOnYahoo = NoNotFoundOnYahoo;
            output.NoOfTablesFailAddToLocalBase = NoOfTablesFailAddToLocalBase;
            output.Duration = Duration;
        end
        function [DataStore,Info,ErrorCode] = DownloadData(symbol,DateRange)
            %Download Data
            %Error code:  0 - Download ok
            %            -1 - Error occured.
            %            -2 - Symbol Name Exception

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
    end
end