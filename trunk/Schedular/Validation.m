classdef Validation <   URL_Download & ...
                        handle
    methods
        function [Table,NoOfTasksRunning] = ViewDayTrack(obj,Date,Name,Type)
           %%
           try
               cd('P:\StockData [MEDIAPC]\StockData [MEDIAPC]\')
               ResultsDir = 'P:\StockData [MEDIAPC]\StockData [MEDIAPC]\';
           catch
               ResultsDir = 'P:\StockData [MEDIAPC]\';
           end
            
            
           String = [ResultsDir,'Schedular\Track\',Name,'_',strrep(datestr(Date),'-','_'),'.mat'];
           struct = load(String);
           struct = struct.struct
           
           Macros = fieldnames(struct.detial.(Type));
           for i = 1:max(size(Macros))
                Val = struct.detial.(Type).(Macros{i})
                Array{i,1} = Macros{i};
                Array{i,2} = Val.Time;
                Array{i,3} = Val.Started;
                Array{i,4} = Val.Complete;
                try
                Array{i,5} = Val.StartTime;
                catch
                Array{i,5} = 'N/A';    
                end
                try
                Array{i,6} = Val.EndTime;
                catch
                Array{i,6} = 'N/A';    
                end
           end
           Heading = {'Macros','Time','Started','Complete','StartTime','EndTime'};
           Table = [Heading;Array];
           NoOfTasksRunning = 0;
        end
    end
end