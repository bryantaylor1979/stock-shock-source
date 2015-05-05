classdef volumeplot < handle
    properties (SetObservable = true)
        EdgeColor = [1,1,1]
        FaceColor = [0,0,0.3]
        Position = [];
        Volume = [];
        Date = [];
        volume_ax = [];
    end
    methods (Hidden = true)
        function Example()
            %% Init
            close all
            clear classes
            ARRAY = fetch(yahoo,'HAWK.L',{'volume'},today-31*3,today,'d');
            Date = ARRAY(:,1);
            Volume = ARRAY(:,2);
            obj = volumeplot(Date,Volume);
%             obj.Position = [0.094,0.125,0.862,0.135];
            
            %%
            ARRAY = fetch(yahoo,'BARC.L',{'volume'},today-31*3,today,'d');
            Date = ARRAY(:,1);
            Volume = ARRAY(:,2);
            obj.Volume = Volume; 
            obj.Date = Date;
            
            %%
            close all
            clear classes
            ARRAY = fetch(yahoo,'HAWK.L',{'volume'},today-31*3,today,'d');
            Date = ARRAY(:,1);
            Volume = ARRAY(:,2);
            volume_ax = subplot(2,1,2);
            obj = volumeplot(Date,Volume,'volume_ax',volume_ax);
            
        end
        function obj = volumeplot(varargin)
            Date = varargin{1};
            Volume = varargin{2};
            
            % variable arg in
            varargin = varargin(3:end);
            [x] = size(varargin,2);
            for i = 1:2:x
                obj.(varargin{i}) = varargin{i+1};
            end            
            
            if not(isempty(obj.volume_ax))
               axes(obj.volume_ax) 
            end
            handle.volume_data = bar(Date, Volume, ...
                                'EdgeColor',    obj.EdgeColor, ...
                                'FaceColor',    obj.FaceColor);
            handle.volume_ax = gca;
            datetick;
            grid on
            set(handle.volume_ax,'XLim',      [min(Date)-5,max(Date)+5]);

            xlabel('Date','FontWeight','bold');
            ylabel('Volume','FontWeight','bold');
            
            
            if isempty(obj.Position)
                obj.Position = get(handle.volume_ax,'Position');
            end
            obj.Volume = Volume; 
            obj.Date = Date;
            
            addlistener(obj,'Position','PostSet', @(x,y)obj.PositionUpdate(handle.volume_ax));
            addlistener(obj,{'Volume','Date'},'PostSet', @(x,y)obj.Update(handle.volume_data,handle.volume_ax));
        end
        function PositionUpdate(varargin)
            %%
            obj = varargin{1};
            handle = varargin{2};
            set(handle,'Position',obj.Position);
        end
        function Update(obj,handle,AXES)
            %%
            set(handle,'YData',obj.Volume);
            set(handle,'XData',obj.Date);
            set(AXES,'XLim', [min(obj.Date)-5,max(obj.Date)+5]);
            axes(AXES)
            datetick;
            set(AXES,'XLim', [min(obj.Date)-5,max(obj.Date)+5]);
        end
    end
end