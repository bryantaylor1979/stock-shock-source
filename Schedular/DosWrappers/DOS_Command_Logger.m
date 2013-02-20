classdef DOS_Command_Logger < handle
    properties (SetObservable = true)
        ControllerMode = 'Master' %Listener and Master
        Mode = 'batch'; %system or batch
        LogInputs = true
        LogOutputs = false
        Log2CommandWindow = true
        ProgramName = 'Schedular';
		LogProgamName = true;
        CommandStr
        Path
        State = 'ready'
        currentComputerName
        selectedComputerName = char([]) %if empty it will default to non remote executions
        remoteShareDir = 'S:\DOS\';
    end
    properties (SetObservable = true) %Batch only properties
        Batch_Job
        Batch_Worker
        StartTime
        LastStatusUpdate = '';
        Duration
        FinishTime
    end
    properties (SetObservable = true) %Status
        Error = 0;
        String = '';
    end
    properties (Hidden = true)
       handles 
       Mode_LUT = { 'batch'; ...
                    'system'};
       selectedComputerName_LUT = { 'mediapc'; ...
                                    'mt'};
       ControllerMode_LUT = {   'Listener'; ...
                                'Master'};
    end
    methods
        function Example(obj)
            %% Check connection to phone
            close all
            clear classes
            %%
            obj = DOS_Command_Logger('Path','Y:\URL_Download\');
            ObjectInspector(obj)
                
            %%
            obj.CommandStr = 'URL_Download.exe "Macro" "BritishBulls_ALLSTATUS"';
            obj.RUN();
            
            %% 
            obj.selectedComputerName = 'mt'
            obj.RUN()
            
            %% listener mode
        end
        function RUN(obj)
            %%
            if strcmpi(obj.ControllerMode,'Listener')
                disp('DOS_Command_Logger is in listener mode')
                %%
                info_filelist = obj.GetInfoList('info.mat');
                track_filelist = obj.GetInfoList('track.mat');
                infoFileToBeExcute = obj.GetInfoFileToBeExecuted(info_filelist,track_filelist);
                
                if isempty(infoFileToBeExcute)
                    disp('not dos commands need to be executed')
                    return 
                end
                obj.applySettings(infoFileToBeExcute)


                
                %% 
                if not(strcmpi(obj.selectedComputerName,obj.currentComputerName))
                   % not for this machine end
                   disp('NOT for this machine')
                   return
                end
            end
            %%
            if isempty(obj.selectedComputerName)
                obj.selectedComputerName = obj.getComputerName;
            end
            if strcmpi(obj.selectedComputerName,obj.currentComputerName)
                obj.RunOnThisMachine();
            else
                struct.Mode = obj.Mode;
                struct.ProgramName = obj.ProgramName;
                struct.CommandStr = obj.CommandStr;
                struct.selectedComputerName = obj.selectedComputerName;
                struct.Path = obj.Path;
                
                %logging
                struct.LogInputs = obj.LogInputs;
                struct.LogOutputs = obj.LogOutputs;
                struct.Log2CommandWindow = obj.Log2CommandWindow;
                struct.LogProgamName =  obj.LogProgamName;
                
                files = ImageIO('Path',obj.remoteShareDir,'ImageType','info.mat');
                files.RUN;
                info_filelist = files.names;
                
                info_filelist = strrep(info_filelist,'_info.mat','');
                info_filelist = strrep(info_filelist,'dos_command_','');
                nums = str2double(info_filelist);
                Num = max(nums);
                if isempty(Num)
                    Num = -1;
                end
                save([obj.remoteShareDir,'dos_command_',num2str(Num+1),'_info.mat'],'struct')
                disp('run on other machine')
            end
        end
    end
    methods (Hidden = true) %support for remote
        function info_filelist = GetInfoList(obj,EndStr)
            files = ImageIO('Path',obj.remoteShareDir,'ImageType',EndStr);
            files.RUN;
            info_filelist = files.names;
        end    
        function infoFileToBeExcute = GetInfoFileToBeExecuted(obj,info_filelist,track_filelist)
            x = size(info_filelist,1);
            infoFileToBeExcute = [];
            for i = 1:x
                n = strcmpi(info_filelist{i},track_filelist);
                if isempty(n)
                    infoFileToBeExcute = info_filelist{i};
                    break
                end
            end
        end
        function applySettings(obj,infoFileToBeExcute)
            %% apply settings
            load([obj.remoteShareDir,infoFileToBeExcute])
            names = fieldnames(struct);
            x = size(names,1);
            for i = 1:x
                obj.(names{i}) = struct.(names{i});
            end
        end
    end
    methods (Hidden = true)
        function name = getComputerName(obj)
            % GETCOMPUTERNAME returns the name of the computer (hostname)
            % name = getComputerName()
            %
            % WARN: output string is converted to lower case
            %
            %
            % See also SYSTEM, GETENV, ISPC, ISUNIX
            %
            % m j m a r i n j (AT) y a h o o (DOT) e s
            % (c) MJMJ/2007
            %

            [ret, name] = system('hostname');   

            if ret ~= 0,
               if ispc
                  name = getenv('COMPUTERNAME');
               else      
                  name = getenv('HOSTNAME');      
               end
            end
            name = lower(name);
            load cr
            name = strrep(name,cr,'');
            name = strrep(name,' ','');
        end
        function RunOnThisMachine(obj)
            commandstr = obj.CommandStr;
            if obj.Log2CommandWindow == true
                if obj.LogInputs == true
                    if obj.LogProgamName == true
                        disp([obj.ProgramName,': ',commandstr]) 
                    else
                        disp(commandstr) 
                    end
                end
            end
            if strcmpi(obj.Mode,'system')
                obj.runSystem;
            elseif strcmpi(obj.Mode,'batch')
                obj.runBatch;
            end
            
            if not(isempty(obj.String))
                if obj.LogOutputs == true
                    disp(String)
                end
            end            
        end
        function obj = DOS_Command_Logger(varargin)    
            x = size(varargin,2);
			for i = 1:2:x
				obj.(varargin{i}) = varargin{i+1};
            end
            obj.currentComputerName = obj.getComputerName();
        end
        function runSystem(obj)
            if not(isempty(obj.Path))
                PWD = pwd;
                cd(obj.Path);
            end
            
            obj.State = 'creating job';
            [obj.Error,obj.String] = system(obj.CommandStr);
            obj.State = 'finished';
            
            if not(isempty(obj.Path))
                cd(PWD);
            end
        end
        function runBatch(obj)
            if not(isempty(obj.Path))
                PWD = pwd;
                cd(obj.Path);
            end
            
            obj.State = 'creating job';
            obj.Batch_Worker = createJob();
            obj.Batch_Job = createTask(obj.Batch_Worker,@system,0,{obj.CommandStr});
            obj.State = 'submitting job';
            
            submit(obj.Batch_Worker); 
            starttime = now;
            obj.StartTime = datestr(starttime,'HH:MM:SS');
            obj.State = 'Pending';
            

            
            %% monitor with timer
            obj.handles.timerObj = timer('TimerFcn',@(x,y)obj.UpdateState(starttime));
            set(obj.handles.timerObj,'ExecutionMode','fixedSpacing','Period',3);
            start(obj.handles.timerObj);
        end
        function UpdateState(varargin)
            %%
            obj = varargin{1};
            starttime = varargin{2};
            
            %%
            State = get(obj.Batch_Job,'State');
            obj.State = State;
            obj.LastStatusUpdate = datestr(now,'HH:MM:SS');
            obj.Duration = datestr(now-starttime,'HH:MM:SS');
            
            if strcmpi(State,'finished')
                stop(obj.handles.timerObj);
                delete(obj.handles.timerObj);
                destroy(obj.Batch_Worker);
                obj.Batch_Worker = [];
                obj.FinishTime = datestr(now,'HH:MM:SS');
                obj.LastStatusUpdate = datestr(now,'HH:MM:SS');
            end
            
            if strcmpi(obj.ControllerMode,'Listener')
                
            end
        end
    end
end