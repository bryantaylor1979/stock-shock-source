classdef Download_Mat < handle
    % Rev Notes: 
    %   0.05    * EmailAdd properties added to support email alerts
    %   0.06    * Hide all support functions
    %           * Add variable arguments in.
    %           * Add visible flag to make GUI silent.
    %           * Added UpdateOnInt. This means it will download on start
    %             up if this flag is set to true
    %           * Added CloseGUIonCompletion . The GUI will close when
    %             download is complete.
    %           * All changed to handle class.
    %           * Retry error removed.
    properties
        ColumnNames = { 'LocalBase Symbol'; ...
                        'Start Date'; ...
                        'End Date'; ...
                        'NoOfEntriesAdded'; ...
                        'Status'; ...
                        'Date/Time'; ...
                        };
       Config = false;
       SymbolSourceMode = 'III';   %Verified or InDataBase or III
       DataObj = LocalDatabase;
       Component = 'Symbol' %Index or Symbol or Both
       Mode = 'Silent';
       Location = 'C:\SourceSafe\Stocks & Shares\Programs\Stock Quote Sync\Data\';
       UpdateRate = 60*60*24;
       StartTime = ['18:00:00'];
       TradeGuideHandle = [];
       SymbolList = [];
       handles
       Rev = 0.06
       InstallDir = 'C:\SourceSafe\Stocks & Shares\Programs\Stock Quote Sync\';
       ProgramName = 'Stock Quote';
       EmailAdd = { 'bryan.taylor@talktalk.net'; ...
                    'bryan.taylor@st.com'; ...
                    };
       Children
       Visible = 'on';
       UpdateOnInt = 'off';
       CloseGUIonCompletion = 'off';
    end
    methods
        function [Output] = Process(varargin)
            %
            %Written by: Bryan Taylor
            %Date Created: 3rd January 2008
            %Date Modified: 3rd January 2008

            obj = varargin{1};
            disp(['Executed: ',datestr(now)])

            %% Load Objects
            obj.SymbolSourceMode
            switch lower(obj.SymbolSourceMode)
                case 'verfied'
                    [tablelist] = GetAllTableNamesMat(); 
                case 'indatabase'
                    DataObj = LocalDatabase;
                    DataObj.Location = obj.Location;
                    [tablelist] = DataObj.GetDownloadedSymbolList();
                case 'iii'
                    DataObj = LocalDatabase;
                    DataObj.Location = obj.Location;
                    SymbolObj = SymbolInfo;
                    SymbolObj.InstallDir = obj.InstallDir;
                    SymbolObj.ReadMap('III_IndexMap');      
                    switch lower(obj.Component)
                        case 'index'
                        tablelist = SymbolObj.IndexList;
                        case 'symbol'
                        tablelist = SymbolObj.SymbolList;   
                        case 'both'
                        tablelist = [SymbolObj.IndexList;SymbolObj.SymbolList];     
                        otherwise
                    end
                    tablelist = [tablelist]
                otherwise          
            end

            [x] = size(tablelist,1);
            tic
            start = 1;
            for j = start:x
                  %Update GUI
                  if isempty(obj.TradeGuideHandle)
                        waitbar(j/x,obj.handles.figure,['Processing... ',num2str(j),' of ',num2str(x),' (',num2str(round(j/x*100)),'%)'])
                  else
                        obj.TradeGuideHandle.UpdateStatus(j/x);
                        set(obj.TradeGuideHandle.handles.StatusInfo,'String',['Processing... ',num2str(j),' of ',num2str(x),' (',num2str(round(j/x*100)),'%)']);                     
                  end
                  drawnow;

                  DataObj.Symbol = tablelist{j};
                  [Info] = DataObj.Sync()

                  %Log Information
                  Date_Time = datestr(now);
                  if j == start
                    Data = {DataObj.Symbol,Info.Start_Date,Info.End_Date,Info.NoOfEntriesAdded,Info.Status,Date_Time};
                  else
                    Data = [Data;{DataObj.Symbol,Info.Start_Date,Info.End_Date,Info.NoOfEntriesAdded,Info.Status,Date_Time}];   
                  end

                  %Update GUI
                  if strcmpi(obj.Mode,'Visual')
                    set(h.table,'Data',Data)
                  end
            end
            waitbar(i/x,obj.handles.figure,obj.CalculateTime(toc));
            if strcmpi(obj.Mode,'Silent')
                try
                set(obj.TradeGuideHandle.handles.table,'Data',Data)
                end
            end
            try
            set(h.Status,'String',['Ready']);
            end
            try
            Output = Data;
            catch
                
            end
            obj.SendEmail;
            if strcmpi(obj.CloseGUIonCompletion,'on');
                close(obj.handles.figure);
            end
        end
        function [Output] = DC_Download_Mat(varargin)
            %
            %Written by: Bryan Taylor
            %Date Created: 3rd January 2008
            %Date Modified: 3rd January 2008

            global h

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
        function [DataStore,timedout,Info] = DownloadData_Mat(symbol,DateRange)
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
        end
        function [DataStore,Info,ErrorCode] = DownloadDataTemp(symbol,DateRange)
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
        end
        function [obj] = SendEmail(obj)
           
            %% 
            setpref('Internet','SMTP_Server','smtp.talktalk.net');
            setpref('Internet','E_mail','bryan.taylor@talktalk.net');
            sendmail(   obj.EmailAdd, [obj.ProgramName,' - ',datestr(now)], ...
                         {'Program details: '; ...
                         ['Name: ',obj.ProgramName]; ...
                         ['Rev: ',num2str(obj.Rev)]; ...
                         ['Finished @: ',datestr(now)]; ...
                         }, ...
                         {});          
        end
    end
    methods (Hidden = true) %GUI functions
        function [obj] = CreateMinimalGUI(obj)
                        %%
            obj.handles.figure = waitbar(0,['Time to start: ',obj.StartTime]);
            set(obj.handles.figure, 'Name',[obj.ProgramName,' - Downloader (R',num2str(obj.Rev),')'], ...
                                    'NumberTitle','off');
            
            %Toolbar
            image = imread([obj.InstallDir,'Icons\refresh3.jpg']);
            image = imresize(image,[16,16]);
                                        
            obj.handles.toolbar = uitoolbar(obj.handles.figure);
            obj.handles.refresh = uipushtool(obj.handles.toolbar, ....
                                                'CDATA',image, ...
                                                'TooltipString','Refresh', ...
                                                'ClickedCallback',@obj.Process);
            
            image = imread([obj.InstallDir,'Icons\ticker2.jpg']);
            image = imresize(image,[16,16]);
            obj.handles.auto = uitoggletool(obj.handles.toolbar, ...
                                                'CDATA',image, ...
                                                'TooltipString','Auto-Updater');
                                                      
            obj.handles.timer = timer(  'TimerFcn',@obj.Process, ...
                                        'Period', obj.UpdateRate, ...
                                        'ExecutionMode','fixedDelay'); 
                                    
            set(obj.handles.auto,'ClickedCallback',@obj.Timer);   
            
            %Menu Bar
            obj.handles.menu = uimenu(obj.handles.figure,'Label','Help');
            obj.handles.About = uimenu(obj.handles.menu, ...
                            'Label',['About ',upper(obj.ProgramName)], ...
                            'Callback',@obj.About);
            
            get(obj.handles.About)
            stop(obj.handles.timer)
        end
        function [obj] = About(varargin)
            obj = varargin{1};
            names = fieldnames(obj.Children);
            [x] = size(names,1);
            for i = 1:x
                Componet = getfield(obj.Children,names{i});
                Rev = Componet.Rev;
                String{i,1} = [names{i},': R',num2str(Rev)];
            end
            msgbox([{'Component Information';'==================';''};String])
        end
        function [obj] = Timer(varargin)
            obj = varargin{1};
            switch get(obj.handles.auto,'State')
                case 'off'
                    stop(obj.handles.timer)
                case 'on'
                    start(obj.handles.timer)
                otherwise
            end
        end
    end
    methods (Hidden = true)
        function [obj] = Download_Mat(varargin)
            warning off
            %% Varargin
            [x] = size(varargin,2);
            for i = 1:2:x
                obj.(varargin{i}) = varargin{i+1};
            end
            
            %% Load Components
            obj.Children.LocalDatabase = LocalDatabase;
            obj.Children.SymbolInfo = SymbolInfo;
            
            %%
            if strcmpi(obj.Visible,'on')
                obj = obj.CreateMinimalGUI;
                set(obj.handles.auto,'ClickedCallback', @obj.Timer);  
            end
            StartDelay = obj.CalcStartDelay;
            
            obj.handles.timer = timer(  'TimerFcn', @obj.Process, ...
                                        'Period', obj.UpdateRate, ...
                                        'StartDelay', StartDelay, ...
                                        'ExecutionMode', 'fixedDelay');      
                                           
            stop(obj.handles.timer);
            
            if strcmpi(obj.UpdateOnInt,'on')
                obj.Process;
            else
                disp('Update not happening')
            end
            
            warning on
        end
        function [StartDelay] = CalcStartDelay(obj)
            TradeGuideStartTimeNum = rem(datenum(obj.StartTime),1);
            
            StartDelay = (TradeGuideStartTimeNum - rem(now,1))*24*60*60;
            if StartDelay < 0
                StartDelay = StartDelay + 60*60*24;
            end
        end
        function [TimeStr] = CalculateTime(obj,Seconds)
            secs = round(Seconds);
            minutes = floor(secs/60);
            hours = floor(minutes/60);
            min = minutes - hours*60;
            secs = secs - minutes*60;
            TimeStr = [num2str(hours),'h ',num2str(min),'m ',num2str(secs),'s'];
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
    end
end

