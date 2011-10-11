classdef III_HoldingsQuote
    properties
        Ticker = 'EMG.L';
        Quantity = 212;
        AvgPricePerShare = 235.5896;
        LastPrice = [];
        Change = [];
        BookingCost = [];
        Valuation = [];
        ProfitLossPounds = [];
        ProfitLossPercentage = [];
        Conn = [];
        Data = [];
        Symbols = [];
        handles = [];
        Visible = 'on';
        ErrorCode = 1;
        TickerPeriod = 120;
        TimerObj = [];
        TimerState = 'Stopped';
        Holdings   = {  ...
                        'NSAM.L',36089,2.6377; ...
                        'JJB.L', 12402, 12.3881};
    end
    methods (Hidden = false)
        function [obj] = TimerStart(obj)
           start(obj.TimerObj);
           obj.TimerState = 'Started';
        end
        function [obj] = TimerStop(obj)
           stop(obj.TimerObj); 
           obj.TimerState = 'Stopped';
        end
        function [obj] = UpdateGUI(obj)
            set(obj.handles.figure,'Visible',obj.Visible);
        end
        function [obj] = III_HoldingsQuote(obj)
            disp('Is this executed every time?')
            try
            obj.Conn = yahoo;
            catch
            uiwait(msgbox({'Could not connect to yahoo';'Please check connection'}))
            clear
            return
            end
            [obj] = obj.CreateGUI();
            t = timer(  'TimerFcn',         {@obj.UpdateTable}, ...
                        'ExecutionMode',    'fixedRate', ...
                        'Period',           obj.TickerPeriod ...
                        );
            start(t)
            obj.TimerObj = t;
            obj = obj.IntTable();
        end
        function [obj] = UserInputs(obj)
            prompt={'Enter the ticker symbol:','Enter the price you paid for the stock:','Enter Quantity'};
            name='Inputs Parameters';
            numlines=1;
            defaultanswer={obj.Ticker,num2str(obj.AvgPricePerShare),num2str(obj.Quantity)};
 
            answer=inputdlg(prompt,name,numlines,defaultanswer);
            obj.Ticker = answer{1};
            obj.AvgPricePerShare = str2double(answer{2});
            obj.Quantity = str2double(answer{3});
            drawnow;
        end
        function [obj] = GetQuote(obj)
            try
                LastPrice = fetch(obj.Conn,obj.Ticker,'Last');
            catch 
                obj.ErrorCode = -1;
                return
            end
            obj.LastPrice =  LastPrice.Last;
            obj.Change = (obj.LastPrice-obj.AvgPricePerShare)*100;
            obj.BookingCost = obj.Quantity*obj.AvgPricePerShare/100;
            obj.Valuation = obj.Quantity*obj.LastPrice/100;
            obj.ProfitLossPounds = obj.Valuation - obj.BookingCost;
            obj.ProfitLossPercentage = round(obj.ProfitLossPounds/obj.BookingCost*10000)/100;
            drawnow;
        end
        function [obj] = AddQuote(obj)
            %Data
            if obj.ErrorCode == -1
               return 
            end
            Data = obj.Data;
            NewData = {num2str(obj.Quantity,5),num2str(obj.AvgPricePerShare ,5),num2str(obj.LastPrice ,5),num2str(obj.Change ,5),num2str(obj.BookingCost,5),num2str(obj.Valuation,5),num2str(obj.ProfitLossPounds,3),num2str(obj.ProfitLossPercentage,5)};

            %Update symbol set
            [x] = size(NewData,1);
            Symbols = obj.Symbols;
            if strcmpi(Symbols,'numbered')
            Symbols = {obj.Ticker};   
            else
            Symbols = [Symbols;{obj.Ticker}];
            end
            Data = [Data;NewData];
            obj.Data = Data;
            obj.Symbols = Symbols;
            
            %Total Info
            Valuation = sum(str2double(Data(:,6)));
            Profit = sum(str2double(Data(:,7)));
            PercentageProfit = Profit/Valuation*100;
            Data = [Data;{'','','','','Total',['£',num2str(Valuation,5)],['£',num2str(Profit,5)],[num2str(PercentageProfit,5),'%']}];
            
            Symbols = [Symbols;{''}];
            set(obj.handles.uitable, 'Data',   Data, ... 
                                     'RowName',Symbols);
            
            set(obj.handles.Status,'String',['Valuation as at ',datestr(now,15),' on ',datestr(now,20)]);
        end
        function [obj] = UpdateQuote(obj,ID)
            if obj.ErrorCode == -1
               return 
            end
            Data = obj.Data;
            NewData = {num2str(obj.Quantity,5),num2str(obj.AvgPricePerShare ,5),num2str(obj.LastPrice ,5),num2str(obj.Change ,5),num2str(obj.BookingCost,5),num2str(obj.Valuation,5),num2str(obj.ProfitLossPounds,3),num2str(obj.ProfitLossPercentage,5)};
            if isempty(Data)
                Data = NewData;
            else
                Data(ID,:) = NewData;
            end
            obj.Data = Data;
            %Total Info
            Valuation = sum(str2double(Data(:,6)));
            Profit = sum(str2double(Data(:,7)));
            PercentageProfit = Profit/Valuation*100;
            Data = [Data;{'','','','','Total',['£',num2str(Valuation,5)],['£',num2str(Profit,5)],[num2str(PercentageProfit,5),'%']}];
            set(obj.handles.uitable, 'Data', Data); 
            set(obj.handles.Status,'String',['Valuation as at ',datestr(now,15),' on ',datestr(now,20)]);
        end
        function [obj] = Toolbars(obj)
            handles.toolbar = uitoolbar(h1);
            ToolboxCallback = {'ToolboxCallback',handles};

            [RGB,k] = imread('new_ico.bmp');
            RGB = ind2rgb(RGB,k);
            RGB = imresize(RGB,[16 16],'nearest');
            handles.New = uipushtool(handles.toolbar, ...
                                  'CData',RGB, ... 
                                  'TooltipString','New', ...
                                  'tag','New', ...
                                  'ClickedCallback',[ToolboxCallback,{'New'}]);
        end
    end
    methods (Hidden = true)
        function [obj] = CreateGUI(obj)
            handles.figure = figure;
            height = 90;
            width = 700;
            TopGap = 20;
            
            Position = get(handles.figure,'Position');
            Position(3) = width;
            Position(4) = height+TopGap;
            set(handles.figure, 'Position',Position, ...
                                'MenuBar','none', ...
                                'Visible',obj.Visible, ...
                                'Name','Real-Time Stock Monitor', ...
                                'NumberTitle','off', ...
                                'Color',[0.8,0.8,0.8]);
            handles.uitable = uitable();
            textcolor = 0.5;
            set(handles.uitable,'Position',[1,1,width,height], ...
                                'ColumnName',{'Quantity','Avg Price Per Share (p) *','Latest Price (p) **','Change(p)','Booking Cost (£)','Valuation (£)','Profit/Loss (£)','Profit/Loss (%)'}, ...
                                'BackgroundColor',[1,1,1], ...
                                'FontWeight','bold', ...
                                'ForegroundColor',[textcolor,textcolor,textcolor], ...
                                'ColumnWidth','auto');
                            
            handles.Status = uicontrol(handles.figure,    'String','Text', ...
                                                    'Style','text', ...
                                                    'HorizontalAlignment','left', ...
                                                    'FontWeight','bold', ...
                                                    'Position',[10,height+3,300,15]);
            
            obj.handles = handles;
            drawnow; 
        end
        function [obj] = IntTable(obj)
            % Add Quote
            Inputs = obj.Holdings;
            [x] = size(Inputs,1);
            for i = 1:x
            obj.Ticker = Inputs{i,1};
            obj.Quantity = Inputs{i,2};
            obj.AvgPricePerShare = Inputs{i,3};
            obj = obj.GetQuote;
            obj = obj.AddQuote;
            end
            obj = obj.UpdateGUI;
        end
        function [obj] = UpdateTable(obj,dummy,dummy1)
            persistent timerun
            if isempty(timerun)
                timerun = 1;
                return
            else
                disp('Updating')
                Inputs = obj.Holdings;
                [x] = size(Inputs,1);
                for i = 1:x
                obj.Ticker = Inputs{i,1};
                obj.Quantity = Inputs{i,2};
                obj.AvgPricePerShare = Inputs{i,3};
                obj = obj.GetQuote;
                obj = obj.UpdateQuote(i);
                end
            end
        end
    end
end
        