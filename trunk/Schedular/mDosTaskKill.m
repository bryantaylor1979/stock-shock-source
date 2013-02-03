classdef mDosTaskKill     < 	handle & ...
								DOS_Command_Logger
	properties
        Termination = 'Force' %ForceParent, ForceParentAndChildren 
	end
    methods
        function Example(obj)
            %%
            close all
            clear classes
            obj = mDosTaskKill
            %%
            TerminationType = 'F';   %  F - forcefully terminate
                                     %  T - process and any child processes
            PID = 8928;
            obj.TaskKill_PID(PID,TerminationType);
            
            %%
            TerminationType = 'F';   %  F - forcefully terminate
                                     %  T - process and any child processes
            IM = 'Spotify.exe';
            obj.TaskKill_IM(IM,TerminationType);
        end
        function TaskKill_PID(obj, PID, TerminationType)
            %%
            CommandString = ['TASKKILL /PID ',num2str(PID)];
            
            if strcmpi(TerminationType,'F')
                CommandString = [CommandString,' /F'];
            elseif strcmpi(TerminationType,'T')
                CommandString = [CommandString,' /T'];
            else
            end 
                
            [Error,String] = obj.Dos_Command(CommandString);
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
                
            [Error,String] = obj.Dos_Command(CommandString);
        end
    end
    methods
        function TaskKillDosHelp(obj)
            %%
            dos('taskkill /?')
        end 
    end
end