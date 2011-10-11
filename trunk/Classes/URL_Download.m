classdef URL_Download < handle
    properties
        sURL
        eURL
        timeout = 200;
        t1 = 5000;  
    end
    methods (Hidden = false)
        function SaveALLURL(obj,Symbols,ProgramName,ResultName,Date)
            %
            disp(['Executed: ',datestr(now)])

            %% Load Objects
            %Verfied - The symbols 
            [x] = size(Symbols,1)
            tic
            for j = 1:x
                  waitbar(j/x,obj.handles.figure,['Processing... ',num2str(j),' of ',num2str(x),' (',num2str(round(j/x*100)),'%)'])
                  drawnow;

                  Symbol = strrep(Symbols{j},'.L','');

                  obj.SaveURL(Symbol,ProgramName,ResultName,Date);
            end
            waitbar(i/x,    obj.handles.figure, obj.CalculateTime(toc));
        end
        function Symbols = GetURL_Symbols(obj,Program,Macro,Date)
            CD = pwd;
            FileName = [obj.ResultsDir,Program,'\Results\',Macro,'\URL\',datestr(Date)];
            try
                cd(FileName);
            catch
                FileName
               error('Folder does not exist, are you sure that the URL has been downloaded for this day?') 
            end
            names = struct2cell(dir);
            Symbols = rot90(strrep(names(1,:,:),'.mat',''));
            Symbols = Symbols(1:end-2);
            cd(CD);           
        end
        function [s, Error] = LoadURLs(obj,Program,Macro,Symbol,date)
            PWD = pwd;
            Path = [obj.ResultsDir,Program,'\Results\',Macro,'\URL\',datestr(date),'\'];
            Filename = [Path,Symbol,'.mat']
            try
                load(Filename);
                Error = 0;
            catch
                s = [];
                Error = -1;   
            end
            cd(PWD) 
        end
        function DateNum = GetLastDateOfURL(obj,Program,Macro,DateNum)
            FileName = [obj.ResultsDir,Program,'\Results\',Macro,'\URL\']
            CD = pwd;
            cd(FileName);
            names = struct2cell(dir);
            Name = rot90(strrep(names(1,:,:),'.mat',''));
            
            DateNums = datenum(Name(1:end-2));
            n = find(DateNums <= DateNum);
            DateNums = DateNums(n);
            
            DateNum = max(DateNums);
            cd(CD);
        end 
    end
    methods (Hidden = true)
        function [s,Error] = SaveURL(obj,Symbol,ProgramName,ResultName,Date)
            %%
            %Error codes:
            %   0 : Successfull.
            %  -1 : No Data On web page.
            Error = 0;
            time = 1;
            while time < obj.timeout
                try
                    s = urlread2([obj.sURL,Symbol,obj.eURL],[],[],obj.t1);
                    break
                catch
                    disp(['Connection problems, Wait: ',num2str(time)])
                    pause(time);
                    time = time*2;
                end
            end
            if obj.timeout < time
               return 
               s = [];
               Error = -2;
            end
            %%
            PWD = pwd;
            Path = [obj.ResultsDir,ProgramName,'\Results\',ResultName,'\URL\',strrep(datestr(Date),'-','_'),'\'];
            try
                cd(Path);
            catch
                mkdir(Path);
                cd(Path);
            end
            Filename = [Path,Symbol,'.mat'];
            save(Filename,'s');
            cd(PWD);
        end
        function TimeStr = CalculateTime(obj,Seconds)
            secs = round(Seconds);
            minutes = floor(secs/60);
            hours = floor(minutes/60);
            min = minutes - hours*60;
            secs = secs - minutes*60;
            TimeStr = [num2str(hours),'h ',num2str(min),'m ',num2str(secs),'s'];
        end  
    end
end