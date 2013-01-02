classdef Reliabilty <   handle & ...
                        DataSetFiltering & ...
                        ResultsLog & ...
                        StructureManagement
    properties
        log = false;
    end
    methods
        function obj = Reliabilty()
            %%
            try
                cd('P:\StockData [MEDIAPC]\StockData [MEDIAPC]\')
                obj.ResultsDir = 'P:\StockData [MEDIAPC]\StockData [MEDIAPC]\';
%                 obj.MacroLogDir = 'P:\StockData [MEDIAPC]\StockData [MEDIAPC]\';
            catch
                obj.ResultsDir = 'P:\StockData [MEDIAPC]\';
%                 obj.MacroLogDir = 'P:\StockData [MEDIAPC]\';
            end
            disp(['ResultsDir: ',obj.ResultsDir])
        end
        function DATASET = WeekReportAll(obj)
            %%
            datenum = today;
            ProgramName = 'BritishBulls';
            ResultName = 'ALL_STATUS';
            
            Struct = obj.BuildProgramMacroArray;
            
            Struct.Yahoo.BB_RT_Confirmation.Frequency = 2;
            
            Struct.BritishBulls.CurrentEvent.Type = 'Weekly';
            Struct.BritishBulls.CurrentEvent.Frequency = 1;
            
            Struct.DigitalLook.Forecasts.Type = 'Weekly';
            Struct.DigitalLook.Forecasts.Frequency = 1; 
            
            Struct.Yahoo.MasterBUYconfQuote.Type 
            Struct.Yahoo.MasterBUYconfQuote.Frequency = 3;            
            
            %%
            ProgramNames = fieldnames(Struct);
            x = size(ProgramNames,1);
            start = true;
            count = 1;
            for i = 1:x
                ResultNames = fieldnames(Struct.(ProgramNames{i}));
                y = size(ResultNames,1);
                for j = 1:y
                    if strcmpi(Struct.(ProgramNames{i}).(ResultNames{j}).Type,'WeekDaysOnly');
                        ProgramNamesList{count,1} = ProgramNames{i};
                        ResultNamesLIst{count,1} = ResultNames{j};
                        
                        Prog = ProgramNames{i};
                        Res = ResultNames{j};
                        
                        Short{count,1} = [Prog(1:4),'_',Res(1:4)];
                        
                        N_DATASET = obj.WeekReport(ProgramNames{i},ResultNames{j},datenum);
                        count = count + 1;
                        if start == true
                            DATASET = N_DATASET;
                            start = false;
                        else
                            DATASET = [DATASET;N_DATASET];
                        end
                    end
                end
            end
            %%
            DATASET = [dataset(Short),DATASET];
        end
        function DATASET = WeekReport_ALL_URL(obj,Date,Name,Type)
            %%
            % DATASET = obj.WeekReport_ALL_URL(Date)
            DATA = {    'ADVFN',          'Finacials'; ...
                        'BritishBulls',   'ALL_STATUS'; ...
                        'BritishBulls',   'CurrentEvent'; ...
                        'DigitalLook',    'Symbol2Num'; ...
                        'FinicialTimes',  'Analysis'; ...
                        'FinicialTimes',  'Performance'; ...
                        'NewsAlerts',     'RNS'; ...
                        'SharePrice',     'Summary'; ...
                        'Stox',           'Best_Investments'; ...
                        'WhatBrokersSay', 'BrokersView'; ...
                        'NakedTrader',    'Shares'};
                        
            
           String = ['Y:\Schedular\Track\',Name,'_',strrep(datestr(Date),'-','_'),'.mat'];
           struct = load(String);
           struct = struct.struct;
           
           
           Macros = fieldnames(struct.detial.URL_Download);
           for i = 1:max(size(DATA))
                ProgramName = DATA(i,1);
                MacroName = DATA(i,2);
                if i == 1
                DATASET = obj.WeekReport(ProgramName{1},MacroName{1},Type,Date);
                DATASET = [dataset(ProgramName,MacroName),DATASET];
                else
                N_DATASET = obj.WeekReport(ProgramName{1},MacroName{1},Type,Date); 
                N_DATASET = [dataset(ProgramName,MacroName),N_DATASET];
                DATASET = [DATASET;N_DATASET];
                end
           end 
        end
        function DATASET = WeekReport(obj,ProgramName,ResultName,Type,datenum) 
            % Example:
            % ========
            % ProgramName = 'WhatBrokersSay';
            % ResultName = 'BrokersView';
            % Type = 'URL';
            % DATASET = obj.WeekReport(ProgramName,ResultName,Type,today) 
            log = false;
            [DateNum, error] = obj.GetResultDateNums(ProgramName,ResultName,Type);
            DateNum = floor(DateNum);
            
            %Get the day of the week
            Day = datestr(datenum,'DDD');
            
            %Calculate Date range for analysis
            switch lower(Day)
                case 'mon'
                    DateRange = [today];
                case 'tue'
                    DateRange = [today-1:today];
                case 'wed'
                    DateRange = [today-2:today];
                case 'thu'
                    DateRange = [today-3:today];
                case 'fri'
                    DateRange = [today-4:today];
                case 'sat'
                    DateRange = [today-5:today];
                case 'sun'
                    DateRange = [today-6:today];
            end
            if log == true
            disp(['DateRange: ',datestr(DateRange(1)),' - ',datestr(DateRange(end))])
            end
            
            for i = 1:7
                Status{i} = 'N/A';
            end
            %Get Status for each day.
            x = size(DateRange,2);
            for i = 1:x
                Date = DateRange(i);
                n = find(DateNum==Date);
                if isempty(n)
                    Status{i} = 'FALSE';
                else
                    Status{i} = 'TRUE ';
                end
            end           
            DATASET = dataset({Status(1),'Mon'},{Status(2),'Tues'},{Status(3),'Wed'},{Status(4),'Thurs'},{Status(5),'Fri'},{Status(6),'Sat'},{Status(7),'Sun'});
        end
        function Status2 = OverallReport(obj,datenum)
            %% program names
            Struct = obj.BuildProgramMacroArray(obj.DataPath);
            
            %%
            Struct.Yahoo.BB_RT_Confirmation.Frequency = 2;
            
            Struct.BritishBulls.CurrentEvent.Type = 'Weekly';
            Struct.BritishBulls.CurrentEvent.Frequency = 1;
            
            Struct.DigitalLook.Forecasts.Type = 'Weekly';
            Struct.DigitalLook.Forecasts.Frequency = 1;
            
            Struct.Yahoo.MasterBUYconfQuote.Type = 'WeekDaysOnly';
            Struct.Yahoo.MasterBUYconfQuote.Frequency = 3; 
            
            Struct.Yahoo.SellConfirmation.Enable = 'FALSE';
            Struct.Yahoo.Confirmation.Enable = 'FALSE';
            
            %%
            Status = obj.EvaluateTheArray(Struct);
            Status = obj.UpToDate(Status,datenum);
            %
            obj.PlotBarGraph(Status);
            %%
            Status2 = obj.ColumnFiltering(Status,{'ProgramName','ResultName','NumberOfDaysSinceLastUpdate'});
            Status2 = sortrows(Status2,3,'descend');
        end
        function Table = HistTimeDurationALL(obj)
            %%
            DATA = {    'ADVFN',          'Finacials'; ...
                        'BritishBulls',   'ALL_STATUS'; ...
                        'BritishBulls',   'CurrentEvent'; ...
                        'DigitalLook',    'Symbol2Num'; ...
                        'FinicialTimes',  'Analysis'; ...
                        'FinicialTimes',  'Performance'; ...
                        'NewsAlerts',     'RNS'; ...
                        'SharePrice',     'Summary'; ...
                        'Stox',           'Best_Investments'; ...
                        'WhatBrokersSay', 'BrokersView'};       
            x = size(DATA,1);
            for i = 1:x
                Program = DATA{i,1};
                MacroName = DATA{i,2};
                temp = obj.HistTimeDuration(Program,MacroName);
                temp.Program = Program;
                temp.MacroName = MacroName;
                outStruct(i) = temp;
            end
            
            %%
            Table = obj.struct2Table(outStruct);
        end
        function outStruct = HistTimeDuration(obj,ProgramName,MacroName)
            %%           
            [DateNum, error] = obj.GetResultDateNums(ProgramName,MacroName,'URL');
            x = max(size(DateNum));
            h = waitbar(0);
            for i = 1:x
                waitbar(i/x,h);
                struct(i) = obj.ResultsFolderDurationInfo(ProgramName,MacroName,'URL',DateNum(i));
            end
            close(h)
            %%
            Duration        = obj.GetField(struct,'Duration');
            StartTime       = obj.GetField(struct,'StartTime');
            EndTime         = obj.GetField(struct,'EndTime');
            NumberOfEntries = obj.GetField(struct,'NumberOfEntries');
            
            
            outStruct.MaxDuration   = datestr(max(datenum(Duration))    ,'HH:MM:SS');
            outStruct.MinDuration   = datestr(min(datenum(Duration))    ,'HH:MM:SS');
            
            outStruct.MinStartTime  = datestr(min(datenum(StartTime))   ,'HH:MM:SS');
            outStruct.MaxStartTime  = datestr(max(datenum(StartTime))   ,'HH:MM:SS');
            
            outStruct.MinEndTime    = datestr(min(datenum(EndTime))     ,'HH:MM:SS');
            outStruct.MaxEndTime    = datestr(max(datenum(EndTime))     ,'HH:MM:SS');
            
            outStruct.MinNumberOfEntrie    = min(cell2mat(NumberOfEntries));
            outStruct.MaxNumberOfEntrie    = max(cell2mat(NumberOfEntries));
        end
        function DATASET = TimeDurationSummary(obj,Date)
            %%
            
            DATA = {    'ADVFN',          'Finacials'; ...
                        'BritishBulls',   'ALL_STATUS'; ...
                        'BritishBulls',   'CurrentEvent'; ...
                        'DigitalLook',    'Symbol2Num'; ...
                        'FinicialTimes',  'Analysis'; ...
                        'FinicialTimes',  'Performance'; ...
                        'NewsAlerts',     'RNS'; ...
                        'SharePrice',     'Summary'; ...
                        'Stox',           'Best_Investments'; ...
                        'NakedTrader',    'Shares'; ...
                        'WhatBrokersSay', 'BrokersView'};       
            x = size(DATA,1);
            for i = 1:x
                try
                Program = DATA{i,1};
                MacroName = DATA{i,2};
                struct(i) = obj.ResultsFolderDurationInfo(Program,MacroName,'URL',Date);
                catch
                struct(i).StartTime = 'N/A';    
                struct(i).EndTime = 'N/A';
                struct(i).Duration = 'N/A'; 
                struct(i).NumberOfEntries = NaN;
                end
            end
            
            %
            for i = 1:max(size(struct))
                StartTime{i,1} = struct(i).StartTime;
                EndTime{i,1} = struct(i).EndTime;
                Duration{i,1} = struct(i).Duration;
                NumberOfEntries(i,1) = struct(i).NumberOfEntries;
            end
            DATASET = dataset({DATA(:,1),'ProgramName'},{DATA(:,2),'MacroName'},StartTime,EndTime,Duration,NumberOfEntries);
        end
        function struct = TotalDurationSummary(obj,DATASET)
            %%
            ThresholdTime = '16:00:00';            
            %%
            StartTimes = obj.GetColumn(DATASET,'StartTime');
            n = find(not(strcmpi(StartTimes,'N/A')));
            StartTimes = StartTimes(n);
            
            %%
            StartTimes = datenum(StartTimes);
            DateNum = datenum(ThresholdTime);
            n = find(StartTimes>DateNum);
            StartTimes = StartTimes(n);
            OverallStartTime = min(StartTimes);
            
            EndTimes = obj.GetColumn(DATASET,'EndTime');
            n = find(not(strcmpi(EndTimes,'N/A')));
            EndTimes = datenum(EndTimes(n))
            
            %%
            DateNum = datenum(ThresholdTime);
            n = find(EndTimes>DateNum);
            EndTimes = EndTimes(n);
            OverallEndTime = max(EndTimes);
            
            TimeAfterMidNight = rem(OverallEndTime,1);
            TimeBeforeMidNight = 1 - rem(OverallStartTime,1);
            Duration = TimeAfterMidNight + TimeBeforeMidNight;
            
            struct.OverallStartTime = datestr(OverallStartTime,'HH:MM:SS');
            struct.OverallEndTime = datestr(OverallEndTime,'HH:MM:SS');
            struct.Duration = datestr(Duration,'HH:MM:SS');
        end
    end
    methods %Data convert for report
        function [Table] = ProgramStruct2Table(obj,Struct)
            %%
            count = 1;
            ProgramNames = fieldnames(Struct);
            for i = 1:max(size(ProgramNames))
                
                ProgramName = ProgramNames{i};
                Macros = Struct.(ProgramName);
                
                MacroNames = fieldnames(Macros);
                for j = 1:max(size(MacroNames))
                    MacroName = MacroNames{j};
                    struct = Struct.(ProgramName).(MacroName); 
                    
                    Table{count,1} = ProgramName;
                    Table{count,2} = MacroName;
                    Table{count,3} = struct.Type;
                    Table{count,4} = struct.Frequency;
                    Table{count,5} = struct.Enable;
                    count = count+ 1;
                end
            end
            Table = [{'Program','Macro','Type','Freq','Enable'};Table];
        end
    end
    methods (Hidden = true)
        function [Status,error] = Get(obj,ProgramName,ResultName,Type,Frequency,FolderType)
            %%
            [DateNum, error] = obj.GetResultDateNums(ProgramName,ResultName,FolderType);
            if error == 0;
                switch Type
                    case 'WeekDaysOnly'
                        if Frequency == 1
                            Status = obj.GetStatsOnDateNums(DateNum,Frequency);
                        else
                            Status = [];
                            error = -1;
                            disp('Analysis on mulitiple times a day updates is not supported')
                            return
                        end
                    case 'Weekly'
                        Status = obj.GetStatsOnDateNumsWeekly(DateNum,Frequency);
                    otherwise
                end
                error = 0;
            else
                StartDateNum = NaN;
                EndDateNum = NaN;
                Duration = NaN;
                NumberOfSuccessfulEvents = NaN;
                RequiredNumberOfEvents = NaN;
                Reliabilty = NaN;
                NumberOfDaysSinceLastUpdate = NaN;
                Error = {'Folder Not Found'};
                Status = dataset({Error,'Error'},StartDateNum,EndDateNum,Duration,NumberOfSuccessfulEvents,RequiredNumberOfEvents,Reliabilty,NumberOfDaysSinceLastUpdate); 
            end  
        end
        function Struct = BuildProgramMacroArray(obj,DataPath)
            %This function creates a struct descibing the program/macros in the reliabilty study. 
            
            % obj.DataPath - Will define the path of the reliabity check.
            
            % Get a list of program names from the location.
            [FileNames,error] = obj.GetFileNames(DataPath);
            
            % Remove programs with that don't have a results folder.
            ProgramNames = obj.RemoveProgWithoutFolderName(FileNames,'Results');

            x = size(ProgramNames,1);
            for i = 1:x
                ProgramName2 = ProgramNames{i};
                [FileNames2,error] = obj.GetFileNames([DataPath,'\',ProgramName2,'\Results\']);
                ProgramName = strrep(ProgramName2,' ','');
                y = size(FileNames2,1);
                for j = 1:y
                    try
                    Struct.(ProgramName).(FileNames2{j}).FolderName = ProgramName2;
                    Struct.(ProgramName).(FileNames2{j}).Type = 'WeekDaysOnly';
                    Struct.(ProgramName).(FileNames2{j}).Frequency = 1;
                    Struct.(ProgramName).(FileNames2{j}).Enable = 'TRUE';
                    end
                end
            end         
        end
        function Status = EvaluateTheArray(obj,Struct,FolderType)
            %%
            ProgramNames = fieldnames(Struct);
            x = size(ProgramNames,1);
            h = waitbar(0);
            for i = 1:x
                MacroNames = fieldnames(Struct.(ProgramNames{i}));
                y = size(MacroNames,1);
                ProgramName = ProgramNames{i};
                for j = 1:y
                    waitbar(j/y,h)
                    MacroName = MacroNames{j};
                    ProgramFolderName = Struct.(ProgramNames{i}).(MacroNames{j}).FolderName;
                    Frequency = Struct.(ProgramNames{i}).(MacroNames{j}).Frequency;
                    Type = Struct.(ProgramNames{i}).(MacroNames{j}).Type;
                    Enable = Struct.(ProgramNames{i}).(MacroNames{j}).Enable;
                    
                    if strcmpi(Enable,'TRUE')
                        [NewStatus,error] = obj.Get(ProgramFolderName,MacroName,Type,Frequency,FolderType);
                        if error == 0
                            NewStatus = [dataset({{ProgramName},'ProgramName'},{{MacroName},'ResultName'},{{Type},'Type'},Frequency),NewStatus];
                            if and(i == 1,j == 1)
                            Status = NewStatus; 
                            else
                            Status = [Status;NewStatus];  
                            end
                        end
                    end
                end
            end           
        end
        function PlotBarGraph(obj,Status)
            %%
            ProgramName = obj.GetColumn(Status,'ProgramName');
            ResultName = obj.GetColumn(Status,'ResultName');
            Reliabilty = obj.GetColumn(Status,'Reliabilty');
            UpToDate = obj.GetColumn(Status,'UpToDate');
            n1 = find(UpToDate == 0);
            n2 = find(not(UpToDate == 0));
            
            n = find(isnan(Reliabilty)==1);
            Reliabilty(n) = 0;
            
            x = size(ProgramName,1);
            for i = 1:x
                Name = [ProgramName{i},'_',ResultName{i}];
                Names{i} = Name;
            end
            
            Rel1(n1) = Reliabilty(n1);
            Rel1(n2) = 0;
            h = barh(Rel1*100);
            set(h,'FaceColor','r');
            
            hold on
            Rel2(n2) = Reliabilty(n2);
            Rel2(n1) = 0;
            h = barh(Rel2*100);
            set(h,'FaceColor','g');
            
            legend({'Not Updating','Updating'})         
            
            
            ylabel('Macro Name')
            xlabel('Reliabilty (%)')
            set(gca,    'YTickLabel', Names, ...
                        'YTick', [1:x]);
            
            %% overall reliabilty
            TotalReliabilty = sum(Reliabilty);
            TotalReliabilty = TotalReliabilty/x;
            title(['Total Reliabilty: ',num2str(TotalReliabilty*100),'%'])
            set(gcf,    'Position', [181         145        1005         779], ...
                        'Name', 'Reliabilty Overview', ...
                        'NumberTitle','off');   
%             obj.ColourMap(h,x,50,Reliabilty);
        end
    end
    methods (Hidden = true) %Add columns
        function DataSet = UpToDate(obj,DataSet,datenum)
            DaysOld = today - datenum;
            NumberOfDaysSinceLastUpdate = obj.GetColumn(DataSet,'NumberOfDaysSinceLastUpdate');
            Type = obj.GetColumn(DataSet,'Type');
            x = size(NumberOfDaysSinceLastUpdate,1);
            for i = 1:x
                NumOfDaysSinceLastUpdate = NumberOfDaysSinceLastUpdate(i);
                switch Type{i}
                    case 'Weekly'
                        if NumOfDaysSinceLastUpdate <= 7 + DaysOld
                            UpToDate(i,1) = true;
                        else
                            UpToDate(i,1) = false;
                        end
                    case 'WeekDaysOnly'
                        if NumOfDaysSinceLastUpdate < 1 + DaysOld
                            UpToDate(i,1) = true;
                        else
                            UpToDate(i,1) = false;
                        end
                    otherwise
                        error('Type not recognised')
                end
            end
            DataSet = [DataSet,dataset(UpToDate)];
        end
        function DataSet = StartEndDateStr(obj,Status)
            %%
            StartDateNum = obj.GetColumn(Status,'StartDateNum');
            for i = 1:max(size(StartDateNum))
                StartDate{i,1} = datestr(StartDateNum(i),'dd-mmm-yyyy');
            end
            EndDateNum = obj.GetColumn(Status,'EndDateNum');
            for i = 1:max(size(EndDateNum))
                EndDate{i,1} = datestr(EndDateNum(i),'dd-mmm-yyyy');
            end
            DataSet = [Status,dataset(StartDate,EndDate)];
        end
    end
    methods (Hidden = true)
        function ColourMap(obj,h,x,num,Reliabilty)

            ch = get(h,'Children');
            fvd = get(ch,'Faces');
            fvcd = get(ch,'FaceVertexCData');

            [zs, izs] = sortrows(Reliabilty,1);

            for i = 1:x
                row = izs(i);
                fvcd(fvd(row,:)) = i;
            end
            set(ch,'FaceVertexCData',fvcd)
            clear map
            step = 1/num;
            for i = 0:num
                map(i+1,1) = 1 - step*i;
                map(i+1,2) = step*i;
                map(i+1,3) = 0;
            end
            colormap(map);           
        end
        function ProgramNames = RemoveProgWithoutFolderName(obj,FileNames,FolderName)
            %Remove program names without a Results folder. 
            x = size(FileNames,1);
            n1 = [];
            n2 = [];
            for i = 1:x
                ProgramName = FileNames{i};
                [FileNames2,error] = obj.GetFileNames([obj.ResultsDir,'\',ProgramName]);
                n = find(strcmpi(FileNames2,FolderName));
                if not(isempty(n))
                   n1 = [n1,i]; 
                else
                   n2 = [n2,i]; 
                end
            end
%             disp(['The following programs have been removed because they have no ',FolderName,' folders:'])
%             disp(FileNames(n2));    
            ProgramNames = FileNames(n1);
        end
        function Status = GetStatsOnDateNums(obj,DateNum,Frequency)
            if isempty(DateNum)
                StartDateNum = NaN;
                EndDateNum = NaN;
                Duration = NaN;
                NumberOfSuccessfulEvents = NaN;
                RequiredNumberOfEvents = NaN;
                Reliabilty = NaN;
                NumberOfDaysSinceLastUpdate = NaN;
                Status = dataset({'DateNumEmpty','Error'},StartDateNum,EndDateNum,Duration,NumberOfSuccessfulEvents,RequiredNumberOfEvents,Reliabilty,NumberOfDaysSinceLastUpdate);
                return
            end
            if iscell(DateNum)
                try
                    DateNum = cell2double(DateNum);
                catch
                    x = 1; 
                end
            end
            StartDateNum = min(DateNum);
            EndDateNum = max(DateNum);
            Duration = EndDateNum-StartDateNum+1;
            
            DateRange(1) = StartDateNum;
            DateRange(2) = EndDateNum;
            NumberOfSuccessfulEvents = size(DateNum,1);
            RequiredNumberOfEvents = obj.RequiredNumberOfDays(DateRange);
            Reliabilty = NumberOfSuccessfulEvents/RequiredNumberOfEvents;
            
            if obj.log == true
                disp(['First Date: ',datestr(StartDateNum)])
                disp(['Last Date: ',datestr(EndDateNum)])
                disp(['Duration in days: ',num2str(Duration)])
                disp(['NumberOfSuccessfulEvents: ',num2str(NumberOfSuccessfulEvents)])
                disp(['Required Number Days Events: ',num2str(RequiredNumberOfEvents)])
                disp(['Reliabilty: ',num2str(Reliabilty*100),'%'])  
            end
            Error = {'False'};
            
            %% NumberOfDaysSinceLastUpdate
            NumberOfDaysSinceLastUpdate = today - EndDateNum;
            
            %%
            Status = dataset({Error,'Error'},StartDateNum,EndDateNum,Duration,NumberOfSuccessfulEvents,RequiredNumberOfEvents,Reliabilty,NumberOfDaysSinceLastUpdate);            
        end
        function Status = GetStatsOnDateNumsWeekly(obj,DateNum,Frequency)
            if isempty(DateNum)
                StartDateNum = NaN;
                EndDateNum = NaN;
                Duration = NaN;
                NumberOfSuccessfulEvents = NaN;
                RequiredNumberOfEvents = NaN;
                Reliabilty = NaN;
                NumberOfDaysSinceLastUpdate = NaN;
                Status = dataset({'DateNumEmpty','Error'},StartDateNum,EndDateNum,Duration,NumberOfSuccessfulEvents,RequiredNumberOfEvents,Reliabilty,NumberOfDaysSinceLastUpdate);
                return
            end
            StartDateNum = min(DateNum);
            EndDateNum = max(DateNum);
            Duration = EndDateNum-StartDateNum+1;
            
            DateRange(1) = StartDateNum;
            DateRange(2) = EndDateNum;
            NumberOfSuccessfulEvents = size(DateNum,1);
            RequiredNumberOfEvents = floor(Duration/7);
            Reliabilty = NumberOfSuccessfulEvents/RequiredNumberOfEvents;
            
            if obj.log == true
                disp(['First Date: ',datestr(StartDateNum)])
                disp(['Last Date: ',datestr(EndDateNum)])
                disp(['Duration in days: ',num2str(Duration)])
                disp(['NumberOfSuccessfulEvents: ',num2str(NumberOfSuccessfulEvents)])
                disp(['Required Number Days Events: ',num2str(RequiredNumberOfEvents)])
                disp(['Reliabilty: ',num2str(Reliabilty*100),'%'])  
            end
            
            Error = {'False'};
            
            %% NumberOfDaysSinceLastUpdate
            NumberOfDaysSinceLastUpdate = today - EndDateNum;
            
            %%
            Status = dataset({Error,'Error'},StartDateNum,EndDateNum,Duration,NumberOfSuccessfulEvents,RequiredNumberOfEvents,Reliabilty,NumberOfDaysSinceLastUpdate);            
        end
        function countwd = RequiredNumberOfDays(obj,DateRange)
            countwd = 0;
            for i = DateRange(1):DateRange(2)
                switch datestr(i,8)
                    case {'Mon','Tue','Wed','Thu','Fri'}
                        countwd = countwd + 1;
                    case {'Sat','Sun'}
                    otherwise
                        error('Day not recognised')
                end
            end
        end
        function DateNum = LastWeekDay(obj,DateNum)
            %%
            Day = datestr(DateNum,'DDD');
            switch lower(Day)
                case 'sun'
                    DateNum = DateNum - 2;
                case 'sat'
                    DateNum = DateNum - 1;
            end
        end
    end
end

