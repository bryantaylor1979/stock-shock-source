classdef TaskMaster <   handle & ...
                        TrackerManagement & ...
                        StructureManagement & ...
                        DataSetFiltering
    properties
        InstallDir = []; 
        StockData
    end
    methods
        function obj = temp(obj)
             obj.InstallDir = [pwd,'\'];
             
             PWD = pwd;
             try 
                cd('P:\StockData [MEDIAPC]\StockData [MEDIAPC]\')
                obj.StockData = 'P:\StockData [MEDIAPC]\StockData [MEDIAPC]\';
             catch
                obj.StockData = 'P:\StockData [MEDIAPC]\';
             end
             disp(['ResultsDir: ',obj.StockData])
             cd(PWD)
             
             %% Tasks
             MaxTaskPerPC = 3;
             PC_Names = {   'MT'; ...
                            'BRYAN_PC'; ...
                            'MediaPc' };
             MaxNumberOfAttempts = 4;
                            
             FieldNames={   'ProgramName';      'MacroName';                    'StartTime';'Type';            'Target';    'NumberTimesRun';   'Status';   'Running'};
             table   =  {   'URL_Download',     'BritishBulls_ALLSTATUS',       '19:00:00', 'WeekDaysOnly',    10,          0,                  0,          false; ...
                            'URL_Download',     'ADVFN_URL_CompanyInfo',        '19:01:00', 'WeekDaysOnly',    2445,        0,                  0,          false; ...
                            'URL_Download',     'BritishBulls_HIST',            '19:10:00', 'WeekDaysOnly',    2445,        0,                  0,          false; ...
                            'URL_Download',     'DigitalLook_Symbol2Num_URL',   '19:11:00', 'WeekDaysOnly',    2445,        0,                  0,          false; ...
                            'URL_Download',     'NewsAlerts_RNS',               '19:09:00', 'WeekDaysOnly',    2445,        0,                  0,          false; ...
                            'URL_Download',     'SharePrice_Summary',           '19:12:00', 'WeekDaysOnly',    1699,        0,                  0,          false; ...
                            'URL_Download',     'Stox',                         '19:08:00', 'WeekDaysOnly',    2445,        0,                  0,          false; ...
                            'URL_Download',     'WhatBrokersSay',               '19:00:00', 'WeekDaysOnly',    3,           0,                  0,          false; ...
                            'URL_Download',     'FT_Analysis',                  '19:03:00', 'WeekDaysOnly',    2445,        0,                  0,          false; ...
                            'URL_Download',     'FT_Performance',               '19:14:00', 'WeekDaysOnly',    2445,        0,                  0,          false; ...
                            'URL_Download',     'NakedTrader',                  '19:15:00', 'WeekDaysOnly',    3,           0,                  0,          false};
             DATASET.table = table;
             DATASET.FieldNames = FieldNames;
             N_DATASET = obj.Planner2DataSet(DATASET);
             
             %%
             ComputerName = 'mt';
             ProgramName = 'URL_Download';
             ResultName = 'FT_Performance';
             
             %%
             Date = obj.GetStoreDate(today)
             obj.AddTask(Date,ComputerName,ProgramName,ResultName)
             
             %%
             N_DATASET = obj.GetTrack(N_DATASET);
             
        end
        function GetTasksRunning(obj,ComputerName,Date)
            %%
            [struct, Error] = obj.LoadStatus(Date,ComputerName)
            DATASET = obj.struct2DATASET(struct.detial)
            obj.NumRange(DATASET,'Started',[-0.5,0.5])
        end
        function AddTask(obj,Date,ComputerName,ProgramName,ResultName)
            %%
            [struct, Error] = obj.LoadStatus(Date,ComputerName);
            
            %%
            struct.detial.(ProgramName).(ResultName).TimeOfLastPulse = NaN;
            struct.detial.(ProgramName).(ResultName).Started = 0;
            struct.detial.(ProgramName).(ResultName).AgentName =  '';
            struct.detial.(ProgramName).(ResultName).Complete = 0;
            struct.detial.(ProgramName).(ResultName).EndTime = 'N/A';
            struct.detial.(ProgramName).(ResultName).Progress = 0;
            struct.detial.(ProgramName).(ResultName).Time = 'Queued';
            
            obj.SaveStatus(struct,date,ComputerName);
        end
        function date = GetStoreDate(obj,date)
            disp('Found function')
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
        function N_DATASET = GetTrack(obj,N_DATASET)
             [N_DATASET, Error] = obj.LoadTrack();
             if Error == -1
                obj.SaveTrack(N_DATASET);
             end
        end
        function SaveTrack(obj,N_DATASET)   
            %% check folder exists
            try
                cd([obj.StockData,'TaskMaster\Track\'])
            catch
                mkdir([obj.StockData,'TaskMaster\Track\'])
            end
            
            %%
            filename = [obj.StockData,'TaskMaster\Track\',datestr(today),'.mat']
            save(filename,'N_DATASET')
        end
        function [N_DATASET, Error] = LoadTrack(obj)
            Error = 0;
            filename = [obj.StockData,'TaskMaster\Track\',datestr(today),'.mat'];
            try
                load(filename)  
            catch
                N_DATASET = [];
                Error = -1;
            end
        end
    end
end
    
    