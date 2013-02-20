classdef mindowsSchedular < handle 
    % this class is intended to control
    %   - Run a task in windows schedular
    %   - Ensure we control all the task and monitor the tasks.
    properties (SetObservable = true)
        CompiledProgramDir = 'Y:\';
        ComputerName
        TaskController
        LastTradingDate
        LastTradingDateNum
        SharedDir = 'Y:\Schedular\'; % shared between PCs to track tasks.
    end
    properties (Hidden = true)
        handles
    end
    methods
        function Example(obj)
           %%
            close all
            clear classes
            
            %%
            obj = mindowsSchedular;
            ObjectInspector(obj)
        end
        function RunAndTrackProgram(obj,ProgramName,MacroName,NumberOfPasses,NextAgentID)

            Name = getComputerName;
            disp(['ComputerName: ',Name])
            
            [struct, Error] = obj.LoadStatus(date,Name);
            struct = struct.detial;
            struct.(ProgramName).(MacroName).Started = true;
            struct.(ProgramName).(MacroName).TimeOfLastPulse = now;
            struct.(ProgramName).(MacroName).StartTime = datestr(now,'HH:MM:SS');
            o_struct.detial = struct;
            obj.SaveStatus(o_struct,date,Name);

            %%
            for i = 1:NumberOfPasses
                obj.RunProgram(ProgramName,MacroName,NextAgentID);
            end

            %% Double check everything is closed
            programName = ['URL_Download_Agent',num2str(NextAgentID)];
            obj.KillProgram(programName);
            pause(30)
            obj.KillProgram(programName);

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
        function NextAgentID = CheckHung(obj,DATASET)
            %%
            NumberOfScedulars = [1:6];
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
            
            %%
            obj.KillStale(P_DATASET);
            
            %% Get ID for next event
            try
                AgentName = obj.GetColumn(N_DATASET,'AgentName');
                AgentNumStr = strrep(AgentName,'Agent','');
                AgentNum = str2num(cell2mat(AgentNumStr));
                for i = 1:size(AgentNum,1)
                    n = find(not(AgentNum(i) == NumberOfScedulars));
                    NumberOfScedulars = NumberOfScedulars(n);
                end
                NextAgentID = NumberOfScedulars(1);
            catch
                NextAgentID = 1;
            end
        end
        function [N_DATASET] = AddTimeSinceLastPulse(obj,DATASET)
            %% Time since last update
            TimeOfLastPulse = obj.GetColumn(DATASET,'TimeOfLastPulse');
            TimeSinceLastPulse = now - TimeOfLastPulse;
            
            Str = datestr(TimeOfLastPulse,'HH:MM:SS');
            for i = 1:size(Str,1)
                TimeOfLastPulseStr{i,1} = Str(i,:);
            end
            
            Str = datestr(TimeSinceLastPulse,'HH:MM:SS');
            for i = 1:size(Str,1)
                TimeSinceLastPulseStr{i,1} = Str(i,:);
            end
            
            N_DATASET = [DATASET,dataset(TimeOfLastPulseStr,TimeSinceLastPulse,TimeSinceLastPulseStr)];
        end
        function P_DATASET = FindStale(obj,N_DATASET,StaleThreshold)
            %%
            StaleThresholdNum = rem(datenum(StaleThreshold),1);
            P_DATASET = obj.NumRange(N_DATASET,'TimeSinceLastPulse',[StaleThresholdNum,Inf]);
            NumStale = size(P_DATASET,1);
            disp(['Number Stale: ',num2str(NumStale)])
        end
    end 
    methods (Hidden = true) %Support functions
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
        function obj = mindowsSchedular()
            %% Load objects
            obj.TaskController = TaskController;
            obj.handles.DataSetFiltering = DataSetFiltering;
            
            %% process
            obj.ComputerName = obj.getComputerName;
            obj.LastTradingDateNum = obj.GetLastTradingDate();
            obj.LastTradingDate = datestr(obj.LastTradingDateNum);
            
            %%
            [struct, Error] = obj.LoadStatus(date,obj.ComputerName)
        end
        function date = GetLastTradingDate(obj)
            date = today;
            date = obj.GetStoreDate(date);              
        end
    end
    methods % Load and Save Tracker.
        function SaveStatus(obj,struct,date,Name)
            %%
           filename = [obj.InstallDir,'Track\',Name,'_',strrep(datestr(date),'-','_'),'.mat'];
           filename = [obj.StockData,'Schedular\Track\',Name,'_',strrep(datestr(date),'-','_'),'.mat'];
           save(filename)
        end
        function [struct, Error] = LoadStatus(obj,date,Name)
            %%
            filename = [obj.SharedDir,'Schedular\Track\',Name,'_',strrep(datestr(date),'-','_'),'.mat'];
            try
                disp(['Load Path: ',filename])
                load(filename)
                Error = 0;
            catch
                struct = [];
                Error = -1;                
            end
        end
    end
end