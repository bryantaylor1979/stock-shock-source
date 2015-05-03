function Connect2yahoo(obj)
    if obj.AutoRetry == true
       Time = 2; 
    else
       Time = 1; 
    end
    Timeout = 40;
    while Time < Timeout
        try
            obj.conn = yahoo;
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
    else
        disp('Connection established') 
    end
end