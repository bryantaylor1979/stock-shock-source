classdef WebQuery < handle
    properties   
    end
    methods
        function WriteWebQuery(obj,string)
            if obj.loglevel > 0
                disp(string)
            end
            fid = fopen([obj.InstallDir,'DL.iqy'], 'w');
            fprintf(fid, [ ...
                'WEB\n',...
                '1\n', ...
                string,'\n', ...
                '\n', ...
                'Selection=EntirePage\n', ...
                'Formatting=None\n', ...
                'PreFormattedTextToColumns=True\n', ...
                'ConsecutiveDelimitersAsOne=True\n', ...
                'SingleBlockTextImport=False\n', ...
                'DisableDateRecognition=False\n', ...
                'DisableRedirections=False']);
            fclose(fid);
        end
        function raw = ReadWebQuery(obj,string)
           time = 1;
           while time < obj.timeout
                try
                    obj.WriteWebQuery(string);
                    [~,~,raw] = xlsread([obj.InstallDir,'DL.iqy']);
                    break
                catch
                    disp('Connection problems')
                    pause(time);
                    time = time*2;
                end
           end
            if time >= obj.timeout
               raw = [];
               Error = -2;
               return
            end
        end
    end
end