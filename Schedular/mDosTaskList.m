classdef mDosTaskList       < 	handle & ...
								DOS_Command_Logger
	%TODO: GUI which is a dos string builder.
	%TODO: Error checking. i.e check you not using lt (less than) in the wrong place. May even auto detect, i.e numbers can be eq, ne, lt etc. Where string can only be eq, ne.
	%TODO: The table column filter is not avaliable. 
	%TODO: find out about a PID kill command.
	%TODO: PRIORITY-HIGH, string table decode.
	properties
		% this control access to remote system
		remotesystem_Enable = false
		remotesystem_name = 'LTCBG-BRYANT'  % Windows Computer Name
		remotesystem_username = 'bryant'   	% domain\user
		remotesystem_password = 'Tango224' 	% passowrd
		
		% table view
		% ==========
		% standard -> ImageName 	PID 	SessionName 	Session# 	MemUsage
		% services -> ImageName		PID		Services
		% modules  -> ImageName		PID		Modules
		
		%TODO: find out if you can add these columns? username, status, cputime, windowTitle
		output_table_view = 'standard'; %standard, services, modules or verbose
		
		% filter options
		% ==============
		filter_username_Enable = false
		filter_username = 'bryant'
		filter_username_operator = 'ne'  %ne - not equal
										 %eq - equal
		
		filter_status_Enable = false
		filter_status = 'running' 		 %running, not responding, unknown
		filter_status_operator = 'eq'	 %ne - not equal
										 %eq - equal
										 
		filter_imagename_Enable = false
		filter_imagename = 'tasklist.exe'
		filter_imagename_operator = 'eq' %ne - not equal
										 %eq - equal	

		filter_PID_Enable = false
		filter_PID = 512
		filter_PID_operator = 'eq'		 %ne - not equal
										 %eq - equal
										 %gt - greater than
										 %lt - less than
										 %ge - greater than and equal to
										 %le - less than and equal 
										 
		filter_session_Enable = false
		filter_session = 1 %Session Number: 0 or 1
		filter_session_operator = 'eq'	 %ne - not equal
										 %eq - equal
										 %gt - greater than
										 %lt - less than
										 %ge - greater than and equal to
										 %le - less than and equal

		filter_sessionName_Enable = false
		filter_sessionName = 'Services' 	%Services or Console
		filter_sessionName_operator = 'eq' 	%ne - not equal
											%eq - equal	
											
		filter_cpuTime_Enable = false
		filter_cpuTime = 'Services' 	 %hh:mm:ss
										 %hh - hours
										 %mm - minutes
										 %ss - seconds
		filter_cpuTime_operator = 'eq'	 %ne - not equal
										 %eq - equal
										 %gt - greater than
										 %lt - less than
										 %ge - greater than and equal to
										 %le - less than and equal
										 
		filter_memUsage_Enable = false
		filter_memUsage = 100	%Memory usage in KB
		filter_memUsage_operator = 'gt'  %ne - not equal
										 %eq - equal
										 %gt - greater than
										 %lt - less than
										 %ge - greater than and equal to
										 %le - less than and equal

	    % to see services use the /SVC
		filter_services_Enable = false
		filter_services = 'Netlogon'	    %Service name
		filter_services_operator = 'eq'  	%ne - not equal
											%eq - equal
											
		% to see services use the /M
		filter_modules_Enable = false
		filter_modules = 'ntdll.dll'	    %Service name
		filter_modules_operator = 'eq'  	%ne - not equal
											%eq - equal
		
		% window Title
		filter_windowTitle_Enable = false
		filter_windowTitle = 'Spotify'		%Service name
		filter_windowTitle_operator = 'eq'  %ne - not equal
											%eq - equal		
	end
	properties %Should not need modified
		% table output format
		output_format = 'CSV'	% TABLE LIST CSV	
	end
	methods
		function Example(obj)
			%% 
			close all
			clear classes
			
			%% run normal tasklist display
			% ============================
			obj = mDosTaskList();
			DATASET = obj.TaskList;
            DATASET(1:10,:)
			
			%% remote connection
			% ==================
            % LTCBG-BRYANT, bryant, Tango224
            % MediaPC, bryan, tango224
            % MT, bryan, tango224
            % i canit get this to work on the mediapc and MT
			obj = mDosTaskList(		'remotesystem_Enable',       true, ...
										'remotesystem_name',		'"MT"', ...      % Windows Computer Name
										'remotesystem_username',	'"MT\bryan taylor"', ...		% domain\user
										'remotesystem_password',	'"tango224"');		% passowrd
			DATASET = obj.TaskList;
            DATASET(1:10,:)
			
			%% Changing format
			% ================
			
			%% standard
			obj = mDosTaskList( 'output_table_view', 'standard');
			DATASET = obj.TaskList
			
			%% services
			obj = mDosTaskList( 'output_table_view', 'services');
			DATASET = obj.TaskList;			
			
			%% modules
			obj = mDosTaskList( 'output_table_view', 'modules');
			DATASET = obj.TaskList;
            
            %% modules
			obj = mDosTaskList( 'output_table_view', 'verbose');
			DATASET = obj.TaskList;
			
			%% Filtering
			% ==========
			%% Status filtering - Running
			obj = mDosTaskList( 	'filter_status_Enable', 	 true, ...
									'filter_status',			'running', ...  %running, not responding, unknown
									'filter_status_operator',   'eq');	 %ne, eq
			DATASET = obj.TaskList
            
            %% Status filtering - unknown
			obj = mDosTaskList( 	'filter_status_Enable', 	 true, ...
									'filter_status',			'unknown', ...  %running, not responding, unknown
									'filter_status_operator',   'eq');	 %ne, eq
			DATASET = obj.TaskList
            
            %% Status filtering - not responding
			obj = mDosTaskList( 	'filter_status_Enable', 	 true, ...
									'filter_status',			'not responding', ...  %running, not responding, unknown
									'filter_status_operator',   'eq');	 %ne, eq
			DATASET = obj.TaskList
			
			%% Image Name filtering
			obj = mDosTaskList( 	'filter_imagename_Enable',   true, ...
									'filter_imagename',         'tasklist.exe', ...
									'filter_imagename_operator','eq'); 	%ne, eq
			DATASET = obj.TaskList
			
			%% PID filtering
			obj = mDosTaskList( 	'filter_PID_Enable',	true, ...
									'filter_PID',			348, ...
									'filter_PID_operator', 'eq');		 %ne, eq, gt, lt, ge, le
			DATASET = obj.TaskList
			
			%% session filtering
			obj = mDosTaskList( 	'filter_session_Enable',	true	, ...
									'filter_session',			1		, ... %Session Number: 0 or 1
									'filter_session_operator',	'eq');
            DATASET = obj.TaskList
		
			%% session Name
			obj = mDosTaskManager( 	'filter_sessionName_Enable', 	 true		, ...
									'filter_sessionName',			'Console'	, ... 	%Services or Console
									'filter_sessionName_operator',  'eq');				%ne, eq
            DATASET = obj.TaskList
			
			%% cpu Time - How long the task has been running. 	
			obj = mDosTaskList( 	'output_table_view',            'verbose'   , ...
                                    'filter_cpuTime_Enable',		 true		, ...
									'filter_cpuTime',				'00:00:05'	, ... 	
									'filter_cpuTime_operator',      'eq'); 				%ne, eq, gt, lt, ge, le
            DATASET = obj.TaskList
				
			%% mem Usage
			obj = mDosTaskList( 	'filter_memUsage_Enable',		true		, ...
									'filter_memUsage',              10000		, ...	%Memory usage in KB
									'filter_memUsage_operator',    'gt');          	%ne, eq
            DATASET = obj.TaskList
            
			%% services 
			obj = mDosTaskList( 	'output_table_view',            'services'  , ...
                                    'filter_services_Enable',        true		, ...
									'filter_services',              'Netlogon'	, ...	%Service name
									'filter_services_operator',     'eq');  			%ne, eq
			DATASET = obj.TaskList
            
			%% modules
			obj = mDosTaskList( 	'output_table_view',            'modules'  , ...
                                    'filter_modules_Enable',	 	 true		, ...
									'filter_modules',				'mswsock.dll'	, ...	%Service name
									'filter_modules_operator',      'eq');  			%ne, eq
            DATASET = obj.TaskList
		
			%% window Title
			obj = mDosTaskList( 	'output_table_view',            'verbose'  , ...
                                    'filter_windowTitle_Enable', 	 true		, ...
									'filter_windowTitle',           'Spotify'	, ...	%Service name
									'filter_windowTitle_operator',  'eq'); 				%ne, eq		
            DATASET = obj.TaskList
			

        end
		function DATASET_OUT = TaskList(obj)
			% This tool displays a list of currently running processes
			%% on eith a local or remote machine. 
			CommandString = obj.StringBuilder();
			[Error,String] = obj.Dos_Command(CommandString);
            
            if obj.remotesystem_Enable == true
                ErrorString = 'ERROR: Logon failure: unknown user name or bad password.';
                if strncmp(String,ErrorString,56)
                   errordlg(ErrorString, 'Error Dialog', 'modal');
                   error(ErrorString);
                end
                %%
                ErrorString = 'ERROR: The RPC server is unavailable.'
                if strncmp(String,ErrorString,37)
                   errordlg(ErrorString, 'Error Dialog', 'modal');
                   error(ErrorString);                   
                end
            end
            
            %%
            DATASET_OUT = obj.DecodeString(String);
        end
    end
    methods %TaskList - Support Functions
        function TaskListDosHelp(obj)
            %%
            dos('tasklist /?')
        end      
        function string = StringBuilder(obj)
			%% Machine Connection
			%% ==================
			
			string = 'tasklist';
			if obj.remotesystem_Enable == true
				string = [string,' /S ',obj.remotesystem_name,' /U ',obj.remotesystem_username,' /P ',obj.remotesystem_password];
			end
			
			%% FILTERING
			%% =========
			
			% username
			if obj.filter_username_Enable == true
				string = [string,' /FI "USERNAME ',	obj.filter_username_operator,	' ',obj.filter_username,'"'];
			end
			% status
			if obj.filter_status_Enable == true
				string = [string,' /FI "STATUS ',	obj.filter_status_operator,		' ',obj.filter_status,'"'];
			end
			% image name
			if obj.filter_imagename_Enable == true
				string = [string,' /FI "IMAGENAME ',	obj.filter_imagename_operator,	' ',obj.filter_imagename,'"'];
			end
			% PID
			if obj.filter_PID_Enable == true
				string = [string,' /FI "PID ',	obj.filter_imagename_operator,	' ',num2str(obj.filter_PID),'"'];
			end
			% session
			if obj.filter_session_Enable == true
				string = [string,' /FI "SESSION ',	obj.filter_session_operator,	' ',num2str(obj.filter_session),'"'];
			end
			% session name
			if obj.filter_sessionName_Enable == true
				string = [string,' /FI "SESSIONNAME ',	obj.filter_sessionName_operator,	' ',obj.filter_sessionName,'"'];
			end
			% cpu time
			if obj.filter_cpuTime_Enable == true
				string = [string,' /FI "CPUTIME ',	obj.filter_cpuTime_operator,	' ',obj.filter_cpuTime,'"'];
			end
			% memory usage
			if obj.filter_memUsage_Enable == true
				string = [string,' /FI "MEMUSAGE ',	obj.filter_memUsage_operator,	' ',num2str(obj.filter_memUsage),'"'];
			end
			% services
			if obj.filter_services_Enable == true
				string = [string,' /FI "SERVICES ',	obj.filter_services_operator,	' ',obj.filter_services,'"'];
			end
			% modules
			if obj.filter_modules_Enable == true
				string = [string,' /FI "MODULES ',	obj.filter_modules_operator,	' ',obj.filter_modules,'"'];
			end
			% window title
			if obj.filter_windowTitle_Enable == true
				string = [string,' /FI "WINDOWTITLE ',	obj.filter_windowTitle_operator,	' ',obj.filter_windowTitle,'"'];
			end
			
			%% OUTPUT TABLE
			%% ============
			
			% output format
			string = [string,' /FO "',obj.output_format,'"'];
			
			% output table view
			if strcmpi(obj.output_table_view,'services')
				string = [string,' /SVC'];
			elseif strcmpi(obj.output_table_view,'modules')
				string = [string,' /M'];
            elseif strcmpi(obj.output_table_view,'verbose')
                string = [string,' /V'];
			end
        end
        function obj = mDosTaskList(varargin)
            %%
			x = size(varargin,2);
			for i = 1:2:x
				obj.(varargin{i}) = varargin{i+1};
            end
        end
    end
    methods %Decoders
        function DATASET_OUT = DecodeString(obj,string)
            %% ImageName
            switch lower(obj.output_table_view)
                case 'standard'
                    DATASET_OUT = obj.DecodeStandard(string);
                case 'services'	
                    DATASET_OUT = obj.DecodeServices(string);
                case 'modules'
                    DATASET_OUT = obj.DecodeModules(string);
                case 'verbose'
                    DATASET_OUT = obj.DecodeVerbose(string);
                otherwise
            end
        end
        function DATASET_OUT = DecodeStandard(obj,string)
                array = textscan(string,'%s%d%s%d%s%s', ...
                                        'Delimiter', '","', ...
                                        'CollectOutput',false, ...
                                        'Headerlines', 1 , ...
                                        'MultipleDelimsAsOne', true, ...
                                        'EndOfLine','\n');
                imageName = array{1};
                PID = num2cell(array{2});	 	
                SessionName = array{3};
                SessionNum = num2cell(array{4}); 
                MemUsage1 = array{5};
                MemUsage2 = array{6};

                %% Masssage Data a Bit
                x = size(MemUsage1,1);
                for i = 1:x
                    MemUsage{i,1} = [MemUsage1{i},MemUsage2{i}];
                end
                %%
                str = 'INFO: No tasks are running which match the specified criteria';
                x = size(str,2);
                if not(strncmpi(string,str,x))        
                    %%
                    DATASET_OUT = dataset(  {imageName,'imageName'}, ...
                                            {PID,'PID'}, ...
                                            {SessionName,'SessionName'}, ...
                                            {SessionNum,'SessionNum'}, ...
                                            {MemUsage,'MemUsage'});        
                else
                    %%
                    DATASET_OUT = dataset(  {[],'imageName'}, ...
                                            {[],'PID'}, ...
                                            {[],'SessionName'}, ...
                                            {[],'SessionNum'}, ...
                                            {[],'MemUsage'});                         
                end
        end
        function DATASET_OUT = DecodeModules(obj,string)
                %%
                array = textscan(string,['%s%d%s%s%s%s%s%s%s%s%s%s%s%s%s', ...
                                         '%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s', ... 
                                         '%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s', ...
                                         '%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s', ...
                                         '%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s', ...
                                         '%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s', ...
                                         '%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s', ...
                                         '%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s', ...
                                         '%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s', ...
                                         '%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s', ...
                                         '%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s', ...
                                         '%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s', ...
                                         '%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s', ...
                                         '%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s', ...
                                         '%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s', ...
                                         '%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s', ...
                                         '%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s', ...
                                         '%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s', ...
                                         '%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s', ...
                                         '%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s', ...
                                         '%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s'], ...
                                        'Delimiter', '","', ...
                                        'CollectOutput',false, ...
                                        'Headerlines', 1 , ...
                                        'MultipleDelimsAsOne', true, ...
                                        'EndOfLine','\n');

                %%
                imageName = array{1};
                PID = num2cell(array{2});	

                %%
                x = size(array,2);
                y = size(imageName,1);

                %%
                for j = 3:y
                    for i = 3:x
                        if not(isempty((array{i}{j})))
                            if i == 3
                            string = array{i}{j};   
                            else
                            string = [string,',',array{i}{j}];
                            end
                        end
                    end
                    Modules{j,1} = string;
                end

                %%
                DATASET_OUT = dataset(  {imageName,'imageName'}, ...
                                        {PID,'PID'}, ...
                                        {Modules,'Modules'});                
        end
        function DATASET_OUT = DecodeServices(obj,string)
                array = textscan(string,'%s%d%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s', ...
                                        'Delimiter', '","', ...
                                        'CollectOutput',false, ...
                                        'Headerlines', 1 , ...
                                        'MultipleDelimsAsOne', true, ...
                                        'EndOfLine','\n');
                %%
                imageName = array{1};
                PID = num2cell(array{2});

                x = size(imageName,1);
                for j = 1:x
                    for i = 3:19
                        if not(isempty((array{i}{j})))
                            if i == 3
                            string = array{i}{j};   
                            else
                            string = [string,',',array{i}{j}];
                            end
                        end
                    end
                    Services{j,1} = string;
                end
                DATASET_OUT = dataset(  {imageName,'imageName'}, ...
                                        {PID,'PID'}, ...
                                        {Services,'Services'});                
        end
        function DATASET_OUT = DecodeVerbose(obj,string)
           %%
            load CR
            array = obj.Delimit(string,cr);
            
            %% crop reshape array
            x = size(array,2);
            for i = 2:x-1
                line = array{i};
                array2 = obj.Delimit(line,'","');
                
                imageName{i-1,1} = array2{1};
                PID{i-1,1} = str2num(array2{2});
                SessionName{i-1,1} = array2{3};
                SessionNum{i-1,1} = str2num(array2{4});
                MemUsage{i-1,1} = array2{5};
                Status{i-1,1} = array2{6};
                UserName{i-1,1} = array2{7};
                CPUTime{i-1,1} = array2{8};
                WindowTitle{i-1,1} = array2{9};
            end
        
                                    
            %%
            DATASET_OUT = dataset(      {imageName,'imageName'}, ...
                                        {PID,'PID'}, ...
                                        {SessionName,'SessionName'}, ...
                                        {SessionNum,'SessionNum'}, ...
                                        {MemUsage,'memUsage'}, ...
                                        {Status,'Status'}, ...
                                        {UserName,'username'}, ...
                                        {CPUTime,'cpuTime'}, ...
                                        {WindowTitle,'WindowTitle'});  
        end
        function array = Delimit(obj,string,cr)
            %%
            n = findstr(string,cr);
            p = max(size(cr));
            x = size(n,2);
            for i = 1:x 
                if i == 1
                    array{i} = string(2:n(i)-1);
                else
                    array{i} = string(n(i-1)+p:n(i)-1);
                end
            end
            array{x+1} = string(n(end)+p:end-1);
        end
    end
end