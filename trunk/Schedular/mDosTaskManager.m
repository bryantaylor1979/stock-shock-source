classdef mDosTaskManager	< 	handle & ...
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
		output_table_view = 'standard'; %standard or services or modules
		
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
		output_display_verbose = false;		
	end
	methods
		function Example(obj)
			%% 
			close all
			clear classes
			
			%% run normal tasklist display
			%% ===========================
			obj = mDosTaskManager();
			DATASET = obj.TaskList;
			
			%% remote connection
			%% =================
			obj = mDosTaskManager(		remotesystem_Enable, 	false, ...
										remotesystem_name,		'LTCBG-BRYANT', ... % Windows Computer Name
										remotesystem_username,	'bryant'   			% domain\user
										remotesystem_password,	'Tango224');		% passowrd
			DATASET = obj.TaskList;
			
			%% Changing format
			%% ===============
			
			%% standard
			obj = mDosTaskManager( output_table_view, 'standard');
			DATASET = obj.TaskList;
			
			%% services
			obj = mDosTaskManager( output_table_view, 'services');
			DATASET = obj.TaskList;			
			
			%% modules
			obj = mDosTaskManager( output_table_view, 'modules');
			DATASET = obj.TaskList;
			
			%% Filtering
			%% =========
			%% Status filtering
			obj = mDosTaskManager( 	filter_status_Enable, 	 true, ...
									filter_status,			'running', ...  %running, not responding, unknown
									filter_status_operator, 'eq');	 %ne, eq
			DATASET = obj.TaskList;
			
			%% Image Name filtering
			obj = mDosTaskManager( 	filter_imagename_Enable,   true, ...
									filter_imagename,		  'tasklist.exe'
									filter_imagename_operator,'eq'); 	%ne, eq
			DATASET = obj.TaskList;
			
			%% PID filtering
			obj = mDosTaskManager( 	filter_PID_Enable,	true, ...
									filter_PID,			512, ...
									filter_PID_operator,'eq');		 %ne, eq, gt, lt, ge, le
			DATASET = obj.TaskList;
			
			%% session filtering
			obj = mDosTaskManager( 	filter_session_Enable,		 false	, ...
									filter_session,				 1		, ... %Session Number: 0 or 1
									filter_session_operator,	'eq');
		
			%% session Name
			obj = mDosTaskManager( 	filter_sessionName_Enable, 	 false		, ...
									filter_sessionName,			'Services'	, ... 	%Services or Console
									filter_sessionName_operator,'eq');				%ne, eq
			
			%% cpu Time - How long the task has been running. 	
			obj = mDosTaskManager( 	filter_cpuTime_Enable,		 false		, ...
									filter_cpuTime,				'00:00:05'	, ... 	
									filter_cpuTime_operator,	'eq'); 				%ne, eq, gt, lt, ge, le
				
			%% mem Usage
			obj = mDosTaskManager( 	filter_memUsage_Enable,		 false		, ...
									filter_memUsage,			 100		, ...	%Memory usage in KB
									filter_memUsage_operator,	'gt');          	%ne, eq

			%% services 
			obj = mDosTaskManager( 	filter_services_Enable,		 false		, ...
									filter_services,			'Netlogon'	, ...	%Service name
									filter_services_operator,	'eq');  			%ne, eq
											
			%% modules
			obj = mDosTaskManager( 	filter_modules_Enable,	 	 false		, ...
									filter_modules,				'ntdll.dll'	, ...	%Service name
									filter_modules_operator,	'eq');  			%ne, eq
		
			% window Title
			obj = mDosTaskManager( 	filter_windowTitle_Enable, 	 false		, ...
									filter_windowTitle, 		'Spotify'	, ...	%Service name
									filter_windowTitle_operator,'eq'); 				%ne, eq		

			
			%%
			x = size(varargin,2)
			for i = 1:2:x
				obj.(varargin{i}) = varargin{i+1};
			end
		end
		function TaskList(obj)
			% This tool displays a list of currently running processes
			% on either a local or remote machine. 
			CommandString = obj.StringBuilder();
			[Error,String] = obj.Dos_Command(CommandString);
			
			%% decode the string.
		end
		function string = StringBuilder(obj)
			%% Machine Connection
			%% ==================
			
			string = 'tasklist';
			if remotesystem_Enable == true
				string = [string,' /S ',obj.system,' /U ',obj.username,' /P ',obj.password];
			end
			
			%% FILTERING
			%% =========
			
			% username
			if filter_username_Enable == true
				string = [string,' /FI "USERNAME ',	obj.filter_username_operator,	' ',obj.filter_username,'"'];
			end
			% status
			if filter_status_Enable == true
				string = [string,' /FI "STATUS ',	obj.filter_status_operator,		' ',obj.filter_status,'"'];
			end
			% image name
			if filter_imagename_Enable == true
				string = [string,' /FI "IMAGENAME ',	obj.filter_imagename_operator,	' ',obj.filter_imagename,'"'];
			end
			% PID
			if filter_PID_Enable == true
				string = [string,' /FI "PID ',	obj.filter_imagename_operator,	' ',obj.filter_imagename,'"'];
			end
			% session
			if filter_session_Enable == true
				string = [string,' /FI "PID ',	obj.filter_session_operator,	' ',obj.filter_session,'"'];
			end
			% session name
			if filter_sessionName_Enable == true
				string = [string,' /FI "PID ',	obj.filter_sessionName_operator,	' ',obj.filter_sessionName,'"'];
			end
			% cpu time
			if filter_cpuTime_Enable == true
				string = [string,' /FI "PID ',	obj.filter_cpuTime_operator,	' ',obj.filter_cpuTime,'"'];
			end
			% memory usage
			if filter_memUsage_Enable == true
				string = [string,' /FI "PID ',	obj.filter_memUsage_operator,	' ',obj.filter_memUsage,'"'];
			end
			% services
			if filter_services_Enable == true
				string = [string,' /FI "PID ',	obj.filter_services_operator,	' ',obj.filter_services,'"'];
			end
			% modules
			if filter_modules_Enable == true
				string = [string,' /FI "PID ',	obj.filter_modules_operator,	' ',obj.filter_modules,'"'];
			end
			% window title
			if filter_windowTitle_Enable == true
				string = [string,' /FI "PID ',	obj.filter_windowTitle_operator,	' ',obj.filter_windowTitle,'"'];
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
			end
		end
	end
end