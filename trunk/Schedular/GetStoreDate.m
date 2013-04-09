classdef GetStoreDate < handle
    properties (SetObservable = true)
        TodayDateNum
        StockExchangeOpeningTime = '08:00'; %uk only
        TodaysDate
        StoreDate
        StoreDateNum
    end
    methods
        function Example(obj)
            %%
            close all
            clear classes
            
            %%
            obj = GetStoreDate;  
            ObjectInspector(obj)
            
            %%
            obj.TodayDateNum = floor(now)
            obj.RUN();            
        end
        function RUN(obj)
            Date = obj.TodayDateNum;
            obj.TodaysDate = datestr(Date);
            Threshold = obj.StockExchangeOpeningTime;
            if Date == floor(now) %if today then find time.
                time = now;
                time = rem(time,1);
                ThresholdDateNum = rem(datenum(Threshold),1);
                if time < ThresholdDateNum;
                    Date = Date - 1;
                end
            end
            obj.StoreDate = datestr(Date);
            obj.StoreDateNum = Date;
        end 
    end
    methods (Hidden = true)
        function obj = GetStoreDate()      
        end
    end
end