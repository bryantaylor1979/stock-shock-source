classdef HeartBeatMonitor <    handle
    methods
       function HeartBeat(obj2,Type,ProgramName,Date)
            %%
            ProgramName = 'SharePrice_Summary';
            Date = today;
            
            %%
            name = obj2.getComputerName()
            filename = [obj2.ResultsDir,'Schedular\Track\',name,'_',strrep(datestr(Date),'-','_'),'.mat'];
            load(filename)
            %%
            struct.detial.(Type).(ProgramName).TimeOfLastPulse = now;
            save(filename,'struct')
         end
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
    end
end