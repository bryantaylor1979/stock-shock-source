classdef mTaskList < handle
    properties (SetObservable = true)
        computerName
    	output_table_view    	
        filter_Enable = true;
        filter_name = 'imagename';
        filter_value = 'URL_Download.exe';
        filter_operator = 'eq';
        DATASET = dataset()
        Dos_Shell
        mDosTaskList
    end
    properties (Hidden = true)
        filter_name_LUT = {  'username' ; ...
                             'status'; ...
                             'imagename'; ...
                             'PID'; ...
                             'session'; ...
                             'cpuTime'; ...
                             'memUsage'; ...
                             'services'; ...
                             'modules'; ...
                             'windowTitle'};
        output_table_view_LUT = {  'standard'; ...
                                   'services'; ...
                                   'modules'; ...
                                   'verbose'};
        computerName_LUT = {   'mediapc'; ...
                               'mt'; ...
                               'ltcbg-bryant'};
        remotesystem_Enable %Not working
    	remotesystem_name   %Not working
    	remotesystem_username %Not working
    	remotesystem_password %Not working
    end
    methods
        function Example(obj)
            %%
            close all
            clear classes
            obj = mTaskList
            ObjectInspector(obj)
        end
        function RUN(obj)      
           obj.mDosTaskList.remotesystem_Enable = obj.remotesystem_Enable;
           obj.mDosTaskList.remotesystem_name = obj.remotesystem_name;
           obj.mDosTaskList.remotesystem_username = obj.remotesystem_username;
           obj.mDosTaskList.remotesystem_password = obj.remotesystem_password;
           obj.mDosTaskList.output_table_view = obj.output_table_view; 	
            
           obj.SetEnables();
           obj.mDosTaskList.(['filter_',obj.filter_name]) = obj.filter_value;
           obj.mDosTaskList.(['filter_',obj.filter_name,'_operator']) = obj.filter_operator;
           obj.mDosTaskList.RUN()
           obj.DATASET = obj.mDosTaskList.DATASET;
        end
    end
    methods (Hidden = true)
        function obj = mTaskList(varargin)
            x = size(varargin,2);
            for i = 1:2:x
                obj.(varargin{i}) = varargin{i+1};
            end
            
            if isempty(obj.Dos_Shell)
                obj.mDosTaskList = mDosTaskList();
            else
                obj.mDosTaskList = mDosTaskList('Dos_Shell',obj.Dos_Shell);
            end
            
            obj.remotesystem_Enable = obj.mDosTaskList.remotesystem_Enable;
            obj.remotesystem_name = obj.mDosTaskList.remotesystem_name;
            obj.remotesystem_username = obj.mDosTaskList.remotesystem_username;
            obj.remotesystem_password = obj.mDosTaskList.remotesystem_password;
            obj.output_table_view = obj.mDosTaskList.output_table_view; 	
        end
        function SetEnables(obj)
            %%
            x = max(size(obj.filter_name_LUT));
            for i = 1:x
                obj.mDosTaskList.(['filter_',obj.filter_name_LUT{i},'_Enable']) = false;
            end
            if obj.filter_Enable == true
                obj.mDosTaskList.(['filter_',obj.filter_name,'_Enable']) = true;
                
            end
        end
    end
end