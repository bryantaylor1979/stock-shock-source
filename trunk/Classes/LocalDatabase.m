classdef LocalDatabase < handle
%Example 1: Sync Database
%   
%Written by:    Bryan Taylor
%Date Created:  2nd Feb 2009
%Date Modified: 13th Sep 2009
%
%Rev 0.01   Rev number property added. 
%           Work offline prompt add on first failed connection.
%Rev 0.02   Today replaced with floor(now)
%Rev 0.03   Offline mode added through arg ins.
%Rev 0.04   AutoRetry added. 
%           Change to handle class.
    properties
       Symbol = '2ENT.ST';
       Location =  'C:\HmSourceSafe\Stocks & Shares\Programs\Stock Quote Sync\Data';
       DatabaseName = 'Database'; %OneYear
       DataStore
       LastPrice
       LastPriceDate
       ExternalCommObj = 'yahoo-fetch'; %yahoo-fetch or sqq or offline
       DataStoreColumnNames = {'Date', 'Close', 'Open', 'Low', 'High', 'Volume'};
       SymbolsList
       DownloadStatus
       StartDate
       EndDate 
       ReqUpdateStatus 
       DebugReport = 'off';
       NR_NoiseThreshold = 0.01;
       NR_SoftSwitch = 0;
       NR_Report = false;
       NR_Plot = false;
       conn
       Rev = 0.04
       ProgramName = 'Local Database';
       AutoRetry = true;
    end
    methods (Hidden = false)
        function [DataStore] = LoadData(obj)
            SaveDataPath = [obj.Location,'\',obj.DatabaseName];
            path = [SaveDataPath,'\Download_Mat\Data\'];
            try
            load([path,strrep(obj.Symbol,'.','_'),'.mat']);
            catch
                DataStore = [];
                obj.DataStore = [];
                return
            end
            if not(exist('DataStore')) %Load function didn't return datastore
                uiwait(msgbox('Data did not load'));
            end
            try
            obj.LastPrice = DataStore.LastPrice;
            obj.LastPriceDate = DataStore.LastPriceDate;
            end
            %Extract Data from structre.
            if isstruct(DataStore)
                try
                Data = DataStore.Data;
                if isstruct(Data)
                   Data = Data.Data; 
                end
                end
                try
                Data = DataStore.DataStore;       
                end
            else
                Data = DataStore; 
            end
            try  
            obj.DataStoreColumnNames = DataStore.ColumnNames;
            end
            DataStore = Data;
            obj.DataStore = Data;
            try
            [x1] = size(DataStore.Data,2);
            [x2] = size(DataStore.ColumnNames,2);
            if x2 > x1
                warning('Column names do not match the DATA table. Removing column names')
                DataStore.ColumnNames = DataStore.ColumnNames(:,1:x1);
            end
            end
        end
        function [StartDate,EndDate] = DateRange(obj)
            %Quick: [startdate,enddate] = StockDateRangeMat(symbol,DataStore);
            %Slow:  [startdate,enddate] = StockDateRangeMat(symbol);
            if isempty(obj.DataStore);
            disp({  'Data not already loaded for this symbol.'; ...
                    'Please use LoadData method.'; ...
                    'For now, data is loaded automactically'; ...
                })
            obj = obj.LoadData();
            end

            try
            Datenum = obj.DataStore.Data(:,1);
            catch
            Datenum = obj.DataStore(:,1);   
            end
            if isstruct(Datenum)
            Datenum = Datenum.Data(:,1);    
            end
            try
            obj.EndDate = max(Datenum);
            catch
            x=1;     
            end
            obj.StartDate = min(Datenum);
            EndDate = obj.EndDate;
            StartDate = obj.StartDate;
        end
        function [SymbolsList] = GetDownloadedSymbolList(obj)
            logdir = pwd;
            SaveDataPath = [obj.Location,obj.DatabaseName];
            path = [SaveDataPath,'\Download_Mat\Data\'];
            cd(path);
            array = rot90(struct2cell(dir)); %struct to cell then rotate
            SymbolsList = array(1:end-2,1); %crop names
            SymbolsList = strrep(SymbolsList,'.mat',''); %remove extention
            SymbolsList = strrep(SymbolsList,'_','.'); %remove extention
            cd(logdir);
            obj.SymbolsList = SymbolsList;  
        end
        function [Info] = Sync(obj)
              if  strcmpi(obj.DebugReport,'on')
                disp(['Syncronising symbol: ',obj.Symbol]);
                disp('==================================');
              end
              [LocalStatus] = obj.DetermineDownloadState();

              if LocalStatus == 1 %%UPDATE
                  if  strcmpi(obj.DebugReport,'on')
                      disp(['Updating (Updating or FullDownload): ',obj.Symbol])
                      disp(' ')
                  end
                  [Status] = obj.RequireSync();
                  startdate = obj.StartDate;
                  enddate = obj.EndDate;

                  if strcmpi(Status,'OutOfDate')
                    DataStore = obj.DataStore;
                    [NewDataStore,timedout,Info] = obj.DownloadData([obj.EndDate+1,floor(now)]);

                    if not(isempty(NewDataStore)) %Download ok
                        [DataStore] = obj.CombineArray(DataStore,NewDataStore);
                        obj.DataStore = DataStore;
                        obj.SaveData();
                        Info.Start_Date = datestr(startdate);
                        [Info.Status] = obj.Update2Date(datenum(Info.End_Date));
                    else % Download fail
                        Info.Start_Date = datestr(startdate);
                        Info.NoOfEntriesAdded = 'N/A';
                        Info.End_Date = datestr(enddate);
                        Info.Status = 'ErrorDownloading';  
                    end
                  else %UpToDate.
                      Info.NoOfEntriesAdded = 'N/A';
                      Info.End_Date = datestr(enddate);
                      Info.Start_Date = datestr(startdate);
                      Info.Status =obj.Update2Date(datenum(Info.End_Date));
                  end
              else %% FULL DOWNLOAD
                  if  strcmpi(obj.DebugReport,'on')
                      disp(['FullDownload (Updating or FullDownload): ',obj.Symbol])
                      disp(' ')
                  end
                  [DataStore,timedout,Info] = obj.DownloadData('all');
                  if isempty(DataStore) == 0 %Download good, save data and update date range
                      %Save Data
                      obj.SaveData();
                      [Info.Status] = obj.Update2Date(datenum(Info.End_Date));
                  else %Download not good.
                      Info.NoOfEntriesAdded = 'N/A';
                      Info.End_Date = 'N/A';
                      Info.Start_Date = 'N/A';
                      Info.Status = 'ErrorDownloading';
                  end
              end
              if  strcmpi(obj.DebugReport,'on')
                  disp(' ')
              end
        end
        function SaveData(obj)
            SaveDataPath = [obj.Location,obj.DatabaseName];
            path = [SaveDataPath,'\Download_Mat\Data\'];
            Data = obj.DataStore;
            
            DataStore.Data = Data;
            DataStore.ColumnNames = obj.DataStoreColumnNames;
            
            obj.GetLastPrice;
            DataStore.LastPrice = obj.LastPrice;
            DataStore.LastPriceDate = obj.LastPriceDate;
            
            save([path,strrep(obj.Symbol,'.','_'),'.mat'],'DataStore');
        end
        function [newsymbolset] = StockQuoteMatQuery(symbolset,date);
            if isempty(symbolset)
               error('Input symbol set is empty'); 
            end

            [x] = size(symbolset,1);
            path = 'C:\SourceSafe\Stocks & Shares\Programs\Trade Guide\SaveData\Download_Mat\Database\';

            for i = 1:x
                load([path,symbolset{i},'.mat']);
                try
                    Datenum = DataStore.Data(:,1);
                    n = find(Datenum <= date);
                    n = n(size(n,1));
                    newrow = [symbolset(i),num2cell((DataStore.Data(n,:)))];
                    empty = false;
                catch
                    empty = true;
                end
                if empty == false  
                    if i == 1
                    newsymbolset = newrow;
                    else
                    newsymbolset = [newsymbolset;newrow];   
                    end
                else
                    %do append to new symbol array.
                end
            end
        end
        function [Data] = GetColumn(obj,Name)
            if isempty(obj.DataStore)
               error('Data has not been loaded. Pleas use LoadData method') 
            end
            n = find(strcmpi(Name,obj.DataStoreColumnNames));
            try
            Data = obj.DataStore.Data(:,n);
            catch
            Data = obj.DataStore(:,n);
            end
        end
        function [Data] = GetData(obj,Name,DateRange)
            if isempty(obj.DataStore)
               error('Data has not been loaded. Please use LoadData method') 
            end
            n = find(strcmpi(Name,obj.DataStoreColumnNames));
            try
            Data = obj.DataStore(:,n);
            catch
            Data = obj.DataStore.Data(:,n);  
            end
            
            if isstruct(Data)
            Data = Data.Data(:,n);   
            end
            if isstruct(Data)
            Data = Data.Data(:,n);   
            end
            Date = obj.GetColumn('Date');
            
            n = find(Date>DateRange(2));
            try
            Data = Data(n);
            Date = Date(n);
            catch
               x = 1; 
            end
            
            n = find(Date<DateRange(1));
            Data = Data(n);
            Date = Date(n);
        end
        function [Data] = GetRange(obj,Name,Period)
            switch lower(Period)
                case '1w'
                    [Data] = GetData(obj,Name,[floor(now),floor(now)-7]);
                case '2w'
                    [Data] = GetData(obj,Name,[floor(now),floor(now)-14]);
                case '1m'
                    [Data] = GetData(obj,Name,[floor(now),floor(now)-30]);
                case '3m'
                    [Data] = GetData(obj,Name,[floor(now),floor(now)-120]);
                case '6m'
                    [Data] = GetData(obj,Name,[floor(now),floor(now)-6*30]);
                case '1y'
                    [Data] = GetData(obj,Name,[floor(now),floor(now)-365]);
                otherwise
            end
        end
        function GetLastPrice(obj);
            try
            [Data] = fetch(obj.conn,obj.Symbol,{'Last';'Date'});
            catch
            pause(5)
            obj.Connect2yahoo;
            [Data] = fetch(obj.conn,obj.Symbol,{'Last';'Date'});
            end
            obj.LastPrice = Data.Last;
            obj.LastPriceDate = Data.Date;
        end
    end
    methods (Hidden = false) % Calculations
        function [LastValue,Date] = LastDayClose(obj)
            if isempty(obj.DataStore);
                obj.LoadData();
            end
            if isempty(obj.DataStore)
                LastValue = NaN;
                Date = NaN;
            else
                Close = obj.DataStore(:,2);
                Date = obj.DataStore(:,1);
                Date = Date(end);
                LastValue = Close(end);
            end
        end
        function [Status] = CalcChange(obj)
        %This function assumes data is correctly loaded into Datastore
        %Example: 
        %obj.Symbol = 'IBM';
        %obj = obj.LoadData();
        %obj = obj.CalcDayGrowth();
            if isempty(obj.DataStore);
                obj.LoadData();
            end
            [Status] = obj.CalcStatus('Change_Pence');
            [Status] = obj.CalcStatus('Change_Percentage');
            
            if strcmpi(Status,'RequireUpdate')
                Close = obj.GetColumn('Close');
                Open = obj.GetColumn('Open');
                Change_Pence = Close - Open;
                Change_Percentage = Change_Pence./Open*100;
                obj.DataStoreColumnNames = [obj.DataStoreColumnNames,{'Change_Pence','Change_Percentage'}];
                try
                obj.DataStore.Data = [obj.DataStore.Data,Change_Pence,Change_Percentage];
                catch
                obj.DataStore.Data = [obj.DataStore,Change_Pence,Change_Percentage];    
                end
            end
        end
        function [Status] = CalcPriceMean(obj) %Verfied
            if isempty(obj.DataStore);
                obj.LoadData();
            end
            [Status] = obj.CalcStatus('PriceMean');
            
            if strcmpi(Status,'RequireUpdate')
                Date = obj.GetColumn('Date');
                Close = obj.GetColumn('Close');
                Open = obj.GetColumn('Open');
                Low = obj.GetColumn('Low');
                High = obj.GetColumn('High');

                PriceMean = mean([Close,Open,High,Low],2);

                obj.DataStoreColumnNames = [obj.DataStoreColumnNames,{'PriceMean'}];
                obj.DataStore.Data = [obj.DataStore.Data,PriceMean];
            end
        end
        function [Status] = CalcMovAvg(obj,NumberOfDays)
            if isempty(obj.DataStore);
                obj.LoadData();
            end
            [Status] = obj.CalcStatus(['MovAvg_',num2str(NumberOfDays)]);
            
            if strcmpi(Status,'RequireUpdate')
                PriceMean = obj.GetColumn('PriceMean');
                    
                [x] = size(PriceMean,1);
                
                if x>NumberOfDays
                [MovingAv,LONG] = movavg(PriceMean,NumberOfDays,NumberOfDays,0);
                obj.DataStoreColumnNames = [obj.DataStoreColumnNames,{['MovAvg_',num2str(NumberOfDays)]}];
                obj.DataStore.Data = [obj.DataStore.Data,MovingAv];
                end
            end
        end
        function [Status] = CalcFiveDayHigh(obj)
            if isempty(obj.DataStore);
                obj.LoadData();
            end
            [Status] = obj.CalcStatus('FiveDayHigh');
            
            if strcmpi(Status,'RequireUpdate')
                n = find(strcmpi(obj.DataStoreColumnNames,'PriceMean'));
                PriceMean = obj.DataStore.Data(:,n);
                n = find(strcmpi(obj.DataStoreColumnNames,'Date'));
                Date = obj.DataStore.Data(:,n);

                %Five Day High
                [x] = size(PriceMean,1);
                if x>5
                    for i = 1:x-4
                        Window = PriceMean(i:i+4);
                        MaxVal = max(Window);
                        FiveDayHigh(i+4,1) = MaxVal;
                        n = find(MaxVal == Window);
                        if not(isempty(n))
                        DateOfFiveDayHigh(i+4,1) = Date(i+n(end)-1);
                        NumberOfDaysSinceFiveDayHigh(i+4,1) = 5- n(end);
                        end
                    end

                    obj.DataStoreColumnNames = [obj.DataStoreColumnNames,{'FiveDayHigh','DateOfFiveDayHigh','NumberOfDaysSinceFiveDayHigh'}];
                    obj.DataStore.Data = [obj.DataStore.Data,FiveDayHigh,DateOfFiveDayHigh,NumberOfDaysSinceFiveDayHigh];
                end
            end
        end
        function [Status] = CalcDayDiff(obj)
            if isempty(obj.DataStore);
                obj.LoadData();
            end
            [Status] = obj.CalcStatus('DayDiff');
            
            if strcmpi(Status,'RequireUpdate')
                PriceMean = obj.GetColumn('PriceMean');
                DayDiff = [0;diff(PriceMean)];
                obj.DataStoreColumnNames = [obj.DataStoreColumnNames,{'DayDiff'}];
                obj.DataStore.Data = [obj.DataStore.Data,DayDiff];
            end
        end
        function [Status] = PercentageChange(obj)
            if isempty(obj.DataStore);
                obj.LoadData();
            end
            [Status] = obj.CalcStatus('PercentageChange');
            
            if strcmpi(Status,'RequireUpdate')
                PriceMean = obj.GetColumn('PriceMean');
                DayDiff = obj.GetColumn('DayDiff');

                PercentageChange = DayDiff./PriceMean;  %percent change

                obj.DataStoreColumnNames = [obj.DataStoreColumnNames,{'PercentageChange'}];
                obj.DataStore.Data = [obj.DataStore.Data,PercentageChange];
            end
        end
        function [Status] = VolumeDiff(obj)
            if isempty(obj.DataStore);
                obj.LoadData();
            end
            [Status] = obj.CalcStatus('VolumeDiff');
            
            if strcmpi(Status,'RequireUpdate')
                Volume = obj.GetColumn('Volume');
                VolumeDiff = [0;diff(Volume)];
                obj.DataStoreColumnNames = [obj.DataStoreColumnNames,{'VolumeDiff'}];
                obj.DataStore.Data = [obj.DataStore.Data,VolumeDiff];
            end
        end
        function [Status] = PriceMean_DeNoise(obj)
            if isempty(obj.DataStore);
                obj.LoadData();
            end
            [Status] = obj.CalcStatus('PriceMean_DeNoise');
            
            if strcmpi(Status,'RequireUpdate')
                PriceMean = obj.GetColumn('PriceMean');
                [PriceMean_DeNoise] = obj.NoiseRemoval();
                obj.DataStoreColumnNames = [obj.DataStoreColumnNames,{'PriceMean_DeNoise'}];
                obj.DataStore.Data = [obj.DataStore.Data,PriceMean_DeNoise];
            end
        end
        function [Status] = TradeSignal(obj)
            if isempty(obj.DataStore);
                obj.LoadData();
            end
            [Status] = obj.CalcStatus('ChangeMarker');
            
            if strcmpi(Status,'RequireUpdate')
                Close = obj.GetColumn('Close');
                Open = obj.GetColumn('Open');
                High = obj.GetColumn('High');
                Low = obj.GetColumn('Low');
                [buy,sell,TradeSignal,ChangeMarker,PercentageChange]=obj.tradeguides();
                obj.DataStoreColumnNames = [obj.DataStoreColumnNames,{'TradeSignal','ChangeMarker'}];
                try
                obj.DataStore.Data = [obj.DataStore.Data,TradeSignal,ChangeMarker];
                catch
                   x = 1;
                end
            end
        end
    end
    methods (Hidden = true) % Support functions
        function [Status] = CalcStatus(obj,Name)
            n = find(strcmpi(Name,obj.DataStoreColumnNames));
            [x] = size(n,2);
            switch x
                case 0
                    Status = 'RequireUpdate';
                case 1
                    Status = 'UpToDate';
                case 2
                    Status = 'Overloaded';
                otherwise
                    error('ERROR: Check Calc Status')
            end
        end
        function [DataStore,timedout,Info] = DownloadData(obj,DateRange)
        % DataRange = 'all' or [floor(now)-7,floor(now)];
            if ischar(DateRange)
                Range = 365*200; %Last 200 years
                StartDate = floor(now)-Range;
                EndDate = floor(now);
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
            if strcmpi(obj.Symbol,'CLF') %Exception call clf function!
                timedout = true;
                DataStore=[];
            else
                while complete == false
                  if time == timeout
                      timedout = true;
                      break
                  end
                 if  strcmpi(obj.ExternalCommObj,'sqq')
                    try
                    [date, close, open, low, high, volume, closeadj] = sqq(obj.Symbol,EndDate,StartDate,'d');
                    DataStore = [date, close, open, low, high, volume, closeadj];
                    complete = true;
                    catch
                    complete = false;    
                    end
                  elseif strcmpi(obj.ExternalCommObj,'yahoo-fetch') %Discrete test suggest it take 4 times as long.
                    try
                        [data] = fetch(obj.conn,obj.Symbol,{'Close','Open','Low','High','Volume'},StartDate,EndDate);
                        if isempty(data)
                        complete = false; 
                        else
                        complete = true;
                        end
                    catch
                        complete = false;     
                    end
                    if complete == true;
                    DataStore = flipud(data);
                    [i,j] = size(DataStore);
%                     DataStore(1:i,j+1) = NaN;
                    date = DataStore(:,1);
                    end
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
            obj.DataStore = DataStore;
            if  strcmpi(obj.DebugReport,'on')
                disp(['Downloading: ',obj.Symbol])
                disp('==========================')
                disp(['Date Range: ',datestr(StartDate),' to the ',datestr(EndDate)]);
                if isempty(DataStore)
                disp(['Extracted: ',num2str(0)])     
                else
                disp(['Extracted: ',num2str(num2str(size(date,1)))])   
                end
            end
        end
        function [Status] = DetermineDownloadState(obj)
        %local database state
        % Does stock require update or complete download
        % Status -  0 Full Download Required.
        %           1 Update Download Required.
        %DataStore is empty unless update download status is 1.
        %Written by:    Bryan Taylor
        %Date Created:  4th January 2009
           path = [obj.Location,obj.DatabaseName,'\Download_mat\Data\'];
           [DataStore] = obj.LoadData();
           Status = 1;
           if isempty(DataStore)
              Status = 0;  
           else 
              Status = 1;
           end
           obj.DownloadStatus = Status;
           obj.DataStore = DataStore;
            
           if  strcmpi(obj.DebugReport,'on')
                if Status == 1
                disp(['Symbol: ',obj.Symbol,' is Full in Local Database']);
                else 
                disp(['Symbol: ',obj.Symbol,' is Empty in Local Database']);   
                end
           end
        end
        function [Status] = RequireSync(obj)
            if isempty(obj.EndDate)
                obj.DateRange();
            end
            [Status,LastWorkingDay] = obj.Update2Date(obj.EndDate);
            obj.ReqUpdateStatus = Status;
            if strcmpi(obj.DebugReport,'on')
                 disp('Required Sync Analysis');
                 disp('======================');
                 disp(['LocalDatabase.... EndDate: ',datestr(obj.EndDate),' StartDate: ',datestr(obj.StartDate)])
                 disp(['floor(now) Date: ',datestr(floor(now)),' LastWorkingDay: ',datestr(LastWorkingDay),' Status: ',Status])
                 disp(' ')
            end
        end
        function [Status,LastWorkingDay] = Update2Date(obj,Date)
        %Will return if stock is up to date. It understand the last working day.
        %% 
        switch datestr(floor(now),8)
            case 'Mon'
                LastWorkingDay = floor(now) - 3;
            case 'Sun'
                LastWorkingDay = floor(now) - 2;
            otherwise
                LastWorkingDay = floor(now) - 1;
        end
        if LastWorkingDay == Date
            Status = 'UpToDate';
        else
            Status = 'OutOfDate';
        end
        end 
        function [DataStore] = CombineArray(obj,DataStore,NewDataStore)
        %Combine the downloaded data with the data locally stored.

        %pad new data
        try
            DataStore.Data;
            [width] = size(DataStore.Data,2);
        catch
            [width] = size(DataStore,2);
        end
        [len,wid] = size(NewDataStore);
        NewData = nan(len,width);
        NewData(:,1:wid) = NewDataStore;
        %append
        try
        Data = DataStore.Data;
        catch
        Data = DataStore;    
        end
        if isstruct(Data)
            Data = Data.Data;
        end
        Data = Data(:,1:6);
        warning off
        DataStore.Data = [Data;NewData];
        warning on
        end
        function [buy,sell,tradesignal,changemarker,pP]=tradeguides(obj)
                %Gives Buy and Sell signals for maximum practical profit.
                %Ignores small trend changes or flat days and follow biggest local trends.Profitable spikes are included.
                %Tradeguide signal offers practical trading benchmark training set for Neural Networks and other learning algorithms or TA.
                %
                %There are no hold signals generated.
                %buy=index for buy days
                %sell=index for sell days
                %Tradesignal is the composite buy and sell signal vector with 1= buy and 0=sell
                %Changemarker is a zero vector of the length of the time serie with 1
                %marking a change in trend.
                %
                %INPUTS:
                %   C:- Stock Closing Price (Column-wise Data)
                %   O:- Stock Opening Price (Column-wise Data)
                %   L:- Stock Low Price (Column-wise Data)
                %   H:- Stock High Price (Column-wise Data)
                %
                %OPTIONAL
                %   'Report':-  logical. The report flag defaults to false.
                %   'NoiseThreshold':- This threshold is expressed as a percentage change.
                %   The default is set to 0.005. This means that any daily change of less than
                %   0.5% will be ignored, and persumed as noise.
                %
                %Example:
                %Get a small amount of data from the local database
                % numberofreadings = 365;
                % [startdate,enddate] = StockDateRange('AAA');
                % 
                % [DateNum] = GetData('AAA','datenum',[startdate,startdate+numberofreadings]);
                % [C] = GetData('AAA','close',[startdate,startdate+numberofreadings]);
                % [O] = GetData('AAA','open',[startdate,startdate+numberofreadings]);
                % [H] = GetData('AAA','high',[startdate,startdate+numberofreadings]);
                % [L] = GetData('AAA','low',[startdate,startdate+numberofreadings]);
                %
                %Get trade signals:
                % [buy,sell,tradesignal,changemarker]=tradeguide(C,O,H,L,'Report',true)
                %
                %Written by:    Bryan Taylor
                %Date Created:  17th Feb 2007
                %Date Modified: 17th Feb 2007
                %
                % Copyright 2007, CoLogic, Inc
                NoiseThreshold = obj.NR_NoiseThreshold;
                report = obj.NR_Report;
                report = false;

                %take the mean of each price. 2 means rows. Hence for each day the average
                %is taken of the high, low, open and close price
               
                P = obj.GetColumn('PriceMean');
                l=length(P);

                if report == true
                    if l>5
                    disp('Take the average of the open, close, high low price for each day');
                    disp('This will remove some noise from the data');
                    disp('day_average = (open + close + high + low)/4');
                    day_average = P(1:5) 
                    end
                end

                dP=[0;diff(P)];%2 day price difference

                if report == true
                    if l>5
                    disp('Find the day to day difference of the stock price');
                    disp('DiffPrice = Price(n) - Price(n-1)');
                    disp('where n is a date vector');
                    diffPrice = dP(1:5) 
                    end
                end

                pP=dP./P;%percent change

                if report == true
                    if l>5
                    disp('this does tell us about profit therefore we then take the percentage change.')
                    disp('PercentageChange = PriceChange/Price')
                    PercentageChange = pP(1:5)
                    end
                end

                spP=sign(pP);%sign of day to day % change

                if report == true
                    if l>5
                    disp('find the sign of each price diff')
                    signP = spP(1:5)
                    end
                end

                n=find(spP==0);%%find no change days
                %find returns all the location where the is no change between days

                spP(n)=sign(rand-.5);%%add small noise to no change days

                if report == true
                    if l>5
                    FixedSignChange = spP(1:5);
                    end
                end

                spP=(spP+1)/2;%%convert to binary 0=down 1=up
                %%%%filter out flat days with changes less than .5%
                %%small noises and spikes are non-profitable neglected
                for i=2:l-1
                    if abs(pP(i))<NoiseThreshold
                        spP(i)=spP(i-1);%same as prior day
                    end
                end
                % two 0.25 changes would result in a signed result

                if report == true
                    if l>5
                    FixedSignChange = spP(1:5);
                    end
                end

                %%%%%%%%Mark signal change%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%find buy  signal%%
                n=find(spP(2:end)==1);%shift back by one day 
                buy=n;
                %%%%%%%%find sell signal%%
                n=find(spP(2:end)==0);%shift back by one day 
                sell=n;
                %%%%%%%%tradesignal
                try
                n = find(isnan(spP)==1);   
                x = size(spP,1);
                spP = spP(n);           
                changemarker = zeros(x-1,1);
                
                cm =xor(spP(1:end-1),spP(2:end));%finds changing signals
                changemarker(n) = cm;
                catch
                   x = 1; 
                end
                %%%%%%%%tradesignal
                tradesignal=zeros(l,1);
                tradesignal(buy)=1;
                changemarker = [NaN;changemarker];
        end
        function [P] = NoiseRemoval(obj)
            %This function removes daily noise. This function needs to be optimised but
            %when set up correctly will remove daily noise.
            %
            %Optional Inputs:
            %   Noise Threshold:-   If the daily variation is less than this value the
            %   stock price will be assumed to be the same. This is expressed as a
            %   factor. e.g 0.005 would be result in any change less than 0.5 % would
            %   be ignore therefore would be overwritten by the previous value.
            %
            %   SoftSwitch:-    (Dampen Correction) This allows you to fade from completely corrected to
            %   completely un-corrected. When set to one there is no correct, and when
            %   it is set to 0, full correction will be observed.
            %   This could be changed to the reverse sign. 
            %
            %   Report:-    Will output a report to help with debug. This can also
            %   help to understand the function.
            %
            %   Plot:-  This will plot the orginal data and the noise reduced data on
            %   the same graph.
            %
            %Defaults:  Noise Threshold    0.005
            %           Softswitch         0; (Full correction)
            %
            %Example:
            %IntialiseDatabase;
            % [date,close,open,high,low,closeadj] ...
            %     = StockQuote('AA',{'datenum';'close';'open';'high';'low';'closeadj'},[floor(now)-90,floor(now)]);
            % P=mean([close,open,high,low],2);
            % [price] = NoiseRemoval(P,'softswitch',0,'noisethreshold',0.01);
            % [AX,H1,H2] = plotyy(date,P,date,price,'plot');
            %
            %Please ensure axis are the same scale.
            % axes(AX(1))
            % axis([date(1),date(x),min(P),max(P)]);
            % axes(AX(2))
            % axis([date(1),date(x),min(P),max(P)]);
            %
            % Copyright 2007, CoLogic, Inc

            % TODO:   Subsitute noise threshold for an adpative moving noise figure.

            NoiseThreshold = obj.NR_NoiseThreshold;
            SoftSwitch = obj.NR_SoftSwitch;
            report = obj.NR_Report;
            report = false;
            Plot = obj.NR_Plot;
            P = obj.GetColumn('PriceMean');

            l=length(P);

            %take the mean of each price. 2 means rows. Hence for each day the average
            %is taken of the high, low, open and close price
            if report == true
               if l>5
               Orginal_Data = P(1:5)
               end
            end
            dP=[0;diff(P)];%2 day price difference
            if report == true
                if l>5
               Difference_Data = dP(1:5) 
                end
            end
            pP=dP./P;%percent change
            if report == true
                if l>5
               Percentage_Change = pP(1:5)
                end
            end

            %%%%filter out flat days with changes less than .5%
            %%small noises and spikes are non-profitable neglected
            oldP = P;
            for i=2:l
                if abs(pP(i))<obj.NR_NoiseThreshold
                    pricediff(i) = P(i)-P(i-1);
                    P(i)= P(i-1)+pricediff(i)*obj.NR_SoftSwitch;
                else
                    P(i)=P(i);%no correction
                end
            end
            if report == true
                if l>5
                temp = [oldP,P];
                summary = temp(1:5,:)
                end
            end

            if Plot == true
                %generate date data
                [x] = size(P,1);
                date = [1:x];
                figure;
                [AX,H1,H2] = plotyy(date,oldP,date,P,'plot');

                % Please ensure axis are the same scale.
                axes(AX(1))
                axis([date(1),date(x),min(oldP),max(oldP)]);
                datetick
                axes(AX(2))
                axis([date(1),date(x),min(oldP),max(oldP)]);
                datetick
            end
        end
        function [obj] = LocalDatabase(varargin)
            % Arg ins
            [x] = size(varargin,2);
            for i = 1:2:x
                obj.(varargin{i}) = varargin{i+1};
            end
            
            % Load Comm object
            switch obj.ExternalCommObj
                case 'yahoo-fetch'
                    obj.Connect2yahoo;
                case 'offline'
                otherwise
            end
        end
        function Connect2yahoo(obj)
            
            if obj.AutoRetry == true
               Time = 2; 
            else
               Time = 1; 
            end
            Timeout = 40;
            while Time < Timeout
                try
                    obj.conn = yahoo;
                    break
                catch
                    if Time == 1
                       ButtonName = questdlg(   'Do you want to retry or work offline?', ...
                                                'Connection Failed', ...
                                                'Retry', 'Offline', 'Retry'); 
                       switch ButtonName
                           case 'Retry'
                               %Do nothing
                           case 'Offline'
                               break %Break out while loop
                           otherwise
                       end
                    end
                    PauseTime = 5*2^Time;
                    disp(['Connection failed. Wait ',num2str(PauseTime),' secs'])
                    pause(PauseTime);
                    Time = Time + 1;
                end
            end
            if Time == Timeout
                msgbox('Could not connect to yahoo. Check connection') 
            else
                disp('Connection established') 
            end
        end
    end
end