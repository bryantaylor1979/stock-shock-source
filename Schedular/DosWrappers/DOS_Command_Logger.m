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
        selectedComputerName = '' %Default is currentComputerName (non remote executions)
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
                                    'mt'; ...
                                    'ltcbg-bryant'};
       ControllerMode_LUT = {   'Listener'; ...
                                'Master'; ...
                                'MasterSim'}; %In master sim mode you can force a token even on the same machine.
       infoFileToBeExcute
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
            
            %% MasterSim  mode
            obj = DOS_Command_Logger(   'ControllerMode', 'MasterSim', ...
                                        'Path', 'Y:\URL_Download\', ...
                                        'remoteShareDir','Y:\URL_Download\Swap\');
            obj.CommandStr = 'URL_Download.exe "Macro" "BritishBulls_ALLSTATUS"';
            ObjectInspector(obj)
            
            %% 
            obj = DOS_Command_Logger(      'ControllerMode', 'Listener', ...
                                            'remoteShareDir', 'Y:\URL_Download\Swap\');
            ObjectInspector(obj)
        end
        function RUN(obj)
            %%
            if strcmpi(obj.ControllerMode,'Listener')
                disp('DOS_Command_Logger is in listener mode')
                %%
                info_filelist = obj.GetInfoList('info.mat')
                track_filelist = obj.GetInfoList('track.mat')
                infoFileToBeExcute = obj.GetInfoFileToBeExecuted(info_filelist,track_filelist)
                
                x = size(infoFileToBeExcute,1);
                NoneForThisMachine = true;
                for i = 1:x
                    obj.applySettings(infoFileToBeExcute{i});
                    disp([infoFileToBeExcute{i},' to be executed on ',obj.selectedComputerName])
                    if not(strcmpi(obj.selectedComputerName,obj.currentComputerName))
                       % not for this machine end
                       disp('NOT for this machine')
                    else
                       obj.infoFileToBeExcute = infoFileToBeExcute{i};
                       NoneForThisMachine = false;
                       break
                    end
                end
                if NoneForThisMachine == true
                    return
                end
            end
            %%
            if isempty(obj.selectedComputerName)
                obj.selectedComputerName = obj.getComputerName;
            end
            if strcmpi(obj.selectedComputerName,obj.currentComputerName)
                if strcmpi(obj.ControllerMode,'MasterSim')
                    Num = obj.FindLastTokenNumber();
                    obj.CreateTokens(Num+1);
                    obj.State = 'waiting for tracker';
                    starttime = now;
                    obj.StartTime = datestr(starttime,'HH:MM:SS');
                    obj.handles.timerObj = timer('TimerFcn',@(x,y)obj.Listen2RemoteTask(Num+1));
                    set(obj.handles.timerObj,'ExecutionMode','fixedSpacing','Period',3);
                    start(obj.handles.timerObj);
                else
                    obj.RunOnThisMachine();
                end
            else
                Num = obj.FindLastTokenNumber();
                obj.CreateTokens(Num+1);
                obj.State = 'waiting for tracker';
                starttime = now;
                obj.StartTime = datestr(starttime,'HH:MM:SS');
                obj.handles.timerObj = timer('TimerFcn',@(x,y)obj.Listen2RemoteTask(Num+1));
                set(obj.handles.timerObj,'ExecutionMode','fixedSpacing','Period',3);
                start(obj.handles.timerObj);
            end
        end
    end
    methods (Hidden = true) %support for remote
        function Num = FindLastTokenNumber(obj)
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
        end
        function CreateTokens(obj,Num)
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


            save([obj.remoteShareDir,'dos_command_',num2str(Num),'_info.mat'],'struct')
            disp('run on other machine')            
        end
        function info_filelist = GetInfoList(obj,EndStr)
            files = ImageIO('Path',obj.remoteShareDir,'ImageType',EndStr);
            files.RUN;
            info_filelist = files.names;
        end    
        function infoFileToBeExcute = GetInfoFileToBeExecuted(obj,info_filelist,track_filelist)
            x = size(info_filelist,1)
            infoFileToBeExcute = [];
            count = 1;
            for i = 1:x
                track = strrep(info_filelist{i},'info.mat','track.mat');
                n = find(strcmpi(track,track_filelist));
                if isempty(n)
                    infoFileToBeExcute{count,1} = info_filelist{i};
                    count = count + 1;
                end
            end
        end
        function applySettings(obj,infoFileToBeExcute)
            %% apply settings
            filename = [obj.remoteShareDir,infoFileToBeExcute];
            o_struct = load(filename);
            names = fieldnames(o_struct.struct);
            x = size(names,1);
            for i = 1:x
                obj.(names{i}) = o_struct.struct.(names{i});
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
            obj.currentComputerName = obj.getComputerName();
            obj.selectedComputerName = obj.currentComputerName;
            
            x = size(varargin,2);
			for i = 1:2:x
				obj.(varargin{i}) = varargin{i+1};
            end  
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
            starttime = now;
            obj.StartTime = datestr(starttime,'HH:MM:SS');
            drawnow;
            obj.Batch_Worker = createJob();
            obj.Batch_Job = createTask(obj.Batch_Worker,@system,0,{obj.CommandStr});
            obj.State = 'submitting job';
            drawnow;            
            submit(obj.Batch_Worker); 
            obj.State = 'Pending';
            

            
            %% monitor with timer
            obj.handles.timerObj = timer('TimerFcn',@(x,y)obj.UpdateState(starttime));
            set(obj.handles.timerObj,'ExecutionMode','fixedSpacing','Period',3);
            start(obj.handles.timerObj);
        end
        function UpdateState(varargin)
            %%
            disp('updating')
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
                %%
                
                disp('Listener updating track file')
                infoFileToBeExcute = strrep(obj.infoFileToBeExcute,'info.mat','track.mat');
                struct.State = obj.State;
                struct.LastStatusUpdate = obj.LastStatusUpdate;
                struct.Duration = obj.Duration;
                struct.FinishTime = obj.FinishTime; 
                struct.String = obj.String;
                save([obj.remoteShareDir,infoFileToBeExcute],'struct')
            end
        end
        function Listen2RemoteTask(obj,Num)
            %%
            
            filename2load = ['dos_command_',num2str(Num),'_track.mat'];
            track_filelist = obj.GetInfoList('track.mat');
            disp('Master reading track file')
            n = find(strcmpi(filename2load,track_filelist));
            if not(isempty(n))
                %%
                struct = load([obj.remoteShareDir,filename2load]);
                struct = struct.struct;
                obj.State               = struct.State;
                obj.LastStatusUpdate    = struct.LastStatusUpdate;
                obj.Duration            = struct.Duration;
                obj.FinishTime          = struct.FinishTime;  
                obj.String              = struct.String;
                
                if strcmpi(obj.State,'finished')
                    stop(obj.handles.timerObj);
                    delete(obj.handles.timerObj);
                end
            else
                obj.LastStatusUpdate = datestr(now,'HH:MM:SS');
            end
        end
    end
end