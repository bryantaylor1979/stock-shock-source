classdef CheckConnection
    properties
        UpdateRate = 1;
    end
    methods
        function [obj] = CheckConnection
            h = msgbox(['Error Count: 0']);
            Children = get(h,'Children');
            handle = get(Children(1),'Children');
            progress = '|/-\';

            count = 0;
            prog_count = 0;
            while true
                prog_count = prog_count + 1;
                try
                    Status = true;
                    [s] = urlread('http://www.google.co.uk');
                    set(handle,'String',['Error Count: ',num2str(count),' ',progress(rem(prog_count,4)+1)]);
                catch
                    Status = false;
                end
                if Status == false
                    count = count + 1;
                    set(handle,'String',['Error Count: ',num2str(count),' ',progress(rem(prog_count,4)+1)]);
                end
                pause(obj.UpdateRate)
            end
        end
        function [Connection] = CheckConnection2(obj)
            Time = 1;
            Timeout = 20;
            Connection = true;
            while Time < Timeout
                try
                    [s] = urlread('www.google.co.uk');
                    break
                catch
                    if Time == 1
                       ButtonName = questdlg(   'Do you want to retry or work offline?', ...
                                                'Connection Failed', ...
                                                'Retry', 'Offline', 'Retry'); 
                       switch ButtonName
                           case 'Retry'
                               %Do nothing
                           case 'Offline'
                               break %Break out while loop
                           otherwise
                       end
                    end
                    PauseTime = 5*2^Time;
                    disp(['Connection failed. Wait ',num2str(PauseTime),' secs'])
                    pause(PauseTime);
                    Time = Time + 1;
                end
            end
            if Time == Timeout
                msgbox('Could not connect to yahoo. Check connection') 
                Connection = false;
            else
                disp('Connection established') 
            end
        
        end
    end
end