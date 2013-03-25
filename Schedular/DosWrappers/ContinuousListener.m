classdef ContinuousListener <   handle & ...
                                dynamicprops
    properties  (SetObservable = true)
        NumberOfWorkers = 4;
        Period = 3;
        ExecutionMode = 'fixedDelay';
        Dos_Shell
        TimeOfLastCheck
        TokenDrive = 'Y:\URL_Download\Swap\'
    end
    properties (Hidden = true)
        ExecutionMode_LUT = {   'singleShot'; ...
                                'fixedSpacing'; ...
                                'fixedDelay'; ...
                                'fixedRate'}
        handles
    end
    methods
        function Example(obj)
           %%
           close all
           clear classes
           
           %% delete all timers
           timers = timerfind
           x = size(timers,1);
           for i = 1:x
              delete(timers(i));
           end
           
           %%
           obj = ContinuousListener
           ObjectInspector(obj)

        end
        function Start(obj)
           %%
           obj.handles.timer.ExecutionMode = obj.ExecutionMode;
           obj.handles.timer.Period = obj.Period;
           
           start(obj.handles.timer)
        end
        function Stop(obj)
           stop(obj.handles.timer) 
        end
    end
    methods (Hidden = true)
        function obj = ContinuousListener()
            %%
            obj.TimeOfLastCheck = datestr(now,'HH:MM:SS');
            
            for i = 1:obj.NumberOfWorkers
                propName = ['DosShell_Worker',num2str(i)];
                addprop(obj,propName)
                obj.(propName) = DOS_Command_Logger( 'ControllerMode',   'Listener', ...
                                                    'remoteShareDir',   obj.TokenDrive, ...
                                                    'Mode',             'batch');
            end
                                            
            obj.handles.timer = timer(      'TimerFcn',         @obj.Update, ...
                                            'ExecutionMode',    obj.ExecutionMode, ...
                                            'Period',           obj.Period);
            obj.Start;
        end
        function varargout = Update(varargin)
            %%
            obj = varargin{1};
            obj.TimeOfLastCheck = datestr(now,'HH:MM:SS');
            
            workerNum = obj.findWorker();
            if not(workerNum == -1)
            workerName = ['DosShell_Worker',num2str(workerNum)];
            obj.(workerName).RUN;
            varargout = {1};
            end
        end
        function workerNum = findWorker(obj)
            %%
            workerNum = -1;
            for i = 1:obj.NumberOfWorkers
                propName = ['DosShell_Worker',num2str(i)];
                if strcmpi(obj.(propName).State,'ready') 
                    workerNum = i;
                    return
                end
                if strcmpi(obj.(propName).State,'finished') 
                    workerNum = i;
                    return
                end
            end
        end
        function delete(obj)
            delete(obj.handles.timer)
        end
    end
end