classdef Schedular <    handle & ...
                        MacroRun & ...
                        TaskMonitor & ...
                        DataSetFiltering
    properties
        job
        timers
        CompiledProgramDir = 'Y:\';
        RunOnInt = 'on';
        InstallDir = 'C:\SourceSafe\Stocks & Shares\Programs\Schedular\';
        ProgramName = 'Schedular';
        StockData = 'P:\StockData [MEDIAPC]\';
    end
    methods
        function obj = Schedular(varargin)
%             try
                [x] = size(varargin,2);
                for i = 1:2:x
                    obj.(varargin{i}) = varargin{i+1};
                end
                
                PWD = pwd;
                try 
                    cd('P:\StockData [MEDIAPC]\StockData [MEDIAPC]\')
                    obj.StockData = 'P:\StockData [MEDIAPC]\StockData [MEDIAPC]\';
                    obj.MacroLogDir = 'P:\StockData [MEDIAPC]\StockData [MEDIAPC]\';
                catch
                    obj.StockData = 'P:\StockData [MEDIAPC]\';
                    obj.MacroLogDir = 'P:\StockData [MEDIAPC]\';
                end
                disp(['ResultsDir: ',obj.StockData])
                cd(PWD)

                %% X:\Schedular\MacroLog\URL_Download_New\
                logname = [obj.StockData,'Schedular\MacroLog\URL_Download_New\log',strrep(datestr(now),':','_'),'.txt'];
                obj.InstallDir = [pwd,'\'];
                if strcmpi(obj.RunOnInt,'on')
                    try
                        diary(logname)
                    catch
                        logname
                        disp('Could not create log file')
                    end
                    Plan = obj.LoadPlanner('Planner');
                    N_DATASET = obj.Planner2DataSet(Plan)
                    NumberOfPasses = 3;
                    disp('Planner loaded sucessfully')
                    obj.Run(N_DATASET,NumberOfPasses);
                    
                    diary off
                end
                cd(obj.InstallDir)
%             catch
%                 uiwait(msgbox('Error occured')) 
%             end
        end
        function Run(obj,DATASET,NumberOfPasses)
            NextAgentID = obj.CheckHung;
            
            date = today;
            date = obj.GetStoreDate(date);  
            Name = getComputerName;
            disp(['ComputerName: ',Name])
            DATASET = obj.ColumnStr(DATASET,'PC_Name',Name);
            if isempty(DATASET), error('No tasks for this computer'), end %Check that task are required for this PC.

            %%
            struct = obj.GetStatusStruct(DATASET,date,Name); %Load if file exist, create if not found and save.
            [ProgramName,MacroName] = obj.GetNextAction(struct);
            struct.(ProgramName).(MacroName).Started = true;
            struct.(ProgramName).(MacroName).TimeOfLastPulse = now;
            struct.(ProgramName).(MacroName).StartTime = datestr(now,'HH:MM:SS');

            o_struct.detial = struct;
            obj.SaveStatus(o_struct,date,Name);
            
            %%
            for i = 1:NumberOfPasses
                obj.RunProgram(ProgramName,MacroName,NextAgentID);
            end

            %% Load struct modify to be complete then save. 
            [struct, Error] = obj.LoadStatus(date,Name);
            struct = struct.detial; 

            struct.(ProgramName).(MacroName).Started = false;
            struct.(ProgramName).(MacroName).Complete = true;
            struct.(ProgramName).(MacroName).TimeOfLastPulse = now;
            struct.(ProgramName).(MacroName).EndTime = datestr(now,'HH:MM:SS');
            struct.(ProgramName).(MacroName).Progress = 1;

            o_struct.detial = struct;
            obj.SaveStatus(o_struct,date,Name);            
        end
        function NextAgentID = CheckHung(obj)
            %%
            NumberOfScedulars = [1:6];
            Name = getComputerName;
%             Name = 'mt';
            [DATASET] = obj.GetPcsTasks(Name);
            [DATASET] = obj.NumRange(DATASET,'Complete',[-0.5,0.5]); %Complete FALSE
            x = size(DATASET,1);
            disp(['Removing completed. Number of task left: ',num2str(x)])
            [DATASET] = obj.NumRange(DATASET,'Started',[0.5,1.5]); %Started TRUE
            x = size(DATASET,1);
            disp(['Filter on complete. Number of task left: ',num2str(x)])
            if x == 0
                NextAgentID = 1;
               return 
            end
            
            [DATASET] = obj.ColumnStr(DATASET,'Program','URL_Download'); %Started TRUE
            [N_DATASET] = obj.AddTimeSinceLastPulse(DATASET);
            
            %% Keep only started
            StaleThreshold = '00:10:00';        
            P_DATASET = obj.FindStale(N_DATASET,StaleThreshold);    
            obj.KillStale(P_DATASET);
            
            %% Get ID for next event
            AgentName = obj.GetColumn(N_DATASET,'AgentName');
            AgentNumStr = strrep(AgentName,'Agent','');
            AgentNum = str2num(cell2mat(AgentNumStr));
            
            for i = 1:size(AgentNum,1)
                n = find(not(AgentNum(i) == NumberOfScedulars));
                NumberOfScedulars = NumberOfScedulars(n);
            end
            NextAgentID = NumberOfScedulars(1);
        end
    end
    methods
        function Macro = LoadPlanner(obj,Name)
            disp(['Load planner: ',obj.InstallDir,'Macros\',Name,'.m'])
            [DATASET,Error] = obj.ExecuteMacro([obj.InstallDir,'Macros\',Name,'.m']);
            Macro = DATASET;
        end
        function N_DATASET = Planner2DataSet(obj,Plan)
            %%
            NumberOfFields = size(DATASET.table,2)
            FieldNames = DATASET.FieldNames
            for i = 1:NumberOfFields
                FieldName = FieldNames{i}
                columndata = DATASET.table(:,i)
                column = dataset({columndata,FieldName})
                if i == 1
                    N_DATASET = column;
                else
                    DATASET = [N_DATASET,column];
                end
            end
        end
        function KillStatus = CheckKillAll(obj,KillTime,KillStatus)
            %%
            DateTime = datestr(now,'HH:MM:SS')
            if datenum(KillTime) < datenum(DateTime)
                After = true;
            else
                After = false;
            end
            %%
            KillStatus
            if and(KillStatus == false,After == true)
                obj.KillProgram('Schedular');
                KillStatus = true;
            end
        end
        function KillProgram(obj,Program)
            String = ['taskkill /IM ',Program,'.exe'];
            disp(String)
            dos(String)
        end
        function CreatejobSummaryTimer(obj,UpdateRate)
            %%
            tobj = timer(   'Period',           UpdateRate, ...
                            'ExecutionMode',    'fixedDelay');
            tobj.TimerFcn = @obj.jobSummary;
            
            %%
            start(tobj)     
        end
        function DATASET = jobSummary(varargin)
            %%
            obj = varargin{1};
            try
                MacrosRunning = fieldnames(obj.job.URL_Download);
                x = size(MacrosRunning,1);
                for i = 1:x
                    handle = obj.job.URL_Download.(MacrosRunning{i});
                    State{i,1} = get(handle,'State');
                    StartTime{i,1} = get(handle,'StartTime');
                end
                %
                DATASET = dataset(MacrosRunning,State,StartTime);
                save('jobSummary.mat','DATASET')
            catch
               DATASET = []; 
            end
        end
        function CreateAllTimers(obj,Macros)
            %%
            x = size(Macros,1);
            for i = 1:x
                obj.CreateTimerObject(Macros{i,1},Macros{i,2},Macros{i,3});
            end                        
        end
        function KillAllJobs(obj,Macros)
            x = size(Macros,1);
            for i = 1:x
                try
                obj.KillJob(obj.job.(Macros{i,1}).(Macros{i,2}));
                end
            end            
        end
        function KillJob(obj,job)
            %%
            destroy(job);
        end
        function job = RunProgram(obj,ProgamName,MacroName,AgentNum)
            disp(['Running: ',ProgamName,'-',MacroName])
            PWD = pwd;
            Path = [obj.CompiledProgramDir,ProgamName,'\']
            String1 = [ProgamName,'_Agent',num2str(AgentNum),'.exe "Macro" "',MacroName,'" "AgentName" "Agent',num2str(AgentNum),'"']
            cd(Path)
            dos(String1);
%             String2 = ['dos(''',String1,''')'];
%             job = batch(String2);
            cd(PWD)
            job = 1;
        end
        function CreateTimerObject(obj,ProgamName,MacroName,Time)
            %%
            tobj = timer();
            DateNum = datenum(Time) - now;
            
            HH = str2num(datestr(DateNum,'HH'));
            MM = str2num(datestr(DateNum,'MM'));
            SS = str2num(datestr(DateNum,'SS'));
            
            Delay = HH*60*60 + MM*60 + SS;
            
            tobj.ExecutionMode = 'singleShot';
            tobj.StartDelay = Delay;
            tobj.TimerFcn = {@obj.StartFcn,ProgamName,MacroName};
            
            start(tobj)
            
            obj.timers.(ProgamName).(MacroName) = tobj;
        end
        function StartFcn(varargin)
            obj = varargin{1};
            ProgamName = varargin{4};
            MacroName = varargin{5};
            disp(['Starting macro: ',ProgamName,'-',MacroName])
            obj.job.(ProgamName).(MacroName) = obj.RunMaro(ProgamName,MacroName);
        end
        function DATASET = FilterPCTaskOnly(obj,DATASET,name)
            %%
            [DATASET] = obj.ColumnStr(DATASET,'PC_Name',name)
        end
        function [struct, Error] = LoadStatus(obj,date,Name)
            %%
            filename = [obj.InstallDir,'Track\',Name,'_',strrep(datestr(date),'-','_'),'.mat'];
            filename = [obj.StockData,'Schedular\Track\',Name,'_',strrep(datestr(date),'-','_'),'.mat'];
            try
                disp(['Load Path: ',filename])
                load(filename)
                Error = 0;
            catch
                struct = [];
                Error = -1;                
            end
        end
        function SaveStatus(obj,struct,date,Name)
            %%
           filename = [obj.InstallDir,'Track\',Name,'_',strrep(datestr(date),'-','_'),'.mat'];
           filename = [obj.StockData,'Schedular\Track\',Name,'_',strrep(datestr(date),'-','_'),'.mat'];
           save(filename)
        end
        function struct  = BuildStruct(obj,Macros)
            %%
            x = size(Macros,1);
            for i = 1:x
                PCName = Macros{i,1};
                ProgramName = Macros{i,2};
                MacroName = Macros{i,3};
                struct.(ProgramName).(MacroName).Time =  Macros{i,4};
                struct.(ProgramName).(MacroName).Type =  Macros{i,5};
                struct.(ProgramName).(MacroName).Started = false;
                struct.(ProgramName).(MacroName).Progress = 0;
                struct.(ProgramName).(MacroName).Complete = false;
                struct.(ProgramName).(MacroName).TimeOfLastPulse = 'N/A';
                struct.(ProgramName).(MacroName).StartTime = 'N/A';
                struct.(ProgramName).(MacroName).EndTime = 'N/A';
                struct.(ProgramName).(MacroName).AgentName = [];
            end
        end
        function date = GetStoreDate(obj,date)
            Threshold = '08:00:00';
            if date == today %if today then find time.
                time = now;
                time = rem(time,1);
                ThresholdDateNum = rem(datenum(Threshold),1);
                if time < ThresholdDateNum;
                    date = date - 1;
                end
            end            
        end
        function [struct]  = GetStatusStruct(obj,Macros,date,Name)   
            %%
            [struct, Error] = obj.LoadStatus(date,Name);
            if Error == -1
                disp('Load Track: FAIL (May be first attempt today)')
            else
                disp('Load Track: PASS')
            end
            
            %%
            if Error == -1
                struct  = obj.BuildStruct(Macros);
                o_struct.detial = struct;
                obj.SaveStatus(o_struct,date,Name);
            else
                struct = struct.detial;    
            end
        end
        function [ProgramName,MacroName] = GetNextAction(obj,struct)
            struct = obj.RemoveCompleted(struct);
            struct = obj.RemoveStarted(struct);
            struct = obj.RemoveNotScheduled(struct);
            struct = obj.GetFirstEntry(struct);
            [ProgramName,MacroName] = obj.GetDetails(struct);
        end
        function structout = RemoveCompleted(obj,struct)
            %%
            ProgramNames = fieldnames(struct)
            for i = 1:max(size(ProgramNames))
                MacroNames = fieldnames(struct.(ProgramNames{i}))
                for j = 1:max(size(MacroNames))
                    val = struct.(ProgramNames{i}).(MacroNames{j});
                    if val.Complete == false
                        structout.(ProgramNames{i}).(MacroNames{j}) = struct.(ProgramNames{i}).(MacroNames{j});
                    end
                end
            end
            if not(exist('structout'))
                disp('All task are complete. Program will be terminated')
                error('Program terminated')
            end
        end
        function structout = RemoveStarted(obj,struct)
            %%
            ProgramNames = fieldnames(struct);
            for i = 1:max(size(ProgramNames))
                MacroNames = fieldnames(struct.(ProgramNames{i}))
                for j = 1:max(size(MacroNames))
                    val = struct.(ProgramNames{i}).(MacroNames{j})
                    if val.Started == false
                        structout.(ProgramNames{i}).(MacroNames{j}) = struct.(ProgramNames{i}).(MacroNames{j});
                    end
                end
            end
        end
        function structout = RemoveNotScheduled(obj,struct)
            %%
            ProgramNames = fieldnames(struct)
            TimeNow = datenum(datestr(now,'HH:MM:SS'))
            for i = 1:max(size(ProgramNames))
                MacroNames = fieldnames(struct.(ProgramNames{i}))
                for j = 1:max(size(MacroNames))
                    val = struct.(ProgramNames{i}).(MacroNames{j});
                    val.Time
                    Time = datenum(val.Time);
                    TimeDiff = Time - TimeNow;
                    if TimeDiff < 0
                    	 structout.(ProgramNames{i}).(MacroNames{j}) = struct.(ProgramNames{i}).(MacroNames{j});
                    end
                end
            end            
        end
        function structout = GetFirstEntry(obj,struct)
            %%
            ProgramName = fieldnames(struct);
            MacroName = fieldnames(struct.(ProgramName{1}));
            structout.(ProgramName{1}).(MacroName{1}) = struct.(ProgramName{1}).(MacroName{1});
        end
        function [ProgramName,MacroName] = GetDetails(obj,struct)
            temp = fieldnames(struct);
            ProgramName = temp{1};
            temp = fieldnames(struct.(ProgramName));   
            MacroName = temp{1};
        end
    end
    methods
        function [] = Duration(obj)
            %%
            ProgramName = 'SharePrice';
            MarcoName = 'Summary';
            Type = 'URL';
            Date = today - 2
            [Start,End,Duration] = obj.TimeStartEnd(ProgramName,MarcoName,Type,Date);
            datestr(Duration,'HH:MM:SS')

            %%
            ProgramName = 'ADVFN';
            MarcoName = 'Finacials';
            [Start,End,Duration] = obj.TimeStartEnd(ProgramName,MarcoName,Type,Date);
            datestr(Duration,'HH:MM:SS')  
            
            %%
            ProgramName = 'DigitalLook';
            MarcoName = 'Symbol2Num';
            [Start,End,Duration] = obj.TimeStartEnd(ProgramName,MarcoName,Type,Date);
            datestr(Duration,'HH:MM:SS') 

            %%
            ProgramName = 'Stox';
            MarcoName = 'Best_Investments';
            Date = today - 3
            [Start,End,Duration] = obj.TimeStartEnd(ProgramName,MarcoName,Type,Date);
            datestr(Duration,'HH:MM:SS') 
            
        end
        function [Start,End, Duration] = TimeStartEnd(obj,ProgramName,MarcoName,Type,Date)
            %% X:\SharePrice\Results\Summary\URL
            path = [obj.StockData,ProgramName,'\Results\',MarcoName,'\',Type,'\',strrep(datestr(Date),'-','_'),'\']       
            PWD = pwd
            cd(path)
            directory = dir
            directory(1)
            times = squeeze(struct2cell(directory));
            DateNum = cell2mat(times(5,3:end));
            Start = min(DateNum);
            End = max(DateNum);
            Duration = End - Start;
            cd(PWD)
        end
    end
end