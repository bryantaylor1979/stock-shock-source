classdef RealTimeAlerts
    properties
        LatestValue = [];
        Conn = [];
        Ticker = ['JJB.L'];
        Handles = [];
    end
    methods
        function [obj] = RealTimeAlerts(obj)
            try
            obj.Conn = yahoo;
            catch
            uiwait(msgbox('Could not connect to yahoo'))   
            end
        end
        function [Struct] = GetQuote(obj)
            Struct = fetch(obj.Conn,obj.Ticker,{'Symbol','Last','Date','Time','Change','Open','High','Low','Volume'});
        end
        function [obj] = CreateGUI;
            spacing = 30;
            length = 100;
            FontWeight = 'bold';
            Color = [1,1,1];
            obj.Handles.figure = figure;
            set(obj.Handles.figure,'Color',Color);
            uicontrol(obj.Handles.figure,'Style','text','String','Last','Position',[5,5+spacing*0,length,20],'HorizontalAlignment','left','FontWeight',FontWeight,'BackgroundColor',Color);
            uicontrol(obj.Handles.figure,'Style','text','String','Date','Position',[5,5+spacing*1,length,20],'HorizontalAlignment','left','FontWeight',FontWeight);
            uicontrol(obj.Handles.figure,'Style','text','String','Time','Position',[5,5+spacing*2,length,20],'HorizontalAlignment','left','FontWeight',FontWeight);
            uicontrol(obj.Handles.figure,'Style','text','String','Change','Position',[5,5+spacing*3,length,20],'HorizontalAlignment','left','FontWeight',FontWeight);
            uicontrol(obj.Handles.figure,'Style','text','String','Open','Position',[5,5+spacing*4,length,20],'HorizontalAlignment','left','FontWeight',FontWeight);
            uicontrol(obj.Handles.figure,'Style','text','String','High','Position',[5,5+spacing*5,length,20],'HorizontalAlignment','left','FontWeight',FontWeight);
            uicontrol(obj.Handles.figure,'Style','text','String','Low','Position',[5,5+spacing*6,length,20],'HorizontalAlignment','left','FontWeight',FontWeight);
            uicontrol(obj.Handles.figure,'Style','text','String','Volume','Position',[5,5+spacing*7,length,20],'HorizontalAlignment','left','FontWeight',FontWeight);
        end
    end
end