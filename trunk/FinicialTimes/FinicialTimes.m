classdef FinicialTimes <    handle & ...
                            InvestedSymbols & ...
                            DataSetFiltering & ...
                            MacroRun & ...
                            ResultsLog & ...
                            Comms
    properties
        Threshold = 1.2;
        AllSymbolList
        ColumnNames = {'Date','Company Name','Ticker','Recommendation','Price','Old Price Target','New price target','Broker change','Current Price Target','Profit'};
        GUI_Mode = 'User'; %Minimal or Full or User
        Visible = 'on';
        RunOnInt = 'off';
        CloseGUIwhenComplete = 'off';
        DataFolder = 'C:\SourceSafe\Stocks & Shares\Programs\FinicialTimes\NewData\';
        Mode = 'url'; %url or wq
        ForceUpdate = 'off';
    end
    properties (Hidden = true)
        Rev = 0.15;
        InstallDir = 'C:\SourceSafe\Stocks & Shares\Programs\FinicialTimes\';
        URL = 'http://markets.ft.com/tearsheets/analysis.asp?s=';
        handles
        ProgramName = 'Finanical Times';
        SelectedArray
        TableArray
        RootDir = 'C:\SourceSafe\Stocks & Shares\Programs\';
    end
    methods (Hidden = true)
        function [obj] = FinicialTimes(varargin)
            [x] = size(varargin,2);
            for i = 1:2:x
                obj.(varargin{i}) = varargin{i+1};
            end
            
            obj.CreateGUI;
            
            if strcmpi(obj.RunOnInt,'on')
                obj.RunMacro(obj.Macro);
            end
            if strcmpi(obj.CloseGUIwhenComplete,'on')
                close(obj.handles.figure)
            end              
        end
        function CreateGUI(obj)
            if strcmpi(obj.GUI_Mode,'User')
            obj.GUI_Mode = questdlg('Which mode do you want to load into?', ...
                                    'User Question', ...
                                    'Full', 'Minimal','Minimal');
            end
            
            if strcmpi(obj.GUI_Mode,'Minimal')
                warning off
                obj = obj.CreateMinimalGUI;
                warning on
            else
                warning off
                obj = obj.CreateMaxGUI;
                obj = obj.LoadData;
                warning on
            end
        end
        function Symbols = LoadAllSymbols(obj)
            sobj = SymbolInfo;
            sobj.InstallDir = obj.InstallDir;
            sobj = sobj.ReadMap('III_IndexMap');
            Symbols = sobj.Data(:,2);
            obj.Symbols = Symbols;
        end
        function Symbols = GetBBSymbolList(obj)
            %%
            FileName = [obj.RootDir,'BritishBulls\Results\ALL_STATUS\DataSet\'];
            CD = pwd;
            cd(FileName);
            names = struct2cell(dir);
            Name = rot90(strrep(names(1,:,:),'.mat',''));
            DateNum = max(datenum(Name(1:end-2)));
            cd(CD);
            
            FileName = [obj.RootDir,'BritishBulls\Results\ALL_STATUS\DataSet\',datestr(DateNum),'.mat'];
            load(FileName);
            
            Symbols = obj.GetColumn(DataSet,'Ticker');
        end
        function LASTDAYEVENT = RecentEvents(obj,Symbols,ThresholdDayOld)
            %%
            x = size(Symbols,1);
            FailedCount = 0;
            SucessCount = 0;
            First = true;
            for i = 1:x
                waitbar(i/x)
                try
                    fprintf(['Symbol: ',Symbols{i}])
                    Symbol = strrep(Symbols{i},'.L','');
                    [DATASET, NoOfDaysSinceLastUpdate(i)] = obj.LOC_Events(Symbol);
                    
                    %Filter on most recent. 
                    DaysOld = obj.GetColumn(DATASET,'DaysOld');
                    n = find(min(DaysOld) == DaysOld);
                    DATASET = DATASET(n,:);
                    
                    DaysOld = obj.GetColumn(DATASET,'DaysOld');
                    fprintf([' DaysOld: ',num2str(DaysOld)]);
                    
                    n = find(DaysOld <= ThresholdDayOld);
                    SYMBOLLASTDAYEVENT = [dataset({{Symbol},'Symbol'},NoOfDaysSinceLastUpdate),DATASET(n,:)];
                    if First == true
                        LASTDAYEVENT = SYMBOLLASTDAYEVENT;
                        First = false;
                    else
                        LASTDAYEVENT = [LASTDAYEVENT;SYMBOLLASTDAYEVENT]; 
                    end
                    
                    fprintf(' Sucessfull\n')
                    SucessCount = SucessCount + 1;
                catch
                    fprintf(' Failed\n')
                    FailedCount = FailedCount + 1;
                end
            end
            Min = min(NoOfDaysSinceLastUpdate);
            
            try
            y = size(LASTDAYEVENT,1);
            disp([num2str(y),' Events for ',num2str(x),' Symbols'])
            catch
            disp(['0 Events for ',num2str(x),' Symbols'])    
            end
            
            disp(['NoOfDaysSince LastUpdate: ',num2str(Min)])
            disp(['Sucessfull Events: ',num2str(SucessCount)])
            disp(['Failed Events: ',num2str(FailedCount)])
        end
        function DayBrokersView2SymbolFile(obj,DATASET,Symbol,datenum)
           log = true;
           Ticker = obj.GetColumn(DATASET,'Symbol');
           n = find(strcmpi(Ticker,Symbol));
           N_DATASET = DATASET(n,:);
           
           %%
           try
               [DATASET] = obj.LOC_Quote(Symbol,'All');
               DATASET = DATASET(:,1:8); %Remove last price
               if log == true
                  disp('Local Data Found') 
               end
           catch
               disp('No DATA found locally')
               DATASET = N_DATASET;
               save([obj.DataFolder,Symbol],'DATASET');
               return
           end
           
           %% Get today entry
           [Date] = GetColumn(obj,DATASET,'Date');
           n = find(Date == datenum);
           if isempty(n)
               n = find(Date >= datenum);
           end
           if log == true
                disp(['Number of entries with date requested: ',num2str(size(n,1))])
                if size(n,1) >= 1
                    disp('warning: 2 many entries')
                    return
                end
           end
           try
           DATASET = [DATASET; N_DATASET]; 
           catch
           DATASET = N_DATASET; 
           end
           save([obj.DataFolder,Symbol],'DATASET');
           disp('Dataset saved')
           UpToDate = false;
           DATASET = N_DATASET;  
        end
        function DayBrokersView2SymbolFileLoop(obj,datenum)
               DATASET = obj.LoadResult('FinicialTimes','Sync',datenum);
               Symbols = obj.GetColumn(DATASET,'Symbol');
               [x] = size(Symbols,1);
               for i = 1:x
                    waitbar(i/x);
                    obj.DayBrokersView2SymbolFile(DATASET,Symbols{i},datenum);
               end
        end
        function DayBrokersView2SymbolsFiles(obj)
           %%
           DateNums = obj.GetResultDateNums('FinicialTimes','Sync');
           y = size(DateNums,1);
           
           for j = 1:y
                obj.DayBrokersView2SymbolFileLoop(DateNums(j));
           end
        end
    end
    methods (Hidden = false) %Add Columns
        function [DATASET] = CalcMedianProfit(obj,DATASET)
            MedianTarget = double(GetColumn(obj,DATASET,'MedianTarget'));
            Price = double(GetColumn(obj,DATASET,'LastPrice'));
            MedianProfit = MedianTarget./Price;
            DATASET = [DATASET,dataset(MedianProfit)];
        end 
        function [DATASET] = AddDateStrColumn(obj,DATASET)
            Datenum = obj.GetColumn(DATASET,'Date');
            DateStr = datestr(Datenum)
            [x] = size(DateStr,1);
            for i = 1:x
                DATESTR{i,1} = DateStr(i,:);
            end
            DateStr = DATESTR;
            DATASET = [DATASET,dataset(DateStr)];
        end
    end    
    methods (Hidden = false) % Brokers View - Download Data
        function [DATASET] = LoadAll(obj,Symbols)
            tic;
            disp(['Time Executed: ',datestr(now)])

            InvestedSymbolList = Symbols;

            [x] = size(InvestedSymbolList,1);
            [DATASET] = obj.LOC_Last_DownloadData(InvestedSymbolList{1});
            for i = 1:x %loop over symbols
                Symbol = strrep(InvestedSymbolList{i},'.L','');
                [N_DATASET] = obj.LOC_Last_DownloadData(Symbol);
                DATASET = [DATASET;N_DATASET];
                waitbar(i/x,obj.handles.figure,Symbol);
            end               

        end
        function DownloadAll_URL_BrokersView(obj,Symbols,Date)
            %%
            PWD = pwd;
            x = size(Symbols,1);
            Path = [obj.InstallDir,'Results\Sync\URL\',datestr(Date),'\'];
            try
                cd(Path)
            catch
                mkdir(Path)
                cd(Path)
            end
            
            %%
            names = dir;
            names = rot90(struct2cell(names));
            SymbolDownloaded = strrep(names(1:end-3,1),'.mat','');
            
            
            for i = 1:x
                waitbar(i/x);
                if isempty(find(strcmpi(Symbols{i},SymbolDownloaded)))
                    [s,Error] = obj.readURL(Symbols{i});
                    if Error == 0
                    String = [Path,Symbols{i},'.mat'];
                    save(String,'s');
                    disp([Symbols{i},': Required']);
                    else
                    disp([Symbols{i},': Download Error']);    
                    end
                else
                    disp([Symbols{i},': Not required']);
                end
            end
            cd(PWD)
        end
        function DATASET = DecodeAll_URL_BrokersView(obj,Symbols,Date)
            x = size(Symbols,1);
            h = waitbar(0);
            DATASET = [];
            for i = 1:x %loop over symbols
                waitbar(i/x,h,[num2str(i),' of ',num2str(x)]);
                [s, Error] = obj.loadURL_BrokersView(Symbols{i},Date);
                if Error == 0;
                    try
                    [N_DATASET,Data] = obj.ExtraDataFromURL(s,Symbols{i});
                    catch
                    [N_DATASET,Data] = obj.BuildNoAward(Symbols{i});   
                    end
                    if isempty(DATASET)
                        DATASET = N_DATASET;
                    else
                        try
                        DATASET = [DATASET;N_DATASET];
                        catch
                           x = 1; 
                        end
                    end
                    drawnow;
                end
            end
        end
        function [s,Error] = loadURL_BrokersView(obj,Symbol,Date)
            Path = [obj.InstallDir,'Results\Sync\URL\',datestr(Date),'\'];
            String = [Path,Symbol,'.mat'];
            try
                load(String);  
                Error = 0;
            catch
                s = [];
                Error = -1;
            end
        end
        function DateNums = GetBrokersViewDateNums(obj)
            %%
            PWD = pwd;
            
            Path = [obj.InstallDir,'Results\Sync\URL\'] ;
            cd(Path);
            filenames = rot90(struct2cell(dir));
            filenames = filenames(1:end-2,1);
            DateNums = datenum(filenames);
            
            cd(PWD)
        end
        function DATASET = LOC_URL_BrokersView(obj,Symbol)       
            %% Extract Table
            try
                s = obj.loadURL_BrokersView(Symbol);
                [DATASET,Data] = obj.ExtraDataFromURL(s,Symbol);
            catch % No data available
                [DATASET,Data] = obj.BuildNoAward(Symbol);
            end        
        end
        function [DATASET] = DownloadAll(obj,Symbols)
            datenum = today;
            tic;
            disp(['Time Executed: ',datestr(now)])

            InvestedSymbolList = Symbols;

            [x] = size(InvestedSymbolList,1);
            h = tic;
            if strcmpi(obj.ForceUpdate,'on')
                Symbol = strrep(InvestedSymbolList{1},'.L','');
                disp(Symbol)
                switch upper(obj.Mode)
                    case 'WQ'
                        disp('Web Query')
                        [DATASET,Data] = obj.WQ_DownloadData(Symbol);
                    case 'URL'
                        disp(['URL Query: ',Symbol])
                        [DATASET,Data] = obj.URL_DownloadData(Symbol);
                    otherwise
                end
                UpToDate = true;
            else
                disp('Sync')
                [DATASET,UpToDate] = obj.Sync(InvestedSymbolList{1},datenum);
            end
            timed(1) = toc(h);
            h = tic;
            disp(' ')
            for i = 2:x %loop over symbols
                Symbol = strrep(InvestedSymbolList{i},'.L','');
                disp(Symbol)
                if strcmpi(obj.ForceUpdate,'on')
                    switch upper(obj.Mode)
                        case 'WQ'
                            disp('Web Query')
                            [N_DATASET,Data] = obj.WQ_DownloadData(Symbol);
                        case 'URL'
                            disp(['URL Query: ',Symbol])
                            [N_DATASET,Data] = obj.URL_DownloadData(Symbol);
                        otherwise
                    end
                else
                    disp('Sync')
                    [N_DATASET,UpToDate] = obj.Sync(Symbol,datenum);
                    
                end
                try
                DATASET = [DATASET;N_DATASET];
                end
                Num2Go = x - i;
                index = rem(i,5)+1;
                timed(index) = toc(h);
                AvTime = mean(timed);
                
                Time2Go = Num2Go*AvTime;
                h = tic;
                if UpToDate == true
                    waitbar(i/x,obj.handles.figure,['ETC: ',num2str(Time2Go/60),'mins (',num2str(i),' of ',num2str(x),') : ',Symbol,' - UpToDate']);
                else
                    waitbar(i/x,obj.handles.figure,['ETC: ',num2str(Time2Go/60),'mins (',num2str(i),' of ',num2str(x),') : ',Symbol,' - Downloaded']);
                end
                disp(' ')
            end   
            close(obj.handles.figure)
        end
        function [DATASET] = LOC_Quote(obj,Symbol,Fields)
            %Local Quote
            %Fields:    'All'
            %           'Date'
            %           'Symbol'
            %           'Recommendation'
            %           'Strength'
            %           'NoOfBrokers'
            %           'MedianTarget'
            %           'HighEstimate'
            %           'LowEstimate'
            %           'LastPrice'
            %LOC_Quote(obj,Symbol,Fields)
            if strcmpi(Fields,'all')
                load([obj.DataFolder,Symbol]) 
            else
                load([obj.DataFolder,Symbol]) 
                [DATASET] = obj.ColumnFiltering(DATASET,Fields);
            end
        end
        function [DATASET_OUT, NoOfDaysSinceLastUpdate] = LOC_Events(obj,Symbol)
            %% 
            DATASET = obj.LOC_Quote(Symbol,'All');
            Date = obj.GetColumn(DATASET,'Date');
            NoOfDaysSinceLastUpdate = today - max(Date);
            
            %%
            Strength = obj.GetColumn(DATASET,'Strength');
            n = find(isnan(Strength) == 0);
            DATASET = DATASET(n,:);
            
            
            nr = get(DATASET);
            VarNames = nr.VarNames(3:end-1);
            y = size(VarNames,2);
            x = size(DATASET,1);
            for i = 2:x
                ROW1 = DATASET(i-1,:);
                ROW2 = DATASET(i,:);
                for j = 1:y
                    Name = VarNames{j};
                    R1 = obj.GetColumn(ROW2,Name);
                    R2 = obj.GetColumn(ROW1,Name);
                    switch class(R1)
                        case 'double'
                            log2 = R1 == R2;
                        case 'char'
                            log2 = strcmpi(R1,R2);
                        case 'cell'
                            log2 = strcmpi(R1{1},R2{1});
                        otherwise
                            log2 = false;
                    end
                    LOG(j) = log2;
                end
                x = size(LOG,2);
                thisperc = sum(LOG)/x;
                perc(i,1) = thisperc;
                if thisperc < 1
                    if exist('DATASET_OUT')
                    DATASET_OUT = [DATASET_OUT;obj.EvaluateChange(ROW1,ROW2)] ;
                    else
                    DATASET_OUT = obj.EvaluateChange(ROW1,ROW2);
                    end
                end
            end
            %Most recent to the top. 
            DATASET_OUT = sortrows(DATASET_OUT,'DaysOld','ascend'); %descend or ascend
        end
        function [DATASET_OUT] = EvaluateChange(obj,RR1,RR2)
            %% Read Data
            Date = obj.GetColumn(RR2,'Date');
            DateStr = {datestr(Date)};
            NoOfBrokers1 = obj.GetColumn(RR1,'NoOfBrokers');
            NoOfBrokers2 = obj.GetColumn(RR2,'NoOfBrokers');            
            MedianTarget1 = obj.GetColumn(RR1,'MedianTarget');
            MedianTarget2 = obj.GetColumn(RR2,'MedianTarget');
            HighEstimate1 = obj.GetColumn(RR1,'HighEstimate');
            HighEstimate2 = obj.GetColumn(RR2,'HighEstimate');  
            LowEstimate1 = obj.GetColumn(RR1,'LowEstimate');
            LowEstimate2 = obj.GetColumn(RR2,'LowEstimate');
            
            MedianTargetDiff = MedianTarget2 - MedianTarget1;
            if MedianTarget1 > MedianTarget2
                Event = {'Downgrade'};
                if NoOfBrokers2 == 2
                    OldTarget = obj.GetColumn(RR1,'LowEstimate');
                    NewTarget = obj.GetColumn(RR2,'LowEstimate');
                else
                    OldTarget = obj.GetColumn(RR1,'LowEstimate');
                    NewTarget = obj.GetColumn(RR2,'LowEstimate'); 
                    Correction = NewTarget/OldTarget;                   
                end
            else
                Event = {'Upgrade'};
                if NoOfBrokers2 == 2
                    OldTarget = obj.GetColumn(RR1,'HighEstimate');
                    NewTarget = obj.GetColumn(RR2,'HighEstimate'); 
                    Correction = NewTarget/OldTarget;
                else
                    OldTarget = obj.GetColumn(RR1,'HighEstimate');
                    NewTarget = obj.GetColumn(RR2,'HighEstimate'); 
                    Correction = NewTarget/OldTarget;                   
                end
            end
            %%
            if and(MedianTarget1 < MedianTarget2, HighEstimate2 == HighEstimate1)
                  OldTarget = MedianTarget1;
                  NewTarget = MedianTarget2;
                  Correction = MedianTarget2/MedianTarget1;
                  MedianTargetDiff = MedianTarget2 - MedianTarget1;
                  Description = {'Median target increase'}; 
                  Event = {'Upgrade'};
            end
            if and(MedianTarget1 > MedianTarget2, HighEstimate2 == HighEstimate1)
                  OldTarget = MedianTarget1;
                  NewTarget = MedianTarget2;
                  Correction = MedianTarget2/MedianTarget1;
                  MedianTargetDiff = MedianTarget2 - MedianTarget1;
                  Description = {'Median target increase'}; 
                  Event = {'Downgrade'};  
            end
            if and(HighEstimate2 < HighEstimate1, MedianTarget1 == MedianTarget2)
                  OldTarget = HighEstimate1;
                  NewTarget = HighEstimate2;
                  Correction = HighEstimate2/HighEstimate1;
                  MedianTargetDiff = HighEstimate2 - HighEstimate1;
                  Description = {'High target decrease'}; 
                  Event = {'Downgrade'};  
            end
            if and(HighEstimate2 > HighEstimate1, MedianTarget1 == MedianTarget2)
                  OldTarget = HighEstimate1;
                  NewTarget = HighEstimate2;
                  Correction = HighEstimate2/HighEstimate1;
                  MedianTargetDiff = HighEstimate2 - HighEstimate1;
                  Description = {'High target increase'}; 
                  Event = {'Upgrade'};                   
            end
            if not(NoOfBrokers1 == NoOfBrokers2)
               if and(and(MedianTarget1 == MedianTarget2,HighEstimate1 == HighEstimate2),LowEstimate1 == LowEstimate2)
                   OldTarget = NaN;
                   NewTarget = NaN;
                   Correction = 1;
                   MedianTargetDiff = 0;
                   Description = {'The Brokers have change their view. The assumption here is purely because the price has dropped an none of the fundamentals have changed'}; 
               else
                   Description = {''}; 
               end               
            else
               if and(and(MedianTarget1 == MedianTarget2,HighEstimate1 == HighEstimate2),LowEstimate1 == LowEstimate2)
                   OldTarget = NaN;
                   NewTarget = NaN;
                   Correction = 1;
                   MedianTargetDiff = 0;
                   Description = {'The Brokers have change their view. The assumption here is purely because the price has dropped an none of the fundamentals have changed'}; 
               else
                   Description = {''}; 
               end               
            end
            %% Number of days old
            DateNum = datenum(DateStr);
            DaysOld = today - DateNum;
            %%
            DATASET_OUT = dataset(DateStr,DateNum,DaysOld,Event,MedianTargetDiff,OldTarget,NewTarget,Correction,Description);  
        end
        function [DATASET] = LOC_GetEvents(obj,Symbol)
            %%
            DATASET = obj.LOC_Quote('YELL','All');
            
            %% Remove Failed Downloads
            [Data] = obj.GetColumn(DATASET,'MedianTarget')
            n = find(isnan(Data)==false);
            DATASET = DATASET(n,:);
            
            [UPDATED,SUMMARY] = obj.CompareQuote(DATASET(1,:),DATASET(2,:))
        end
        function [UPDATED,SUMMARY] = CompareQuote(obj,DATASET1,DATASET2)
            
            [MedianTarget1] = obj.GetColumn(DATASET1,'MedianTarget')
            [MedianTarget2] = obj.GetColumn(DATASET2,'MedianTarget')
        end
        function [DATASET] = LOC_DownloadAll(obj,Symbols)
            %%
            CommObj = 'URL';
            [x] = size(Symbols,1);
            for i = 1:x
                switch lower(CommObj)
                    case 'loc'
                        N_DATASET = obj.LOC_Last_DownloadData(Symbols{i});
                    case 'url'
                        N_DATASET = obj.URL_DownloadData(Symbols{i});
                end
                if i == 1
                    DATASET = N_DATASET;
                else
                    DATASET = [DATASET;N_DATASET];
                end
            end
        end
        function [DATASET,UpToDate] = Sync(obj,Symbol,datenum)
           AttemptAgain = false; %If N/A it will attempet again.
           log = true;
            
           % Load local data.
           Symbol = strrep(Symbol,'.L','');
           try
               [DATASET] = obj.LOC_Quote(Symbol,'All');
               if log == true
                  disp('Local Data Found') 
               end
           catch
               switch obj.Mode
                   case 'url'
                       DATASET = obj.URL_DownloadData(Symbol);
                   case 'wq'
                       DATASET = obj.WQ_DownloadData(Symbol);
                   otherwise
               end
               save([obj.DataFolder,Symbol],'DATASET')
               disp('Data saved')
               UpToDate = false;
               return
           end
           
           % Get today entry
           [Date] = double(GetColumn(obj,DATASET,'Date'));
           n = find(Date == datenum);
           if isempty(n)
               n = find(Date >= datenum);
           end
           if log == true
                disp(['Number of entries with date requested: ',num2str(size(n,1))])
                if size(n,1) > 1
                    disp('warning: 2 many entries')
                end
           end
           S_DATASET = DATASET(n,:);
           if size(n,1) > 1
                Strength = double(GetColumn(obj,S_DATASET,'Strength'));
                n = find(not(isnan(Strength)));
                if isempty(n)
                   n = 1;
                end
                S_DATASET = S_DATASET(n,:);
           end

           % Sync
           if not(isempty(S_DATASET)) %Already uptodate if this is true
              Recommendation = GetColumn(obj,S_DATASET,'Recommendation');
              Recommendation = Recommendation{1,1};
              if or(strcmpi(Recommendation,'No Opinion'),strcmpi(Recommendation,'N/A'))
                  n = find(not(Date == today));
                  DATASET = DATASET(n,:);
                  if AttemptAgain == false
                    UpToDate = true;
                    DATASET = S_DATASET;
                    return                      
                  end
              else
                  UpToDate = true;
                  DATASET = S_DATASET;
                  return 
              end
           end
           switch obj.Mode
               case 'url'
                   N_DATASET = obj.URL_DownloadData(Symbol);
               case 'wq'
                   N_DATASET = obj.WQ_DownloadData(Symbol);
               otherwise
           end
           DATASET = [DATASET; N_DATASET]; 
           save([obj.DataFolder,Symbol],'DATASET');
           disp('Dataset saved')
           UpToDate = false;
           DATASET = N_DATASET;
        end
        function [DATASET,Data] = WQ_DownloadData(obj,Symbol)
            tic
                %% WHAT BROKERS SAY
                time = 1;
                while time <200
                    try
                        obj.WriteWebQuery(Symbol);
                        [num,data,raw] = xlsread('FT.iqy');
                        break
                    catch
                        disp('Connection problems')
                        pause(time);
                        time = time*2;
                    end
                end
                n = find(strcmpi('Analyst Detail',raw(:,1)));
                p = n;
                Data = raw(n:n+5,:);

                    try
                    Latest = cell2mat(Data(2,2:end));
                    n = find(Latest == max(Latest));
                    Recommendation = Data{1,n+1};

                    Strength = max(Latest)/sum(Latest);
                    NoOfBrokers = sum(Latest);

                    %Price Targets
                    String = raw{p+7,:};

                    %% Median Target
                    n = findstr('median target of',String);
                    nString = String(n+16:n+30);
                    i = findstr(',',nString);
                    MedianTarget = str2num(nString(1:i-1));

                    %% High estimate
                    n = findstr('high estimate of',String);                
                    nString = String(n+16:n+30);
                    i = findstr('and',nString);
                    HighEstimate = str2num(nString(1:i-1));

                    %% Low estimate
                    n = findstr('low estimate of',String);               
                    nString = String(n+16:n+30);
                    i = findstr('The',nString);
                    LowEstimate = str2num(nString(1:i-3));
                    
                    if isempty(MedianTarget)
                       n = findstr('share price to rise to',String);
                       nString = String(n+23:n+28);
                       LowEstimate = str2num(nString);
                       HighEstimate = LowEstimate;
                       MedianTarget = LowEstimate;
                    end

                    %% Last Price
                    s = fetch(yahoo,[strrep(Symbol,'.',''),'.L']);
                    LastPrice = s.Last;

                    %%
                    Data = [Data;{'Recommendation',Recommendation,' ',' ',' ',' ',' '}];
                    Recommendation = {Recommendation};
                    Date = today;
                    Symbol = {Symbol};

                    %%
                    if isempty(MedianTarget)
                        MedianTarget = NaN;
                    end
                    if isempty(HighEstimate)
                       HighEstimate = NaN; 
                    end
                    if isempty(LowEstimate)
                       LowEstimate = NaN; 
                    end
                    DATASET = dataset(Date,Symbol,Recommendation,Strength,NoOfBrokers,MedianTarget,HighEstimate,LowEstimate,LastPrice);
                catch
                    Date = today;
                    Recommendation = {'N/A'};
                    Strength = NaN;
                    NoOfBrokers = NaN;
                    MedianTarget = NaN;
                    HighEstimate = NaN;
                    LowEstimate = NaN;
                    s = fetch(yahoo,[Symbol,'.L']);
                    LastPrice = s.Last;
                    LastPrice = LastPrice(1);
                    Symbol = {Symbol};
                    DATASET = dataset(  Date, ...
                                        Symbol, ...
                                        Recommendation, ...
                                        Strength, ...
                                        NoOfBrokers, ...
                                        MedianTarget, ...
                                        HighEstimate, ...
                                        LowEstimate, ...
                                        LastPrice);
                    Data = [];
                    return                    
                end
             toc   
        end
        function [DATASET,Data] = URL_DownloadData(obj,Symbol)
            %
            tic
            s = obj.readURL(Symbol);

            %% Extract Table
            try
                [DATASET,Data] = obj.ExtraDataFromURL(s,Symbol);
            catch % No data available
                [DATASET,Data] = obj.BuildNoAward(Symbol);
            end
            toc
        end
        function [DATASET] = LOC_Today_DownloadData(obj,Symbol)
           String = [obj.DataFolder,strrep(Symbol,'.L','')];
           try
           load(String); 
           catch
                    Date = today;
                    Recommendation = {'N/A'};
                    Strength = NaN;
                    NoOfBrokers = NaN;
                    MedianTarget = NaN;
                    HighEstimate = NaN;
                    LowEstimate = NaN;
                    LastPrice = NaN;
                    Symbol = {Symbol};
                    DATASET = dataset(  Date, ...
                                        Symbol, ...
                                        Recommendation, ...
                                        Strength, ...
                                        NoOfBrokers, ...
                                        MedianTarget, ...
                                        HighEstimate, ...
                                        LowEstimate, ...
                                        LastPrice); 
           end
           [Date] = GetColumn(obj,DATASET,'Date');
           n = find(Date == today);
           DATASET = DATASET(n,:);
        end
        function [DATASET] = LOC_Last_DownloadData(obj,Symbol)
           String = [obj.DataFolder,strrep(Symbol,'.L','')];
           try
           load(String); 
           catch
                    Date = today;
                    Recommendation = {'N/A'};
                    Strength = NaN;
                    NoOfBrokers = NaN;
                    MedianTarget = NaN;
                    HighEstimate = NaN;
                    LowEstimate = NaN;
                    LastPrice = NaN;
                    Symbol = {Symbol};
                    DATASET = dataset(  Date, ...
                                        Symbol, ...
                                        Recommendation, ...
                                        Strength, ...
                                        NoOfBrokers, ...
                                        MedianTarget, ...
                                        HighEstimate, ...
                                        LowEstimate, ...
                                        LastPrice); 
           end
           [Date] = GetColumn(obj,DATASET,'Date');
           n = find(Date == max(Date));
           DATASET = DATASET(n,:);
        end
    end
    methods (Hidden = false) %Performance Analysis
        function [DATASET,Error] = Performance_URL2DataSet(obj,s)
            Error = 0;
            n = findstr(s,'Open');
            crop = s(n:n+4000);
            
            %% Open
            try
                n = findstr(crop,'">');
                Open = crop(n(1)+2:n(2));
                p = findstr(Open,'</span>');
                Open = str2num(strrep(Open(1:p(1)-1),',',''));
            catch
                %likely to be other format
                DATASET = [];
                Error = -1;
                return
            end
            if isempty(Open)
                Open = NaN;
            end
            
            %% AvVolume
            n = findstr(s,'Average Volume');
            AvVolume = s(n:n+100);
            n = findstr(AvVolume,'">');
            AvVolume = AvVolume(n(1)+2:end);
            p = findstr(AvVolume,'</span>');
            AvVolumeStr = AvVolume(1:p-1);
            
            %% Day Low
            n = findstr(s,'Day Low');
            DayLow = s(n:n+100);
            n = findstr(DayLow,'">');
            DayLow = DayLow(n(1)+2:end);
            p = findstr(DayLow,'</span>');
            DayLow = str2num(strrep(DayLow(1:p-1),',',''));
            
            %% Day High
            n = findstr(s,'Day High');
            DayHigh = s(n:n+100);
            n = findstr(DayHigh,'">');
            DayHigh = DayHigh(n(1)+2:end);
            p = findstr(DayHigh,'</span>');
            DayHigh = str2num(strrep(DayHigh(1:p-1),',',''));
            
            %% Official Close
            n = findstr(s,'Official Close');
            OfficialClose = s(n:n+100);
            n = findstr(OfficialClose,'">');
            OfficialClose = OfficialClose(n(1)+2:end);
            p = findstr(OfficialClose,'</span>');
            OfficialClose = str2num(strrep(OfficialClose(1:p-1),',',''));
            if isempty(OfficialClose)
                OfficialClose = NaN;
            end
            
            %% EPS (TTM)
            n = findstr(s,'EPS (TTM)');
            EPS = s(n:n+100);
            n = findstr(EPS,'">');
            EPS = EPS(n(1)+2:end);
            p = findstr(EPS,'<span');
            EPS = str2num(strrep(EPS(1:p-1),',',''));
            if isempty(EPS)
                EPS = NaN;
            end
                        
            %% Div Yield
            n = findstr(s,'Div Yield');
            DivYield = s(n:n+100);
            n = findstr(DivYield,'dataValue ">');
            try
            DivYield = DivYield(n(2)+12:end);
            catch
            DivYield = DivYield(n(1)+12:end);  
            end
            p = findstr(DivYield,'</span');
            DivYield = str2num(strrep(DivYield(1:p-1),'%',''));
            if isempty(DivYield)
                DivYield = NaN;
            end
            
            %% Previous Close
            n = findstr(s,'Previous Close');
            PreviousClose = s(n:n+100);
            n = findstr(PreviousClose,'">');
            PreviousClose = PreviousClose(n(1)+2:end);
            p = findstr(PreviousClose,'</span>');
            PreviousClose = str2num(strrep(PreviousClose(1:p-1),',',''));
            if isempty(PreviousClose)
                PreviousClose = NaN;
            end
            
            %% Div PS (TTM)
            n = findstr(s,'Div PS (TTM)');
            DivPS = s(n:n+100);
            n = findstr(DivPS,'dataValue ">');
            try
            DivPS = DivPS(n(2)+12:end);
            catch
            DivPS = DivPS(n(1)+12:end);
            end
            p = findstr(DivPS,'span');
            DivPS = str2num(strrep(DivPS(1:p-1),'<',''));     
            if isempty(DivPS)
                DivPS = NaN;
            end
            
            %% Div Ex-Date
            n = findstr(s,'Div Ex-Date');
            DivExDate = s(n:n+100);
            n = findstr(DivExDate,'dataValue ">');
            try
            DivExDate = DivExDate(n(2)+12:end);
            catch
            DivExDate = DivExDate(n(1)+12:end);    
            end
            p = findstr(DivExDate,'</span');
            DivExDate = DivExDate(1:p-1);         
            
            %% Shares Outstanding
            n = findstr(s,'Shares Outstanding');
            SharesOutstanding = s(n:n+100);
            n = findstr(SharesOutstanding,'">');
            SharesOutstanding = SharesOutstanding(n(1)+2:end) ; 
            p = findstr(SharesOutstanding,'</span>');
            SharesOutstanding = SharesOutstanding(1:p-1);
            SharesOutstanding = strrep(SharesOutstanding,'<span class="dataValue ">--',' ');
            
            %% Div Pay-Date
            n = findstr(s,'Div Pay-Date');
            DivPayDate = s(n:n+100);
            n = findstr(DivPayDate,'dataValue ">');
            try
            DivPayDate = DivPayDate(n(2)+12:end);
            catch
            DivPayDate = DivPayDate(n(1)+12:end);    
            end
            p = findstr(DivPayDate,'</span');
            DivPayDate = DivPayDate(1:p-1);   
            
            %% Market Cap
            n = findstr(s,'Market Cap');
            MarketCap = s(n:n+100);
            n = findstr(MarketCap,'">');
            MarketCap = MarketCap(n(1)+2:end) ; 
            p = findstr(MarketCap,'</span>');
            MarketCap = strrep(MarketCap(1:p-1),'<span class="currencyCode">',' ');
            MarketCap = strrep(MarketCap,'<span class="dataValue ">--',' ');
            
            %% Next Div Ex-Date
            n = findstr(s,'Next Div Ex-Date');
            NextDivExDate = s(n:n+100);
            n = findstr(NextDivExDate,'">');
            try
            NextDivExDate = NextDivExDate(n(2)+2:end); 
            catch
            NextDivExDate = NextDivExDate(n(1)+2:end);     
            end
            p = findstr(NextDivExDate,'</span>');
            NextDivExDate = strrep(NextDivExDate(1:p-1),'<span class="currencyCode">',' '); 
            
            %% Free Float
            n = findstr(s,'Free Float');
            FreeFloat = s(n:n+100);
            n = findstr(FreeFloat,'">');
            FreeFloat = FreeFloat(n(1)+2:end) ; 
            p = findstr(FreeFloat,'</span>');
            FreeFloat = strrep(FreeFloat(1:p-1),'<span class="currencyCode">',' ');       
            FreeFloat = strrep(FreeFloat,'<span class="dataValue ">--',' ');
            
            %% Next Div Pay-Date
            n = findstr(s,'Next Div Pay-Date');
            NextDivPayDate = s(n:n+100);
            n = findstr(NextDivPayDate,'">');
            try 
            NextDivPayDate = NextDivPayDate(n(2)+2:end) ; 
            catch
            NextDivPayDate = NextDivPayDate(n(1)+2:end) ;     
            end
            p = findstr(NextDivPayDate,'</span>');
            NextDivPayDate = NextDivPayDate(1:p-1);
            
            %% P/E (TTM)
            n = findstr(s,'P/E (TTM)');
            PE = s(n:n+100);
            n = findstr(PE,'">');
            try
            PE = PE(n(2)+2:end); 
            catch
            PE = PE(n(1)+2:end);     
            end
            p = findstr(PE,'</span>');
            PE = PE(1:p-1);            
            
            %%
            DATASET = dataset(  Open, ...
                                {{AvVolumeStr},'AvVolumeStr'}, ...
                                DayLow, ...
                                DayHigh, ...
                                OfficialClose, ...
                                EPS, ...
                                DivYield, ...
                                DivPS, ...
                                {{DivExDate},'DivExDate'}, ...
                                PreviousClose, ...
                                {{SharesOutstanding},'SharesOutstanding'}, ...
                                {{DivPayDate},'DivPayDate'}, ...
                                {{NextDivExDate},'NextDivExDate'}, ...
                                {{NextDivPayDate},'NextDivPayDate'}, ...
                                {{MarketCap},'MarketCap'}, ...
                                {{PE},'PE'}, ...
                                {{FreeFloat},'FreeFloat'} ...
                                );   
        end
        function [DATASET,Error] = URL_DownloadPerformanceData(obj,Symbol)
            h = tic;
            [s,Error] = obj.URLSAVE_Performance(Symbol);            
            if Error == -1
               DATASET = [];
               Error = -1;
               return
            end
            [DATASET] = obj.Performance_URL2DataSet(s);
            toc(h);
        end
        function [s,Error] = URLLOAD_Performance(obj,Symbol,date)
            string = [obj.InstallDir,'Results\Performance\URL\',datestr(date),'\'];
            warning off
            mkdir(string);
            warning on
            try
            load([string,Symbol,'.mat']);
            Error = 0;
            catch
            Error = -1;    
            end
        end
        function [s,Error] = URLSAVE_Performance(obj,Symbol,date)
            %%
            h = tic;
            time = 1;
            timeout = 200;
            Error = 0;
            t1 = 5000;
            while time < timeout
                try
                    url = ['http://markets.ft.com/tearsheets/performance.asp?s=',Symbol,'%3ALSE'];
                    s = urlread2(url,[],[],t1);
                    break
                catch
                    disp('Connection problems')
                    pause(time);
                    time = time*2;
                end
            end
            if time > timeout
                Error = -1;
                DATASET = [];
                return
            end       
            %%
            string = [obj.InstallDir,'Results\Performance\URL\',datestr(date),'\'];
            warning off
            mkdir(string);
            warning on
            save([string,Symbol,'.mat'],'s');
        end
        function URLSAVEALL_Performance(obj,Symbols,date)
            %% Get downloaded symbol set
            PWD = pwd;
            Path = ['C:\SourceSafe\Stocks & Shares\Programs\FinicialTimes\Results\Performance\URL\', datestr(date),'\'];
            try
            cd(Path);
            catch
            mkdir(Path)
            cd(Path)
            end
            
            names = dir;
            names = rot90(struct2cell(names));
            SymbolDownloaded = strrep(names(1:end-3,1),'.mat','');
            cd(PWD)
            %%
            [x] = size(Symbols,1);
            h = waitbar(0);
            for i = 1:x
                drawnow;
                waitbar(i/x,h,[num2str(i),' of ',num2str(x)]);
                
                if isempty(find(strcmpi(Symbols{i},SymbolDownloaded)))
                    obj.URLSAVE_Performance(Symbols{i},date);
                    disp([Symbols{i},': Required']);
                else
                    disp([Symbols{i},': Not required']);
                end
            end            
        end
        function [DATASET,Error] = WQ_DownloadPerformanceData(obj,Symbol)
                %% 
                tic
                time = 1;
                while time <200
                    try
                        obj.WritePerfWebQuery(Symbol);
                        [num,data,raw] = xlsread('FT.iqy');
                        break
                    catch
                        disp('Connection problems')
                        pause(time);
                        time = time*2;
                    end
                end
                count = 0;
                
                %% Market Cap
                try
                n = find(strcmpi('Market Cap',raw(:,1)));
                MarketCap = strrep(raw{n,2},'GBP','');
                catch
                    try
                    n = find(strcmpi('Market Cap*',raw(:,1)));
                    MarketCap = strrep(raw{n,2},'GBP',''); 
                    catch
                    MarketCap = '';   
                    count = count + 1;
                    end
                end
                
                %% EPS (TTM)
                try
                    n = find(strcmpi('EPS (TTM)',raw(:,4)));
                    
                    EPS = strrep(raw{n,5},'GBX','');
                    EPS = str2double(strrep(EPS,',',''));
                    if isempty(EPS)
                       EPS = NaN; 
                    end
                catch
                    EPS = NaN;
                    count = count + 1;
                end
                
                %% Shares Outstanding
                try
                n = find(strcmpi('Shares Outstanding',raw(:,1)));
                    SharesOutstanding = raw{n,2};
                catch
                    SharesOutstanding = '';
                    count = count + 1;
                end

                DATASET = dataset({{Symbol},'Ticker'},{{MarketCap},'MarketCap'},EPS,{{SharesOutstanding},'SharesOutstanding'});
                toc
                if count == 3
                    disp([Symbol,' - No Data'])
                    Error = -1;
                else
                    disp([Symbol,' - Found'])
                    Error = 0;
                end
        end
        function DATASET = LOC_GetPerformanceData(obj,Symbols)
            %%
            DataSet = obj.LoadLastResult('FinicialTimes','Performance');
            %
            Ticker = obj.GetColumn(DataSet,'Ticker');   
            [x] = size(Symbols,1);
            for i = 1:x
                Symbol = Symbols{i};
                n = find(strcmpi(Ticker,Symbol));
                if isempty(n)
                    Entry = dataset({{Symbol},'Ticker'}, ...
                                    {NaN,'Open'}, ...
                                    {{''},'MarketCap'}, ...
                                    {NaN,'EPS'}, ...
                                    {{''},'SharesOutstanding'});
                    
                else
                    Entry = DataSet(n,:);
                    Entry = obj.ColumnFiltering(Entry, {    'Ticker', ...
                                                            'Open', ...
                                                            'MarketCap', ...
                                                            'EPS', ...
                                                            'SharesOutstanding'});
                end
                
                %
                if i == 1
                    NewDataSet = Entry;
                else
                    NewDataSet = [NewDataSet;Entry];
                end
            end
            DATASET = NewDataSet;
        end
        function DATASET = AllPerformanceData(obj,Symbols)
            %%
%             try
                [x] = size(Symbols,1)
                h = waitbar(0);
                for i = 1:x
                    drawnow
                    waitbar(i/x,h,[num2str(i),' of ',num2str(x)]);
                    if strcmpi(lower(obj.Mode),'wq')
                        N_DATASET = obj.WQ_DownloadPerformanceData(Symbols{i});
                    else
                        [N_DATASET,error] = obj.URL_DownloadPerformanceData(Symbols{i});
                    end
                    if i == 1
                        DATASET = N_DATASET;
                    else
                        if error == 0;
                            try
                                if exist('DATASET') == 1
                                DATASET = [DATASET;N_DATASET];
                                else
                                DATASET = N_DATASET;    
                                end
                            catch
                                disp('hello')
                            end
                        end
                    end
                end
%             catch
%                 warning(['Process exited prematurely at ',Symbols{i},' - ',[num2str(i),' of ',num2str(x)]])
%             end
        end
        function [DATASET] = LOC_AllPerformanceData(obj,Symbols,date)
            log = true;
            [x] = size(Symbols,1);
            if x == 0
               error('Symbols set is empty') 
            end
            h = waitbar(0);
            for i = 1:x
                drawnow
                if log == true
                    disp(['Symbol: ',Symbols{i}])
                end
                waitbar(i/x,h,[num2str(i),' of ',num2str(x)]);
                [s,Error] = obj.URLLOAD_Performance(Symbols{i},date);
                [N_DATASET,Error] = obj.Performance_URL2DataSet(s);
                if Error == -1
                   disp([Symbols{i},' is likely another format']) 
                end
                if Error == 0;
                    Ticker = Symbols(i);
                    N_DATASET = [dataset(Ticker),N_DATASET];
                    try
                        if exist('DATASET') == 1
                        DATASET = [DATASET;N_DATASET];
                        else
                        DATASET = N_DATASET;    
                        end
                    catch
                        disp('hello')
                    end
                end
            end
        end
        function DATASET = Add_MarketCapNum(obj,DataSet)
            %%
            MarketCap = obj.GetColumn(DataSet,'MarketCap');
            [x] = size(MarketCap,1);
            
            %% Top is default
            Currencys = {   'GBP'; ...
                            'PLN'; ...
                            'USD'; ...
                            'EGP'; ...
                            'AUD'; ...
                            'THB'; ...
                            'NOK'; ...
                            'RUB'; ...
                            'CAD'; ...
                            'EUR'; ...
                            'INR'; ...
                            'TWD'; ...
                            'SEK'; ...
                            'CHF'; ...
                            'JPY'; ...
                            'KZT'; ...
                            'NGN'; ...
                            'ARS'; ...
                            'ZAR'; ...
                            'ILS'; ...
                            'IDR'; ...
                            'HKD'; ...
                            'DKK'; ...
                            'ISK'; ...
                            'KRW'};
            %%            
            Exps= { 't',    1000000000000; ...
                    'bn',   1000000000; ...
                    'm',    1000000; ...
                    'k',    1000; ...
                     };
                    
            y = size(Currencys,1);
            z = size(Exps,1);
            Amount = zeros(x,1);
            AmountNum = zeros(x,1);
            Exp = cell(x,1);
                            
            %%                
            for i = 1:x
                % Currency & AmountStr
                MarketCapStr = MarketCap{i};
                n1 = findstr(MarketCapStr,Currencys{2,1});
                if isempty(n1)
                   Currency{i,1} = Currencys{1,1};
                   AmountStr{i,1} = strrep(MarketCapStr,Currencys{1,1},'');
                else
                   Currency{i,1} = Currencys{2,1};
                   AmountStr{i,1} = strrep(MarketCapStr,Currencys{2,1},'');
                end
                %%
                for j = 3:y
                    n1 = findstr(MarketCapStr,Currencys{j});
                    if not(isempty(n1))
                       Currency{i,1} = Currencys{j,1};
                       AmountStr{i,1} = strrep(MarketCapStr,Currencys{j,1},'');
                    end                      
                end
                

                %% Exp 10^n
                for k = 1:z
                    n1 = findstr(AmountStr{i,1},Exps{k,1});
                    if not(isempty(n1))
                        Exp{i,1} = Exps{k,1};
                        try
                        Amount(i,1) = str2num(strrep(AmountStr{i,1},Exps{k,1},''));
                        catch
                           x = 1 
                        end
                        AmountNum(i,1) = Amount(i,1)*Exps{k,2};
                    end
                end
            end
            DATASET = [DataSet,dataset(Currency,AmountStr,Exp,Amount,AmountNum)];
        end
        function DATASET = Add_MarketCapInDollars(obj,DataSet)
            ExchangeRate = {    'GBP',  1.61026; ...
                                'PLN',  0.345450; ...
                                'USD',  1; ...
                                'EGP',  0.183655; ...
                                'AUD',  0.904134; ...
                                'THB',  0.0302673; ...
                                'NOK',  0.172516; ...
                                'RUB',  0.0334952; ...
                                'CAD',  0.947254; ...
                                'EUR',  1.41576; ...
                                'INR',  0.0217226; ...
                                'TWD',  0.0313050; ...
                                'SEK',  0.138437; ...
                                'CHF',  0.961056; ...
                                'JPY',  0.0110999; ...
                                'KZT',  0.00676361; ...
                                'NGN',  0.00664452; ...
                                'ARS',  0.262605; ...
                                'ZAR',  0.131586; ...
                                'DKK',  0.190139; ...
                                'KRW',  0.000555894; ...
                                'ILS',  0.180492; ...
                                'IDR',  0.0000742348; ...
                                'HKD',  0.0889134; ...
                                'ISK',  0.00533947};
                
            Currency = obj.GetColumn(DataSet,'Currency');
            AmountNum = obj.GetColumn(DataSet,'AmountNum');
            
            [x] = size(Currency,1);
            for i = 1:x
                n = find(strcmpi(Currency{i},ExchangeRate(:,1)));
                Rate = ExchangeRate{n,2};
                MarketCapInDollars(i,1) = AmountNum(i)*Rate;
            end
            DATASET = [DataSet,dataset(MarketCapInDollars)];
        end
        function DATASET = Add_MarketCapCategory(obj,DataSet)
            t  = 1000000000000;
            bn = 1000000000; 
            m  = 1000000;
            k  = 1000; 
                    
            %$       Cat           Low      High
            Cat = { 'Big Cap',    10*bn,    inf; ... 
                    'Mid Cap',    2*bn,     10*bn; ...
                    'Small Cap',  300*m,    2*bn; ... 
                    'Micro Cap',  50*m,     300*m; ... 
                    'Nano Cap',   0,        50*m};
                
            MarketCapInDollars = obj.GetColumn(DataSet,'MarketCapInDollars');
            x = size(MarketCapInDollars,1);
            for i = 1:x
                if MarketCapInDollars(i) == 0
                    MarketCapCategory{i,1} = 'N/A';
                end
                % Nano Cap
                if MarketCapInDollars(i) > Cat{5,2};
                    MarketCapCategory{i,1} = Cat{5,1};
                end
                % Micro Cap
                if MarketCapInDollars(i) > Cat{4,2};
                    MarketCapCategory{i,1} = Cat{4,1};
                end
                % Small Cap
                if MarketCapInDollars(i) > Cat{3,2};
                    MarketCapCategory{i,1} = Cat{3,1};
                end
                % Mid Cap
                if MarketCapInDollars(i) > Cat{2,2};
                    MarketCapCategory{i,1} = Cat{2,1};
                end
                % Big Cap
                if MarketCapInDollars(i) > Cat{1,2};
                    MarketCapCategory{i,1} = Cat{1,1};
                end
            end
            DATASET = [DataSet,dataset(MarketCapCategory)];
        end
    end
    methods (Hidden = true)
        function [DATASET,Data] = BuildNoAward(obj,Symbol)
            Date = today;
            Recommendation = {'N/A'};
            Strength = NaN;
            NoOfBrokers = NaN;
            MedianTarget = NaN;
            HighEstimate = NaN;
            LowEstimate = NaN;
            Symbol = {Symbol};
            DATASET = dataset(  Date, ...
                                Symbol, ...
                                Recommendation, ...
                                Strength, ...
                                NoOfBrokers, ...
                                MedianTarget, ...
                                HighEstimate, ...
                                LowEstimate);
            Data = [];            
        end
        function [DATASET,Data] = ExtraDataFromURL(obj,s,Symbol)
            Data1 = obj.ExtractTable(s);
            Top = {'Buy','Outperform','Hold','Underperform','Sell','No Opinion'};
            Table = [Top;num2cell(Data1);{'','','','','',''}];    
            Labels = {  'Analyst Detail'; ...
                        'Latest'; ...           
                        '4 weeks ago'; ...    
                        '2 months ago'; ...    
                        '3 months ago'; ...   
                        'Last year'; ...        
                        'Recommendation'};
            Data = [Labels,Table];
            n = find(max(Data1(1,:))==Data1(1,:));
            Data(end,2) = Top(n(1));

            Recommendation = Top{n(1)};

            Strength = max(Data1(1,:))/sum(Data1(1,:));
            NoOfBrokers = sum(Data1(1,:));                 

            %% Median Target
            n = findstr('median target of',s);
            nString = s(n+16:n+30);
            i = findstr(', with',nString);
            MedianTarget = str2num(strrep(nString(1:i-1),',',''));
           

            %% High estimate
            n = findstr('high estimate of',s);                
            nString = s(n+16:n+30);
            i = findstr('and',nString);
            HighEstimate = str2num(strrep(nString(1:i-1),',',''));

            %% Low estimate
            n = findstr('low estimate of',s);               
            nString = s(n+16:n+30);
            i = findstr('The',nString);
            LowEstimate = str2num(strrep(nString(1:i-3),',',''));

            if isempty(MedianTarget)
            string = 'share price to rise to';
            p = size(string,2);
            n = findstr(string,s);
            nString = s(n+p+1:n+40);
            q = findstr(nString,' ');
            nString = strrep(nString(1:q(1)),',','');
            LowEstimate = str2num(nString);
            HighEstimate = LowEstimate;
            MedianTarget = LowEstimate;
            end
                    
            %% Last Price

            Recommendation = {Recommendation};
            Date = today;
            Symbol = {Symbol};

            %%
            if isempty(MedianTarget)
                MedianTarget = NaN;
            end
            if isempty(HighEstimate)
               HighEstimate = NaN; 
            end
            if isempty(LowEstimate)
               LowEstimate = NaN; 
            end
            DATASET = dataset(Date,Symbol,Recommendation,Strength,NoOfBrokers,MedianTarget,HighEstimate,LowEstimate);            
        end
        function Price = LastPrice(obj,Symbol)
            time = 1;
            while time <200
                try
                    s = fetch(yahoo,[strrep(Symbol,'.',''),'.L']);
                    break
                catch
                    disp(['Connection problems: Wait',num2str(time)])
                    pause(time);
                    time = time*2;
                end
            end
            
            Price = s.Last;           
        end
        %TODO:  make write web query more eligant
        function WriteWebQuery(obj,Symbol)
            % For brokers view
            fid = fopen('FT.iqy', 'w');
            fprintf(fid, [ ...
                'WEB\n',...
                '1\n', ...
                'http://markets.ft.com/tearsheets/analysis.asp?s=',Symbol,'%%3ALSE\n', ...
                '\n', ...
                'Selection=EntirePage\n', ...
                'Formatting=None\n', ...
                'PreFormattedTextToColumns=True\n', ...
                'ConsecutiveDelimitersAsOne=True\n', ...
                'SingleBlockTextImport=False\n', ...
                'DisableDateRecognition=False\n', ...
                'DisableRedirections=False']);
            fclose(fid);
        end
        function WritePerfWebQuery(obj,Symbol)
            % For Performance Data
            fid = fopen('FT.iqy', 'w');
            fprintf(fid, [ ...
                'WEB\n',...
                '1\n', ...
                'http://markets.ft.com/tearsheets/performance.asp?s=',Symbol,'%3ALSE\n', ...
                '\n', ...
                'Selection=EntirePage\n', ...
                'Formatting=None\n', ...
                'PreFormattedTextToColumns=True\n', ...
                'ConsecutiveDelimitersAsOne=True\n', ...
                'SingleBlockTextImport=False\n', ...
                'DisableDateRecognition=False\n', ...
                'DisableRedirections=False']);
            fclose(fid);
        end
        function [obj] = FilterInvested(varargin)
            obj = varargin{1};
            State = get(obj.handles.filter2,'State');
            persistent TableArray 
            switch State
                case 'on'
                    TableArray = get(obj.handles.table,'Data');
                    
                    InvestedSymbols = obj.Symbols;
                    
                    [x] = size(InvestedSymbols,1);
                    
                    Array = [];
                    for i = 1:x
                        %Filter on BUY
                        Symbol = InvestedSymbols{i};
                        [x] = size(TableArray,1);
                        n = find(strcmpi(TableArray(:,2),Symbol));
                        Line = TableArray(n,:);
                        Array = [Array;Line];
                    end
                    
                    set(obj.handles.table,'Data',Array);
                case 'off'                    
                    set(obj.handles.table,'Data',TableArray);
                otherwise
            end
        end
        function Data = DecodeLine(obj,Line1)
                %%
                n = findstr(Line1,'</td>');
                [x] = size(n,2);
                String = Line1(1:n(1));
                p = findstr(String,'>');
                p = p(end);
                Data(1,1) = str2num(String(p+1:end-1));
                for i = 2:x
                    String = Line1(n(i-1):n(i));
                    p = findstr(String,'>');
                    p = p(end);
                    Data(i,1) = str2num(String(p+1:end-1));
                end
        end
        function delete(obj)
            close(obj.handles.figure);
            stop(obj.handles.timer);
        end
        function Data = ExtractTable(obj,s)
                nstart = findstr('Latest',s);
                nend = findstr('Analyst',s(nstart:end));
                Table = s(nstart:nstart+nend);
                
                %% Line 1
                nstart = findstr(Table,'Latest');
                nend = findstr(Table,'4 weeks ago');
                Line1 = Table(nstart+17:nend);
                Data1 = rot90(obj.DecodeLine(Line1));
  
                %% Line 2
                nstart = findstr(Table,'4 weeks ago');
                nend = findstr(Table,'2 months ago');
                Line2 = Table(nstart+16:nend);
                Data2 = rot90(obj.DecodeLine(Line2));
                
                %% Line 3
                nstart = findstr(Table,'2 months ago');
                nend = findstr(Table,'3 months ago');
                Line3 = Table(nstart+16:nend);
                Data3 = rot90(obj.DecodeLine(Line3));
                
                %% Line 4
                nstart = findstr(Table,'3 months ago');
                nend = findstr(Table,'Last year');
                Line4 = Table(nstart+16:nend);
                Data4 = rot90(obj.DecodeLine(Line4));
                
                %% Line 5
                nstart = findstr(Table,'Last year');
                Line5 = Table(nstart+16:end);
                Data5 = rot90(obj.DecodeLine(Line5));
                
                Data = [Data1;Data2;Data3;Data4;Data5];
        end
        function [s,Error] = readURL(obj,Symbol)
            time = 1;
            t1 = 10000; %10 secs
            timeout = 1000;
            Error = 0;
            while time < timeout
                try
                    old = ['http://markets.ft.com/tearsheets/analysis.asp?s=',Symbol,'%3ALSE'];
                    [s] = urlread2(old,[],[],t1);
                    break
                catch
                    disp(['Connection problems: Wait',num2str(time)])
                    pause(time);
                    time = time*2;
                end
            end
            if time > timeout
                s = [];
                Error = -1;
            end
        end
    end
    methods (Hidden = true) %GUI
        function [obj] = CreateMaxGUI(obj)
            %%
            obj.handles.figure = figure('Toolbar','none',...
                                        'Visible',obj.Visible, ...
                                        'Menubar','none');
            set(obj.handles.figure, 'Name',[obj.ProgramName,' - Viewer (R',num2str(obj.Rev),')'], ...
                                    'NumberTitle','off');
            
            obj.handles.table = uitable( obj.handles.figure, ...
                    'Data', [], ...
                    'ColumnName', []);
                
            set(obj.handles.figure,'ResizeFcn',@obj.Resize);
            
            %Toolbar
            image = imread([obj.InstallDir,'Icons\refresh3.jpg']);
            image = imresize(image,[16,16]);
            
            obj.handles.status = uicontrol( 'Style','text', ...
                                            'Position',[2,2,100000,22], ...
                                            'HorizontalAlignment','left', ...
                                            'String','Ready');
                                        
            obj.handles.toolbar = uitoolbar(obj.handles.figure);
            obj.handles.refresh = uipushtool(obj.handles.toolbar,'CDATA',image, ...
                                                'TooltipString','Refresh', ...
                                                'ClickedCallback',@obj.UpdateTable);
            
            image = imread([obj.InstallDir,'Icons\ticker2.jpg']);
            image = imresize(image,[16,16]);
            obj.handles.auto = uitoggletool(obj.handles.toolbar,'CDATA',image, ...
                                                'TooltipString','Auto-Updater');

            image = imread([obj.InstallDir,'Icons\Filter.jpg']);
            image = imresize(image,[16,16]);
            obj.handles.filter = uitoggletool(obj.handles.toolbar,'CDATA',image, ...
                                                'TooltipString','Filter On Best Buys');
                                            
            image = imread([obj.InstallDir,'Icons\Filter2.jpg']);
            image = imresize(image,[16,16]);
            obj.handles.filter2 = uitoggletool(obj.handles.toolbar,'CDATA',image, ...
                                                'TooltipString','Filter On Invested Symbols');
                                                      
            set(obj.handles.filter,'ClickedCallback',@obj.Filter);
            set(obj.handles.filter2,'ClickedCallback',@obj.FilterInvested);
                                            
           
        end 
        function [obj] = CreateMinimalGUI(obj)
            %%
            obj.handles.figure = waitbar(0,['Schedule Start Time: ']);
            set(obj.handles.figure, 'Name',[obj.ProgramName,' - Downloader (R',num2str(obj.Rev),')'], ...
                                    'NumberTitle','off');
            
            %Toolbar
            image = imread([obj.InstallDir,'Icons\refresh3.jpg']);
            image = imresize(image,[16,16]);
                                        
            obj.handles.toolbar = uitoolbar(obj.handles.figure);
            obj.handles.refresh = uipushtool(obj.handles.toolbar,'CDATA',image, ...
                                                'TooltipString','Refresh', ...
                                                'ClickedCallback',@obj.Update);
            
            image = imread([obj.InstallDir,'Icons\ticker2.jpg']);
            image = imresize(image,[16,16]);
            obj.handles.auto = uitoggletool(obj.handles.toolbar,'CDATA',image, ...
                                                'TooltipString','Auto-Updater');
        end
        function [obj] = Resize(varargin)
            obj = varargin{1};
            Position = get(obj.handles.figure,'position');
            set(obj.handles.table,'Position',[1,25,Position(3),Position(4)-25])
        end%Not Review
        function [] = FilterOnBestBuys(obj)
            set(obj.handles.filter,'State','on');
            obj.Filter;
        end
        function writecsv(obj,FileName,DATA)
            fid = fopen(FileName, 'wt');
            [x,y] = size(DATA);
            for i = 1:x
                for j = 1:y
                    Entry = DATA{i,j};
                    switch class(Entry)
                        case 'char'
                            %do nothing
                        case 'double'
                            Entry = num2str(Entry);
                        otherwise
                            error('class not recoginised');
                    end
                    if j == 1
                        Line = [Entry];
                    else
                        Line = [Line,',',Entry];
                    end
                end
                fprintf(fid, [Line,'\n'], y);
            end
            fclose(fid);
        end
    end
    methods (Hidden = true) %Obselete
        function ConvertMat2Dataset(obj)
            CD = pwd;
            cd([obj.InstallDir,'\DATA\']);
            names = struct2cell(dir);
            names = names(1,3:end);
            [x] = size(names,2);
            h = waitbar(0);
            for i = 1:x
                try
                waitbar(i/x,h);
                load(names{i})
                Date = cell2mat(Dat(:,1));
                Symbol = Dat(:,2);
                Recommendation = Dat(:,3);
                Strength = cell2mat(Dat(:,4));
                NoOfBrokers = cell2mat(Dat(:,5));
                MedianTarget = obj.cell2mat(Dat(:,6));
                HighEstimate = obj.cell2mat(Dat(:,7));
                LowEstimate = obj.cell2mat(Dat(:,8));
                LastPrice = cell2mat(Dat(:,9));
                DATASET = dataset(  Date, ...
                                    Symbol, ...
                                    Recommendation, ...
                                    Strength, ...
                                    NoOfBrokers, ...
                                    MedianTarget, ...
                                    HighEstimate, ...
                                    LowEstimate, ...
                                    LastPrice);
                save([obj.InstallDir,'\NewData\',names{i}],'DATASET');
                end
            end
            cd(CD)
        end
        function out = cell2mat(obj,in)
            [x] = size(in,1);
            for i = 1:x
                try
                out(i,1) = in{i};
                catch
                out(i,1) = NaN;   
                end
            end
        end
    end
end