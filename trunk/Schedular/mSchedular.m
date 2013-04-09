classdef mSchedular <   handle & ... 
                        dynamicprops
    %TODO: Cope with no tracker being returned
    %TODO: Add Tasks to pending tracker list
    properties (SetObservable = true)
        %                   ComputerName,   Nework
        computerName = {    'BRYAN_PC',     'Kinners'; ...
                            'MediaPc',      'Cambs'; ...
                            'MT',           'Cambs'};                   
        NoOfWorkerPerMachine = 4
        Planner_DATASET
        Pending_DATASET = dataset([])
        GetStoreDate
        FinshedTaskIDs = [];
    end
    properties (Hidden = true)
        DatasetFiltering2
    end
    methods
        function Example(obj)
            %%
            close all
            clear classes
            
            obj = mSchedular
            ObjectInspector(obj)
        end
        function RUN(obj)
            %% Filter on task that need to start
            Type = obj.DetectType();
            DATASET = obj.DatasetFiltering2.ColumnStr(obj.Planner_DATASET,'Type','WeekDaysOnly');
            DATASET = obj.Filter_TaskTime(DATASET)
           
            %%  Choose next item
            x = size(DATASET,1);
            for i = 1:x
                B_DATASET = [];
                ID = size(obj.Pending_DATASET,1);
                N_DATASET = DATASET(i,:);    
                Org_ID =        obj.DatasetFiltering2.GetColumn(N_DATASET,'ID');
                ProgramName =   obj.DatasetFiltering2.GetColumn(N_DATASET,'ProgramName');
                MacroName =     obj.DatasetFiltering2.GetColumn(N_DATASET,'MacroName');
                NoOfPasses =    obj.DatasetFiltering2.GetColumn(N_DATASET,'NoOfPasses');
                Dependancy =    obj.DatasetFiltering2.GetColumn(N_DATASET,'Dependancy');
                
                Orginal_IDs = obj.DatasetFiltering2.GetColumn(obj.Pending_DATASET,'Orginal_ID');
                n = find(Orginal_IDs == Org_ID);
                if isempty(n) %Already submitted
                    if isnan(Dependancy)
                        for j = 1:NoOfPasses
                            if j == 1
                                Dependancy = NaN;
                            else
                                Dependancy = ID+j;
                            end
                            P_DATASET = dataset(    {ID+j,'ID'}, ...
                                                    {Org_ID,'Orginal_ID'}, ...
                                                    {ProgramName,'ProgramName'}, ...
                                                    {MacroName,'MacroName'}, ...
                                                    {Dependancy,'Dependancy'});
                            if j == 1
                                B_DATASET = P_DATASET;
                            else
                                B_DATASET = [B_DATASET;P_DATASET];
                            end
                        end
                        if isempty(obj.Pending_DATASET) == true
                            obj.Pending_DATASET = B_DATASET;
                        else
                            obj.Pending_DATASET = [obj.Pending_DATASET;B_DATASET];
                        end
                    end
                end
            end
        end
    end
    methods (Hidden = true)
        function obj = mSchedular()
            %%
            computerName = {'BRYAN_PC',     'Kinners'; ...
                            'MediaPc',      'Cambs'; ...
                            'MT',           'Cambs'}; 
                        
            obj.computerName = dataset( {computerName(:,1),'computerName'}, ...
                                        {computerName(:,2),'network'});
                        
            %% TIMES CAN NOT BE GREATER THEN MID NIGHT.
            ProgramName ={  1,  'URL_Download',    'ADVFN_URL_CompanyInfo',         3,  '20:00', 'WeekDaysOnly', NaN; ...
                            2,  'URL_Download',    'BritishBulls_ALLSTATUS',        3,  '20:00', 'WeekDaysOnly', NaN; ...
                            3,  'URL_Download',    'BritishBulls_HIST',             3,  '20:00', 'WeekDaysOnly', NaN; ...
                            4,  'URL_Download',    'FT_Analysis',                   3,  '20:00', 'WeekDaysOnly', NaN; ...
                            5,  'URL_Download',    'FT_Performance',                3,  '20:00', 'WeekDaysOnly', NaN; ...
                            6,  'URL_Download',    'NakedTrader',                   3,  '20:00', 'WeekDaysOnly', NaN; ...
                            7,  'URL_Download',    'NewsAlerts_RNS',                3,  '20:00', 'WeekDaysOnly', NaN; ...
                            8,  'URL_Download',    'DigitalLook_Symbol2Num_URL',    3,  '20:00', 'WeekDaysOnly', NaN; ...       
                            9,  'URL_Download',    'SharePrice_Summary',            3,  '20:00', 'WeekDaysOnly', NaN; ...
                            10, 'URL_Download',    'Stox',                          3,  '20:00', 'WeekDaysOnly', NaN; ...
                            11, 'URL_Download',    'WhatBrokersSay',                3,  '20:00', 'WeekDaysOnly', NaN; ...
                            12, 'WebPageDecoder',  'ADVFN_ProcessDay',              1,  '20:00', 'WeekDaysOnly', 1; ...
                            13, 'WebPageDecoder',  'BB_HIST_Decode',                1,  '20:00', 'WeekDaysOnly', 3; ...
                            14, 'WebPageDecoder',  'BB_ALL_STATUS_Decode',          1,  '20:00', 'WeekDaysOnly', 2; ...
                            15, 'WebPageDecoder',  'DL_Str2Num_ProcessDay',         1,  '15:01', 'WeekDaysOnly', 8};   
                        
             obj.Planner_DATASET = dataset( {cell2mat(ProgramName(:,1)),    'ID'}, ...
                                            {ProgramName(:,2),              'ProgramName'}, ...
                                            {ProgramName(:,3),              'MacroName'}, ...
                                            {cell2mat(ProgramName(:,4)),    'NoOfPasses'}, ...
                                            {ProgramName(:,5),              'Time2Start'}, ...
                                            {ProgramName(:,6),              'Type'}, ...
                                            {cell2mat(ProgramName(:,7)),    'Dependancy'});  
               %%                         
             obj.GetStoreDate = GetStoreDate;
             obj.DatasetFiltering2 = DatasetFiltering2;
             
             computerName = obj.DatasetFiltering2.GetColumn(obj.computerName,'computerName');
             x = max(size(computerName));
             for i = 1:x
                h = addprop(obj,['tracker_',computerName{i,1}])
                h.SetObservable = true;
                obj.(['tracker_',computerName{i,1}]) = pcTracker();
                obj.(['tracker_',computerName{i,1}]).pcName = computerName{i};
             end
        end
    end
    methods (Hidden = true)
        function O_DATASET = Filter_TaskTime(obj,DATASET)
            %% filter on less than now
            Time2Start = obj.DatasetFiltering2.GetColumn(DATASET,'Time2Start');
            ArrayOfTimes = datenum(Time2Start,'HH:MM');
            NOW = datenum(datestr(now,'HH:MM'),'HH:MM');
            n = find(ArrayOfTimes < NOW);
            
            %% filter all before opening and flag and error. 
            OPEN = datenum('08:00','HH:MM');
            p = find(ArrayOfTimes < OPEN);
            if not(isempty(p))
               error('Times before opening time is not supported. This shouldn''t be required') 
            end 
            O_DATASET = DATASET(n,:);
        end
        function Type = DetectType(obj)
            Day = datestr(now,'ddd');
            switch Day
                case {'Mon','Tue','Wed','Thu','Fri'}
                    Type = 'WeekDaysOnly';
                case {'Sat','Sun'}
                    Type = 'WeekEndsOnly';
                otherwise
                    error('day not recongised')
            end
        end
    end
end