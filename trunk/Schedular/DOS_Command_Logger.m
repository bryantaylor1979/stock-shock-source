classdef DOS_Command_Logger < handle
    properties
        Log2CommandWindow = true
        ProgramName = 'Schedular';
		LogProgamName = true;
    end
    methods
        function Example(obj)
            %% Check connection to phone
            close all
            clear classes
            obj = DOS_Command_Logger;
            cd('Y:')
                
            %%
            obj.Dos_Command('URL_Download_Agent1.exe "Macro" "BritishBulls_ALLSTATUS" "AgentName" "Agent1"');
        end
        function [Error,String] = Dos_Command(obj,commandstr)
            %%
            if obj.Log2CommandWindow == true
				if obj.LogProgamName == true
					disp([obj.ProgramName,': ',commandstr]) 
				else
					disp(commandstr) 
				end
            end
            [Error,String] = system(commandstr);
            if not(isempty(String))
                disp(String)
            end
        end
    end
end