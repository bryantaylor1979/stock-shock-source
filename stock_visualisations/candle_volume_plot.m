classdef candle_volume_plot < handle
    properties (SetObservable = true)
        GroupParamaterHold = false;
        Date
        High
        Low
        Open
        Close
        Volume
    end
    methods
        function obj = candle_volume_plot(Date, High, Low, Open, Close, Volume)
            handle.candle_ax = subplot(2,1,1);
            handle.volume_ax = subplot(2,1,2);
            set(handle.candle_ax,   'Position',   [0.094,0.268,0.862,0.6]);
            set(handle.volume_ax,   'Position',   [0.094,0.125,0.862,0.135]);
            
            candleplot(Date, High, Low, Open, Close, 'handle', handle);
            set(handle.candle_ax,   'XTickLabel', []);
            handle.volumeplot = volumeplot(Date, Volume, 'volume_ax', handle.volume_ax);
            
            obj.Date = Date; obj.High = High; obj.Low = Low; 
            obj.Open = Open; obj.Close = Close; obj.Volume = Volume;
            listerner_handle = addlistener(obj,    {'Date','High','Low','Open','Close','Volume'}, ...
                                                    'PostSet', @(x,y)obj.Update(handle)); 
                                                
            addlistener(obj,    'GroupParamaterHold', ...
                                'PostSet', @(x,y)obj.GroupParamaterHoldUpdate(listerner_handle));
        end
        function Example()
            %% Init
            close all
            clear classes
            ARRAY = fetch(yahoo,'HAWK.L',{'high','low','open','close','volume'},today-31*3,today,'d');
            Date = ARRAY(:,1);
            High = ARRAY(:,2);
            Low = ARRAY(:,3);
            Open = ARRAY(:,4);
            Close = ARRAY(:,5);
            Volume = ARRAY(:,6);
            h = candle_volume_plot(Date,High,Low,Open,Close,Volume);

            %% Update
            ARRAY = fetch(yahoo,'BARC.L',{'high','low','open','close','volume'},today-31*3,today,'d');
            h.GroupParamaterHold = true;
            h.Date = ARRAY(:,1);
            h.High = ARRAY(:,2);
            h.Low = ARRAY(:,3);
            h.Open = ARRAY(:,4);
            h.Close = ARRAY(:,5);
            h.GroupParamaterHold = false;
            h.Volume = ARRAY(:,6);  
        end
        function Update(obj,handle)
            candleplot(obj.Date,obj.High,obj.Low,obj.Open,obj.Close,'handle',handle);
            handle.volumeplot.Volume = obj.Volume;
            handle.volumeplot.Date = obj.Date;
        end
        function GroupParamaterHoldUpdate(obj,listerner_handle)
            if obj.GroupParamaterHold == true
                listerner_handle.Enabled = false;
            else
                listerner_handle.Enabled = true;
            end
        end
    end
end