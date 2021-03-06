classdef Schedular <    handle & ...
                        MacroRun & ...
                        DataSetFiltering & ...
                        StructureManagement & ...
                        mindowsSchedular
    properties
        job
        timers
        RunOnInt = 'on';
        InstallDir = 'C:\SourceSafe\Stocks & Shares\Programs\Schedular\';
        ProgramName = 'Schedular';
        StockData = 'P:\StockData [MEDIAPC]\';
        ENABLE = false
    end
    methods
        function Example(obj)
            %%
            close all
            clear classes
            
            %%
            obj.Schedular
        end
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
                    N_DATASET = obj.Planner2DataSet(Plan);
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
        function Run(obj,N_DATASET,NumberOfPasses)
            %%


            DATASET = obj.ColumnStr(N_DATASET,'PC_Name',Name);
            if isempty(DATASET), error('No tasks for this computer'), end %Check that task are required for this PC.

            %%
            struct = obj.GetStatusStruct(DATASET,date,Name); %Load if file exist, create if not found and save.
%             struct = struct.detial;
            [DATASET] = obj.struct2DATASET(struct);
            NextAgentID = obj.CheckHung(DATASET); %On this PC only
            
            %%
            [ProgramName,MacroName] = obj.GetNextAction(struct);
            
            if obj.ENABLE == true
                obj.RunAndTrackProgram(ProgramName,MacroName,NumberOfPasses,NextAgentID);
            end
        end
    end
    methods
        function N_DATASET = Planner2DataSet(obj,DATASET)
            %%
            NumberOfFields = size(DATASET.table,2);
            FieldNames = DATASET.FieldNames;
            for i = 1:NumberOfFields
                FieldName = FieldNames{i};
                columndata = DATASET.table(:,i);
                column = dataset({columndata,FieldName});
                if i == 1
                    N_DATASET = column;
                else
                    N_DATASET = [N_DATASET,column];
                end
            end
        end
        function Macro = LoadPlanner(obj,Name)
            disp(['Load planner: ',obj.InstallDir,'Macros\',Name,'.m'])
            [DATASET,Error] = obj.ExecuteMacro([obj.InstallDir,'Macros\',Name,'.m']);
            Macro = DATASET;
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
        function struct  = BuildStruct(obj,N_DATASET)
            %%
            PC_Name = obj.GetColumn(N_DATASET,'PC_Name');
            ProgramNames = obj.GetColumn(N_DATASET,'ProgramName');
            MacroNames = obj.GetColumn(N_DATASET,'MacroName');
            StartTime = obj.GetColumn(N_DATASET,'StartTime');
            Types = obj.GetColumn(N_DATASET,'Type');
            %%
            x = size(N_DATASET,1);
            for i = 1:x
                PCName = PC_Name{i};
                ProgramName = ProgramNames{i};
                MacroName = MacroNames{i};
                struct.(ProgramName).(MacroName).Time =  StartTime{i};
                struct.(ProgramName).(MacroName).Type =  Types{i};
                struct.(ProgramName).(MacroName).Started = false;
                struct.(ProgramName).(MacroName).Progress = 0;
                struct.(ProgramName).(MacroName).Complete = false;
                struct.(ProgramName).(MacroName).TimeOfLastPulse = 'N/A';
                struct.(ProgramName).(MacroName).StartTime = 'N/A';
                struct.(ProgramName).(MacroName).EndTime = 'N/A';
                struct.(ProgramName).(MacroName).AgentName = [];
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
    end
    methods %Filter Tasks to get next action
        function [ProgramName,MacroName] = GetNextAction(obj,struct)
            %%
            
            struct2 = obj.RemoveCompleted(struct);
            
            %%
            struct3 = obj.RemoveStarted(struct2);
            
            %%
            struct4 = obj.RemoveNotScheduled(struct3);
            
            %%
            struct5 = obj.GetFirstEntry(struct4);
            
            %%
            [ProgramName,MacroName] = obj.GetDetails(struct5);
        end
        function structout = RemoveNotScheduled(obj,struct)
            %%
            ProgramNames = fieldnames(struct);
            TimeNow = datenum(datestr(now,'HH:MM:SS'));
            for i = 1:max(size(ProgramNames))
                MacroNames = fieldnames(struct.(ProgramNames{i}));
                for j = 1:max(size(MacroNames))
                    val = struct.(ProgramNames{i}).(MacroNames{j});
                    try
                        Time = datenum(val.Time);
                        TimeDiff = Time - TimeNow;
                        if TimeDiff < 0
                             structout.(ProgramNames{i}).(MacroNames{j}) = struct.(ProgramNames{i}).(MacroNames{j});
                        end
                    catch
                        if strcmpi(val.Time,'Queued')
                            structout.(ProgramNames{i}).(MacroNames{j}) = struct.(ProgramNames{i}).(MacroNames{j});
                        else
                           error('') 
                        end
                    end
                end
            end            
        end       
        function structout = RemoveCompleted(obj,struct)
            %%
            ProgramNames = fieldnames(struct);
            for i = 1:max(size(ProgramNames))
                MacroNames = fieldnames(struct.(ProgramNames{i}));
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
                MacroNames = fieldnames(struct.(ProgramNames{i}));
                for j = 1:max(size(MacroNames))
                    val = struct.(ProgramNames{i}).(MacroNames{j});
                    if val.Started == false
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