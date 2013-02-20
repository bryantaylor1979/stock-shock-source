classdef mDosTaskKill     < 	handle 
	properties (SetObservable = true)
        mode = 'PID'    %PID or IM
        PID = 8928;
        IM = 'Spotify.exe';
        Termination = 'ForceParent' %End, ForceParent, ForceParentAndChildren 
        DosShell
    end
    properties (Hidden = true)
        Termination_LUT = { 'ForceParent'; ...
                            'End'; ...
                            'ForceParentAndChildren'}
        handles
    end
    methods
        function Example(obj)
            %%
            close all
            clear classes
            obj = mDosTaskKill('PID',0);
            ObjectInspector(obj)            
            
            %%
            obj.Termination = 'End'; %ForceParent, End
            obj.mode = 'PID';
            obj.RUN
            
            %%
            obj.mode = 'IM';
            obj.RUN
        end
        function RUN(obj)
            switch lower(obj.Termination)
                case 'forceparent'
                	TerminationType = 'F';   %  F - forcefully terminate
                case 'forceparentandchildren'
                    TerminationType = 'T';   %  T - process and any child processes
                case 'end'
                    TerminationType = '';
                otherwise
                    error('mode not recognised')
            end
            
            if strcmpi(obj.mode,'PID')
                obj.TaskKill_PID(obj.PID,TerminationType);
            elseif strcmpi(obj.mode,'IM')
                obj.TaskKill_IM(obj.IM,TerminationType);
            else
                error('mode not recognised')
            end
        end
    end
    methods (Hidden = true)
        function obj = mDosTaskKill(varargin)
            %%
            x = size(varargin,2);
            for i = 1:2:x
                obj.(varargin{i}) = varargin{i+1};
            end
            obj.DosShell = DOS_Command_Logger(  'ProgramName','mDosTaskKill', ...
                                                'Mode','system');
        end
        function TaskKill_PID(obj, PID, TerminationType)
            %%
            CommandString = ['TASKKILL /PID ',num2str(PID)];
            
            if strcmpi(TerminationType,'F')
                CommandString = [CommandString,' /F'];
            elseif strcmpi(TerminationType,'T')
                CommandString = [CommandString,' /T'];
            else
                CommandString = [CommandString];
            end 
            obj.DosShell.CommandStr = CommandString;
            obj.DosShell.RUN();
        end
        function TaskKill_IM(obj, IM, TerminationType)
            %%
            CommandString = ['TASKKILL /IM ',IM];
            
            if strcmpi(TerminationType,'F')
                CommandString = [CommandString,' /F'];
            elseif strcmpi(TerminationType,'T')
                CommandString = [CommandString,' /T'];
            else
            end 
            obj.DosShell.CommandStr = CommandString;
            obj.DosShell.RUN();
        end
        function TaskKillDosHelp(obj)
            %%
            obj.DosShell.Dos_Command('taskkill /?')
        end 
    end
end