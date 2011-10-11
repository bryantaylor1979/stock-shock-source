classdef TradeGuide
    properties
       SaveDataPath = 'C:\SourceSafe\Matlab\Stocks & Shares\Programs\Trade Guide\SaveData';
       InstallDir = 'C:\SourceSafe\Matlab\Stocks & Shares\Programs\Trade Guide\';
       handles = [];
       functions = {   ...
                'CreateDatabase'; ...
                'ImportInstruments'; ...
                'VerfiyYahoo'; ...
                'Download_Mat'; ...
                'DistributedComputing_Download_Mat'; ...
                'CalculateValues'; ...
                'DateRange_Mat'; ...
                'PennyStocks'; ...
                'NoOfSymbolsPerDay_Mat'; ...
                'DatabaseViewer_Mat'; ...
                'CalculateParameters_Mat'; ...
                'ValidDateRange';...
                'DayBestInvestments_Mat'; ...
                'HistoricalDayBestInvestments_Mat'; ...
                'Buy_Sell_Sequence'; ...
                'CalculateProfit'; ...
                'Descion';...
                'DescionPlus'; ...
                'CalculateStake'; ...
                 };
        DataObj = [];
        AutoTradeTimerObj = [];
        TradeGuideStartTime = ['23:14:00'];
        NoDownloadAttempts = 2;
    end
    methods (Hidden = false)
        function [obj] = TradeGuide(obj)
            %% 
            obj = obj.CreateGUI();       
            set(obj.handles.StatusInfo,'String','Ready');
            obj.DataObj = LocalDatabase;
            obj.DataObj.Location = obj.SaveDataPath;
            
            TradeGuideStartTimeNum = rem(datenum(obj.TradeGuideStartTime),1);
            
            Timetoendofday_sec = (TradeGuideStartTimeNum - rem(now,1))*24*60*60;
            if Timetoendofday_sec < 0
                Timetoendofday_sec = Timetoendofday_sec + 60*60*24;
            end
            obj.AutoTradeTimerObj = timer('TimerFcn',@obj.AutoTrade, 'Period',60*60*24,'ExecutionMode','fixedRate','StartDelay',Timetoendofday_sec);
            stop(obj.AutoTradeTimerObj);

            %% Set Callbacks
            set(obj.handles.menu.openproject,'Callback',{@obj.OpenProject,obj.handles});
            set(obj.handles.toolbar.Analysis,'ClickedCallback',{@obj.ToolboxCallback})
            set(obj.handles.toolbar.Stop,'ClickedCallback',{@obj.ToolboxCallback})
            set(obj.handles.toolbar.Report,'ClickedCallback',@obj.Report);
            set(obj.handles.toolbar.AutoTrade,'ClickedCallback',{@obj.AutoTradeWrapper,obj.handles});
            set(obj.handles.menu.loadtable,'Callback',@obj.LoadTable);
            set(obj.handles.menu.MacroDownloadData,'Callback',@obj.MacroDownloadData);
            set(obj.handles.toolbar.ConfigMode,'ClickedCallback',{@CalculationSelection,obj.handles}); %TODO make calculate selection into an API
            set(obj.handles.figure,'ResizeFcn',@obj.ResizeFcn);
            set(obj.handles.Stage.pulldown,'Callback',{@obj.SelectStage});
            set(obj.handles.DatabaseSelection.pulldown,'Callback',{@obj.SelectStage,obj.handles.figure,obj.InstallDir});
            set(obj.handles.DatabaseViewer.pulldown,'Callback',{@obj.DataViewerUpdate});
            set(obj.handles.toolbar.Stop,'State','off');   
        end 
        function SelectStage(varargin)
            obj = varargin{1};
            %% Database Name
            String = get(obj.handles.DatabaseSelection.pulldown,'String');
            Value = get(obj.handles.DatabaseSelection.pulldown,'Value');
            DatabaseName = String{Value};
            path = [obj.InstallDir,DatabaseName];

            %% Get Current Stage Name
            String = get(obj.handles.Stage.pulldown,'String');
            Value = get(obj.handles.Stage.pulldown,'Value');
            Selection = String{Value};

            %% Change headings on table
            
            ModeObj = feval(Selection);
            Names = ModeObj.ColumnNames;
            obj.IntialiseTable(Names);

            if strcmpi(Selection,'DatabaseViewer_Mat')
                set(obj.handles.DatabaseViewer.pulldown,'Enable','on');
                set(obj.handles.DatabaseViewer.text,'Enable','on');
                
                
                set(obj.handles.toolbar.ConfigMode,'Enable','off');
                ModeObj.TradeGuideHandle = obj;
                ModeObj.Process;

                DataObj = LocalDatabase;
                DataObj = DataObj.GetDownloadedSymbolList;
                DataObj.Symbol = DataObj.SymbolsList{1};
                DataObj = DataObj.LoadData;
                
                set(obj.handles.table,'ColumnName',DataObj.DataStoreColumnNames );
                set(obj.handles.table,'Data',DataObj.DataStore);
                
                set(obj.handles.DatabaseViewer.pulldown,'String',DataObj.SymbolsList);
            else
                set(obj.handles.DatabaseViewer.pulldown,'Enable','off');
                set(obj.handles.DatabaseViewer.text,'Enable','off');
                
                %% Config Setup
                ConfigPreset = ModeObj.Config;
                if ConfigPreset == false
                    set(obj.handles.toolbar.ConfigMode,'Enable','off');
                else
                    set(obj.handles.toolbar.ConfigMode,'Enable','on');
                end

                %% Update Data of table
                try
                [tabledata] = obj.FindLatest(path,Selection);
                if iscell(tabledata)
                    set(obj.handles.table,'Data',tabledata);
                else
                    set(obj.handles.table,'Data',[]);
                end
                end
            end
        end
        function OpenProject(obj,events,h)
            %Written by: Bryan Taylor
            %Date Created: 5th January 2008

            global savecriteria 

            path = h.path.savedata
            cd([path]);
            [filename, pathname] = uigetfile( ...
                   {'*.mat';'*.*'}, ...
                    'Open Project');

            if filename == 0 %user didn't select a file
               set(h.Status,'String','Ready');
               drawnow;
               return 
            end

            set(h.Status,'String','Opening Document, Please Wait...')
            drawnow;

            load([pathname,filename])
            set(h.Stage.pulldown,'Value',savecriteria.stage)
            Stage = savecriteria.stage

            set(h.figure,'Name',['Trade Guide - ',filename]);
            drawnow;

            % String = get(h.DatabaseSelection.pulldown,'String')
            % Value =  get(h.DatabaseSelection.pulldown,'Value')
            % Database = String{Value};

            % path = [path,Database]
            StageUpdateTable(1,h,path)

            set(h.Status,'String','Ready');
            drawnow;
        end
        function SaveProjectAs()
            %SaveProjectAs - Save all data in project.
            %Date Created:      4th January 2007
            %Written by:        Bryan Taylor

            mode = 'old';
            global h savecriteria status currentdirectory
            set(h.Status,'String','Saving Document, Please Wait...');

            if strcmpi(mode,'old')
                savecriteria.stage = get(h.Stage.pulldown,'Value');
                savecriteria.status = status;
                try
                status = savecriteria.status;
                end
            else

            end

            cd([currentdirectory,'\SaveData\']);

            [filename, pathname] = uiputfile( ...
                   {'*.mat';}, ...
                    'Save Project As');

            set(h.figure,'Name',['Trade Guide - ',filename]);    
            save([pathname,filename],'savecriteria')
            set(h.Status,'String','Ready');
        end
        function AutoTradeWrapper(varargin); 
            obj = varargin{1};
            State = get(obj.handles.toolbar.AutoTrade,'State');
            switch State
                case 'on'
                    start(obj.AutoTradeTimerObj);
                case 'off'
                    stop(obj.AutoTradeTimerObj);
                otherwise                
            end
        end
        function AutoTrade(varargin)
            %
            %Written by:    Bryan Taylor
            %Date Created:  22nd April 2008
            %Date Modified: 22nd April 2008
            obj = varargin{1};

%             answer = obj.UserRequestDownloadNo;
            answer = obj.NoDownloadAttempts;
            obj.SetStage('Download_Mat');
            
            Inputs = {  'Download_Mat',1,0; ...
                        'CalculateValues',0,0};

            %% Download
            
            Path = [obj.InstallDir,'\SaveData\AutoTrade\',num2str(today),'\'];
            try
                mkdir(Path)    
            end
            
            [x] = size(Inputs,1)
            for i = 1:x
                for j = 1:Inputs{i,2}
                tic
                clear DownLoadObj
                DownLoadObj = feval(Inputs{i,1});
                obj.SetStage(Inputs{i,1});
                Names = DownLoadObj.ColumnNames;
                DownLoadObj.TradeGuideHandle = obj;
                obj.IntialiseTable(Names);
                DownLoadObj.Location = [obj.SaveDataPath,'\'];
                DownLoadObj.Process;
                Data = get(obj.handles.table,'Data');
                save([Path,Inputs{i,1},strrep(num2str(now),'.','_')],'Data');
                Time = toc;
                Inputs{i,3} = datestr(Time,13);
                end
            end
            
            obj.IntialiseTable({'Module';'No Interations';'Time Taken'});
            set(obj.handles.table,'Data',Inputs);
            
            plot = false;
            if plot == true
            NoUpToDate(1) = size(find(strcmpi(Data(:,6),'UpToDate')),1); %accumulate
            save([Path,'Download_Mat',strrep(num2str(now),'.','_')],'Data');
            h1 = figure;
            plot(NoUpToDate);
            title('Number Of Symbols UpToDate');
            xlabel('Session');
            ylabel('No Of Symbols');
            set(h1,'NumberTitle','off');
            set(h1,'Name','Number UpToDate');
            end
            
            %% plot
            if plot == true
            h1 = figure;
            pie([DownloadTime,CalculateParameters],{'DownloadTime','CalculateParameters'});
            Total = sum([DownloadTime,CalculateParameters]);

            Mins = floor(Total/60);
            Hours = floor(Mins/60); %complete
            Minutes = Mins - Hours*60; %complete
            Seconds = Total - Minutes*60 - Hours*60*60;

            String = {  ['Total Elapsed Time: ',num2str(Hours,2),'h ',num2str(Minutes,2),'m ',num2str(Seconds,2),'s']; ...
                        ['Time Finished: ',datestr(now,13)]; ...
                     };
            title(String)
            saveas(h1,[Path,'ComputationTimePieChart.fig']);
            end
        end
        function LoadTable(varargin)
            %
            %Written by:    Bryan Taylor
            %Date Created:  2nd July 2008
            h = varargin{1};

            cd([h.InstallDir,'\SaveData\AutoTrade\Download_Mat\'])
            [filename, pathname, filterindex] = uigetfile( ...
                   {'*.mat','MAT-files (*.mat)'}, ...
                    'Pick a file', ...
                    'MultiSelect', 'off');
            load([pathname,filename])

            obj = Download_Mat;
            Names = obj.ColumnNames;
            h.IntialiseTable(Names);
            set(h.handles.table,'Data',tabledata);

            % Set Mode
            h.SetStage('Download_Mat');
        end
        function AddRow(RowInfo)
            % Add row to table

            Vs = version;
            global h 

            if not(strcmpi(Vs,'7.0.0.19920 (R14)'));
                Data = get(h.table,'Data');
                Data = [Data;RowInfo];
                set(h.table,'Data',Data);
                drawnow;
            else
                % Add row to table
                JavaObject = get(h.table,'Data');
                Table = get(h.table,'Table');
                RowCount = get(Table,'RowCount');
                String = JavaObject(RowCount,1);

                if not(strcmp(String,''))
                    [x] = size(JavaObject,1);
                    JavaObject(2:x+1,:) = JavaObject(:,:);
                end

                [x] = size(RowInfo,2);
                for i = 1:x
                    if ischar(RowInfo{i})     
                    else
                        RowInfo{i} = num2str(RowInfo{i});
                    end
                    JavaObject(1,i) = java.lang.String(RowInfo{i}); 
                end
                set(h.table,'Data',JavaObject);
                drawnow;
            end
        end
        function [Value] = GetResult(StageName,Attribute)
            %Example: 
            %[Value] = GetResult('NoOfSymbolsPerDay','StartDate');
            %
            %Written by:    Bryan Taylor
            %Date Created:  28th April 2008
            global savecriteria

            GuiStruct = savecriteria.GuiStruct;
            stagename = struct2data(GuiStruct,'stagename');
            n = find(strcmpi(stagename,StageName));
            output = getfield(GuiStruct(n),'rptoutput');
            Value = getfield(output,Attribute);
        end
        function [Data] = GetStageData(varargin);
            %Get stage data
            %
            %Example 1: - Return all data from stage in array
            %[Data] = GetStageData('CalculateStakeFcn');
            %
            %Example 2: - Return attribute (column) from stage in an array
            %[Data] = GetStageData('CalculateStakeFcn','MoneyPot');
            %
            %Written by:    Bryan Taylor
            %Date Created:  19th April 2008
            %Date Modified: 19th April 2008

            global h savecriteria

            [x] = size(varargin,2);
            if x == 1
                StageName = varargin{1};
                Attribute = [];
            elseif x == 2
                StageName = varargin{1};
                Attribute = varargin{2};
            else
                error('Too many input args')
            end

            %% Database Name
            String = get(h.DatabaseSelection.pulldown,'String');
            Value = get(h.DatabaseSelection.pulldown,'Value');
            DatabaseName = String{Value};
            path = [h.path.savedata,DatabaseName];

            %%
            [Data] = FindLatest(path,StageName);
            if isnumeric(Data)
                uiwait(msgbox(['Data Not found. Please run simulation: ',StageName]))
                return
            end

            if not(isempty(Attribute))
                [Names] = GetTableColumnNames(StageName);
                n = find(strcmpi(Names,Attribute));
                Data = Data(:,n);
            end
        end
        function [Names] = GetTableColumnNames(Selection)
            %Get column names from table
            %
            %Written by:    Bryan Taylor
            %Date Modified: 7th June 2008

            Names = feval([Selection,'Fcn'],'ColumnNames');
        end
        function LoadStruct(h,TradeStructure)
            % set(h.button,'Enable','off');
            drawnow;

            [NoOfEntries] = size(TradeStructure,2);
            Names = fieldnames(TradeStructure);
            NoOfAttributes = size(Names,1);
            set(h.table,'ColumnName',Names);

            Data = struct2cell(TradeStructure);
            Data2 = rot90(reshape(Data(:,1,:),NoOfAttributes,NoOfEntries));

            set(h.table,'Data',Data2);
            % set(h.button,'Enable','on');
            drawnow;
        end
        function WriteReport()
            global TableHandle Selection
            feval(Selection,TableHandle);
        end
        function Summary()
            %Summary of information
            global savecriteria

            OutPutArray = savecriteria.symbolinfotable;

            [x] = size(OutPutArray,1);
            FullCount = 0;
            EmptyCount = 0;

            Count = 1;
            for i = 1:x
                if strcmp(OutPutArray{i,2},'FULL')
                    FullCount = FullCount + 1;
                    StartDates(Count) = datenum(OutPutArray{i,3});
                    EndDates(Count) = datenum(OutPutArray{i,4});
                    Count = Count + 1;
                else
                    EmptyCount = EmptyCount + 1;
                end
            end



            String = {['Table Summary:']; ...
                      ['Full Tables: ',num2str(FullCount)]; ... 
                      ['Empty Tables: ',num2str(EmptyCount)]; ...
                      ['Total No Of Tables: ',num2str(FullCount+EmptyCount)]; ...
                      ['']; ...
                      ['Database Date Range: ']; ...
                      ['Start Date: ',datestr(min(StartDates))]; ...
                      ['End Date: ',datestr(max(EndDates))]};

            SummaryFigure(String);
        end
        function UpdateStatus(obj,number)
            [bar] = obj.ImageGen(number);
            set(obj.handles.StatusBar.image,'cdata',bar);
            if number == 1;
                set(obj.handles.StatusBar.text1,'String',['Complete']);
            else
                set(obj.handles.StatusBar.text1,'String',[num2str(number*100,2),'%']);
            end
        end
        function SummaryFigure(String)
            %
            h.figure = figure;
            set(h.figure,'position',[20,100,250,150])
            set(h.figure,'Name','Summary');
            set(h.figure,'NumberTitle','off');   
            set(h.figure,'MenuBar','none');

            h.text = uicontrol;
            set(h.text,'Style','edit');
            set(h.text,'Max',10);
            set(h.text,'String',String);
            set(h.text,'HorizontalAlignment','left');
            set(h.text,'BackgroundColor',[1,1,1]);
            set(h.text,'Enable','off');
            drawnow
            set(h.text,'position',[20,10,200,130]);
        end
        function [Data] = GetTableData(h,Name);
            Data = get(h,'Data');
            ColumnNames = get(h,'ColumnName');
            n = find(strcmpi(Name,ColumnNames));
            if isempty(n)
               ColumnNames
               error('Column name not recognised') 
            end
            Data = Data(:,n);
        end
        function [] = DataViewerUpdate(varargin)
            %Calculate Parameters
            %
            %Written by:    Bryan Taylor
            %Date Created:  12th August 2008
            %Date Modified: 12th August 2008
            obj = varargin{1};
            disp('hello')

            Value = get(obj.handles.DatabaseViewer.pulldown,'Value');
            String = get(obj.handles.DatabaseViewer.pulldown,'String');
            symbol = String{Value}
            
            obj.DataObj.Symbol = symbol;
            obj.DataObj = obj.DataObj.LoadData;
                
            set(obj.handles.table,'ColumnName',obj.DataObj.DataStoreColumnNames );
            set(obj.handles.table,'Data',obj.DataObj.DataStore);
        end
    end
    methods (Hidden = true) %GUI Create
        function [obj] = CreateGUI(obj)
            [obj] = obj.CreateFigure();
            [obj] = obj.CreateStatusInfo();
            [obj] = obj.CreateStatusBar();
            [obj] = obj.CreateTable();
            [obj] = obj.CreateMenus();
            [obj] = obj.CreateToolbar();
            [obj] = obj.CreatStagePopupmenu();
            [obj] = obj.CreateDatabaseViewerPopupmenu();
            [obj] = obj.CreateDatabaseSelectionPopupmenu();
        end
        function [obj] = CreateStatusInfo(obj)
            h = uicontrol('Style','text', ...
                                 'String','Loading, Please Wait.....', ...
                                 'HorizontalAlignment','left');
            set(h,'Position',[5,0,200,20]);
            obj.handles.StatusInfo = h;
        end
        function [obj] = CreateStatusBar(obj);
            number = 0;
            [bar] = obj.ImageGen(number);
            h.image = imshow(bar);
            h.axes =gca;
            
            %%
            set(h.axes,'Position',[0.26,-0.05,0.2,0.2]);
            
            %%
            x = 1;
            h.text1 = text(97,8,1,'0%');
            set(h.text1,'HorizontalAlignment','center');
            set(h.text1,'FontWeight','bold');
            
            %%
            set(h.text1,'FontSize',8);
            obj.handles.StatusBar = h;
        end
        function [obj] = CreateFigure(obj)
            %% Create Figure
            h = figure;
            border = 10;
            width = 800;
            height = 200;
            distanceFromBottom = 50;
            set(h,'Position',[border,border,width+border*2,height+border*2]);
            %% Set Title
            set(h,'Name','Trade Guide - New Document.mat');
            set(h,'NumberTitle','off');   
            set(h,'Resize','on');
            set(h,'MenuBar','none');
            BackgroundColour = [0.8314    0.8157    0.7843];
            set(h,'Color',BackgroundColour)
            obj.handles.figure = h;
        end
        function [obj] = CreateTable(obj)
            h = uitable();
            border = 10;
            width = 821;
            height = 200;
            distanceFromBottom = 25;
            set(h,'Position',[0,distanceFromBottom,width,height-distanceFromBottom-2]);
            drawnow;
            obj.handles.table = h;
        end
        function [obj] = CreateMenus(obj)
            %% Create Menu's
            obj.handles.menu.file = uimenu(obj.handles.figure,'Label','File');
            obj.handles.menu.preferences = uimenu(obj.handles.menu.file,'Label','Preferences','Callback','Options');
            obj.handles.menu.saveprojectas = uimenu(obj.handles.menu.file,'Label','Save Project As','Callback','SaveProjectAs');
            obj.handles.menu.openproject = uimenu(obj.handles.menu.file,'Label','Open Project');
            obj.handles.menu.loadtable = uimenu(obj.handles.menu.file,'Label','Load Table');

            obj.handles.menu.Macros = uimenu(obj.handles.figure,'Label','Macros');
            obj.handles.menu.MacroDownloadData = uimenu(obj.handles.menu.Macros,'Label','Download Data');
        end
        function [obj] = CreateToolbar(obj)
            obj.handles.toolbar.main = uitoolbar(obj.handles.figure);

            [RGB,k] = imread('new_ico.bmp');
            RGB = ind2rgb(RGB,k);
            RGB = imresize(RGB,[16 16],'nearest');
            obj.handles.toolbar.New = uipushtool(obj.handles.toolbar.main, ...
                                              'CData',RGB, ... 
                                              'TooltipString','New', ...
                                              'tag','New', ...
                                              'ClickedCallback',{@ToolboxCallback,'New'});

            [RGB] = imread('save2.png');
            RGB = imresize(RGB,[16 16],'nearest');
            obj.handles.toolbar.Save = uipushtool(obj.handles.toolbar.main, ...
                                              'CData',RGB, ... 
                                              'TooltipString','Save', ...
                                              'tag','Save', ...
                                              'ClickedCallback',{@ToolboxCallback,'Save'});

            [RGB] = imread('save.png');
            RGB = imresize(RGB,[16 16],'nearest');
            obj.handles.toolbar.SaveAs = uipushtool(obj.handles.toolbar.main, ...
                                              'CData',RGB, ...
                                              'TooltipString','SaveAs', ...
                                              'tag','SaveAs', ...
                                              'ClickedCallback',{@ToolboxCallback,'SaveAs'});

            [RGB,k] = imread('GuaranteedToRun.gif');
            RGB = ind2rgb(RGB,k);
            RGB = imresize(RGB,[16 16],'nearest');
            obj.handles.toolbar.Analysis = uitoggletool(obj.handles.toolbar.main, ... 
                                              'CData',RGB, ... 
                                              'TooltipString','Analysis', ...
                                              'tag','Analysis', ...
                                              'Separator','on');
            [RGB] = imread('Stop.png');
            RGB = imresize(RGB,[16 16],'nearest');
            obj.handles.toolbar.Stop = uitoggletool(obj.handles.toolbar.main, ...
                                              'CData',RGB, ...
                                              'TooltipString', 'Stop', ...
                                              'tag','Stop'); 

            [RGB] = obj.readicon('rowsetviewer.Ico',0);
            obj.handles.toolbar.Report = uipushtool(obj.handles.toolbar.main, ...
                                              'CData',RGB, ...
                                              'TooltipString', 'Report', ...
                                              'tag','Report', ...
                                              'Separator','off');
            BackgroundColour = [0.8314    0.8157    0.7843];                             
            [RGB] = imread('Config.png');

            [x,y,z] = size(RGB);
            for i = 1:x
               for j = 1:y
                   for k = 1:3
                       Value = RGB(i,j,k);
                       if Value == 0
                            RGB(i,j,k) = BackgroundColour(k)*256;
                       end
                   end
               end
            end

            obj.handles.toolbar.ConfigMode = uipushtool(obj.handles.toolbar.main, ...
                                              'CData',RGB, ...
                                              'TooltipString', 'Config Mode', ...
                                              'tag','ConfigMode', ...
                                              'Separator','off');

            [RGB] = obj.readicon('Install.Ico',0);
            obj.handles.toolbar.AutoTrade = uitoggletool(obj.handles.toolbar.main, ...
                                              'CData',RGB, ...
                                              'TooltipString', 'Enable Auto Trading', ...
                                              'tag','AutoTrade', ...
                                              'Separator','on'); 
        end
        function [obj] = CreatStagePopupmenu(obj)
            obj.handles.Stage.pulldown = uicontrol( ...
                            'Style','popupmenu', ...
                            'String',obj.functions, ...
                            'enable','on', ...
                            'Value',1, ...
                            'Position',[90,200,160,20]);
            
            obj.handles.Stage.text = uicontrol( ...
                            'Style','text', ...
                            'String','Stage Selection: ', ...
                            'Position',[3,198,80,20], ...
                            'HorizontalAlignment','left');
        end
        function [obj] = CreateDatabaseViewerPopupmenu(obj);
            obj.handles.DatabaseViewer.text = uicontrol(    'Style','text', ...
                                'String','Symbol: ', ...
                                'HorizontalAlignment','left', ...
                                'enable','on', ...
                                'Position',[3+260,198,80,20]);
                            
            obj.handles.DatabaseViewer.pulldown = uicontrol( 'Style','popupmenu', ...
                                        'String',{'N/A'}, ...
                                        'enable','on', ...
                                        'Value',1, ...
                                        'Position',[90+220,200,80,20]);                                   
        end
        function [obj] = CreateDatabaseSelectionPopupmenu(obj);
            obj.handles.DatabaseSelection.text = uicontrol( ...
                        'Style','text', ...
                        'String','Database Name: ', ...
                        'HorizontalAlignment','left', ...
                        'enable','on', ...
                        'Position',[403,198,80,20]);

            obj.handles.DatabaseSelection.pulldown = uicontrol( ...
                            'Style','popupmenu', ...
                            'enable','on', ...
                            'Value',1, ...
                            'Position',[486,200,80,20]);    
           
            try
            cd([obj.SaveDataPath]);
            catch
            drawnow;
            uiwait(msgbox({'Can''t connect to SEAGATE drive';'Please connect the external hardrive';'Application will now close'}))
            close all
            clear all
            return
            end
            names = struct2cell(dir)';
            n = find(cell2mat(names(:,4)) == 1);
            names = names(n);
            n = find(not(strcmpi(names,'Common')));
            names = names(n);
            [x] = size(names,1);
            names = names(3:x,1);
            set(obj.handles.DatabaseSelection.pulldown,'String',names);
        end
    end
    methods (Hidden = true) %GUI Functions
        function ResizeFcn(varargin)
            obj = varargin{1};
            %% Create Figure
            distanceFromBottom = 25;
            distanceFromTop = 25;

            Position = get(obj.handles.figure,'Position');
            figuresize = Position;
            Position(1) = 0;
            Position(2) = distanceFromBottom;
            Position(4) = Position(4) - distanceFromBottom - distanceFromTop;

            set(obj.handles.table,'Position',Position);

            % Move stage pulldown
            pulldownsize = get(obj.handles.Stage.pulldown,'Position');
            pulldownsize(2) = figuresize(4)-20;
            set(obj.handles.Stage.pulldown,'Position',pulldownsize);

            % Move stage pulldown
            textsize = get(obj.handles.Stage.text,'Position');
            textsize(2) = figuresize(4)-23;
            set(obj.handles.Stage.text,'Position',textsize);

            % Move stage pulldown
            pulldownsize = get(obj.handles.DatabaseViewer.pulldown,'Position');
            pulldownsize(2) = figuresize(4)-20;
            set(obj.handles.DatabaseViewer.pulldown,'Position',pulldownsize);

            % Move stage pulldown
            textsize = get(obj.handles.DatabaseViewer.text,'Position');
            textsize(2) = figuresize(4)-23;
            set(obj.handles.DatabaseViewer.text,'Position',textsize);

            %% Move Database Name pulldown.
            pulldownsize = get(obj.handles.DatabaseSelection.pulldown,'Position');
            pulldownsize(2) = figuresize(4)-20;
            set(obj.handles.DatabaseSelection.pulldown,'Position',pulldownsize);

            textsize = get(obj.handles.DatabaseSelection.text,'Position');
            textsize(2) = figuresize(4)-23;
            set(obj.handles.DatabaseSelection.text,'Position',textsize);
            
            %% Move Status Progress Bar
%             set(h.axes,'Position',[0.26,-0.05,0.2,0.2]);
            VertPos = -16/figuresize(4);
            HorPos =  229/figuresize(3)
            Heigth = 55/figuresize(4);
            Width =  142/figuresize(3);
            set(obj.handles.StatusBar.axes,'Position',[HorPos,VertPos,Width,Heigth])
            set(obj.handles.StatusBar.axes,'Position',[HorPos,VertPos,Width,Heigth])
        end
        function IntialiseTable(obj,Names)  
            set(obj.handles.table,'ColumnName',Names);
            set(obj.handles.table,'Data',[]);
            drawnow;
        end
        function MacroDownloadData(obj,event,handles)
            global h savecriteria currentdirectory

            cd([currentdirectory,'\SaveData\Download'])
            [filename, pathname, filterindex] = uigetfile( ...
                   {'*.mat','MAT-files (*.mat)'}, ...
                    'Pick a file', ...
                    'MultiSelect', 'on');

            [x] = size(filename,2)

            % Set Mode
            Stage = find(strcmpi(obj.functions,'Download'));
            set(h.Stage.pulldown,'Value',Stage);

            for i = 1:x
                load([pathname,filename{i}])

                Names = feval(['DownloadFcn'],'ColumnNames');
                IntialiseTable(Names);
                set(h.table,'Data',java2array(Data));

                drawnow;
                output = DownloadRpt(handles.table,false);

                NoOfTablesUpdated(i) = output.NoOfTablesUpdated;

                name = strrep(filename{i},'Download_','');
                name = strrep(name,'.mat','');
                datenum(i) = str2num(strrep(name,'_','.'));

                clear Names Data
            end

            figure, scatter(datenum,NoOfTablesUpdated)
            datetick;
            ylabel('No Symbols Updated')
            xlabel('Date/Time')
        end
        function Analysis(handles)
        %Written by:    Bryan Taylor
        %Date Created:  22nd April 2008
        %Date Modified: 22nd April 2008

            %% Run Analysis
            Stage = get(h.Stage.pulldown,'Value');

            [functions] = StageDeclaration();
            [x] = size(functions,1);
            try
                output = GuiStruct(Stage).output
                Inprogress = true;
            catch
                Inprogress = false; 
            end
            if Inprogress == true;
                output = feval([functions{Stage},'Fcn'],handles,output);
            else
                output = feval([functions{Stage},'Fcn'],handles);
            end

            %% Move tool to next stage
            if Stage == x
                Stage = Stage - 1;
            end
            set(h.Stage.pulldown,'Value',Stage+1); %move the tool onto the next stage
        end
        function [bar] = ImageGen(obj,number)
            bar = ones(15,200,3);
            one = round(200*double(number));
            bar(:,1:one,1:2) = 0.6;
            [x,y,z] = size(bar);

            %Border
            bar(1:x,1,:) = 0;
            bar(1:x,y,:) = 0;
            bar(1,1:y,:) = 0;
            bar(x,1:y,:) = 0;
        end
        function [answer] = UserRequestDownloadNo(obj)
            prompt = {'Enter No Of Download Interations:'};
            dlg_title = 'Input for AutoTrade function';
            num_lines = 1;
            def = {'2'};
            answer = inputdlg(prompt,dlg_title,num_lines,def);
            answer = str2num(answer{1});
            drawnow;
        end
        function SetStage(obj,StageName)
            String = get(obj.handles.Stage.pulldown,'String')
            n = find(strcmpi(StageName,String));
            set(obj.handles.Stage.pulldown,'Value',n);
        end
        function [StageName] = GetStage(obj)
            String = get(obj.handles.Stage.pulldown,'String');
            n = get(obj.handles.Stage.pulldown,'Value');
            StageName = String{n};
        end
    end
    methods (Hidden = true) %Functional
        function [NewTradeStructure] = Filter(obj,TradeStructure,Name)
            Names = fieldnames(TradeStructure);
            TempTradeStructure = struct([]);
            SizeOfTradeStruct = size(TradeStructure,2);

            x = size(Name,1);

            for j = 1:SizeOfTradeStruct
                for i = 1:x
                    string = ['TempTradeStructure(',num2str(j),').',Name{i}, '= TradeStructure(',num2str(j),').',Name{i},';'];
                    eval(string);
                end
            end
            NewTradeStructure = TempTradeStructure;
        end
        function [startdate,enddate] = VerifyStatus(obj);
            %% Verfiy status
            global currentdirectory

            load([currentdirectory,'\Profiles\BuySellDatabaseStatus'])
            load([currentdirectory,'\Profiles\DatabaseStatus'])

            if BuySellDatabaseStatus.lastupdated == DatabaseStatus.lastupdated
                startdate = DatabaseStatus.startdate;
                enddate = DatabaseStatus.enddate;
            else
                [startdate,enddate] = GetSearchDateLimits;
                %update local database status
                BuySellDatabaseStatus.startdate = startdate; 
                BuySellDatabaseStatus.enddate = enddate;
                BuySellDatabaseStatus.lastupdated = DatebaseStatus.lastupdated;
                DatebaseStatus = BuySellDatabaseStatus;
                save([currentdirectory,'\Profiles\BuySellDatabaseStatus'])
                save([currentdirectory,'\Profiles\DatabaseStatus'])
            end
        end   
        function [RGB] = readicon(obj,Name,Border)
            %Written by: Bryan Taylor

            global currentdirectory h

            [a,b,c] = imread([currentdirectory,'\Icons\',Name]); 
            % Augment colormap for background color (white).
            BackgroundColour = [0.8314    0.8157    0.7843];
            b2 = [b; BackgroundColour]; 
            % Create new image for display. 
            d = ones(size(a)) * (length(b2) - 1); 
            % Use the AND mask to mix the background and
            % foreground data on the new image
            d(c == 0) = a(c == 0); 
            % Display new image 
            RGB = ind2rgb(uint8(d),colormap(b2));

            %Add border
            [x] = size(RGB,1);
            TopAndBottom(1:Border,1:x,1) = BackgroundColour(1);
            TopAndBottom(1:Border,1:x,2) = BackgroundColour(2);
            TopAndBottom(1:Border,1:x,3) = BackgroundColour(3);
            newRGB = [TopAndBottom;RGB;TopAndBottom];
            LeftAndRight(1:x+Border*2,1:Border,1) = BackgroundColour(1);
            LeftAndRight(1:x+Border*2,1:Border,2) = BackgroundColour(2);
            LeftAndRight(1:x+Border*2,1:Border,3) = BackgroundColour(3);
            RGB = [LeftAndRight,newRGB,LeftAndRight];

            RGB = imresize(RGB,[16 16],'nearest');
        end
        function Analysis_Callback(obj)
        %
        %Written by:    Bryan Taylor
        %Date Created:  22nd April 2008
        %Date Modified: 22nd April 2008
            path = obj.SaveDataPath;

            %% Database Name
            String = get(obj.handles.DatabaseSelection.pulldown,'String');
            Value = get(obj.handles.DatabaseSelection.pulldown,'Value');
            DatabaseName = String{Value};

            %% Run Analysis
            Stage = get(obj.handles.Stage.pulldown,'Value');
            DataObj = feval(obj.functions{Stage});
            DataObj.TradeGuideHandle = obj;
            DataObj.Location = [obj.SaveDataPath,'\'];
            DataObj.Process;

            %% Save Information
            tabledata = get(obj.handles.table,'Data');
            StageName = obj.functions{Stage};
            try 
                path = [path,'\',DatabaseName,'\',StageName,'\'];
                cd(path);
            catch
                mkdir(path);
            end
            SaveFolder = [path,strrep(num2str(now),'.','_')];
            save(SaveFolder,'tabledata');
        end
        function [] = ToolboxCallback(varargin)
            TradeGuideObj = varargin{1};
            event = varargin{2};
            
            if TradeGuideObj.handles.toolbar.Analysis == event
               State = 'start'
            elseif TradeGuideObj.handles.toolbar.Stop == event
               State = 'stop' 
            else
               error('Invalid Event') 
            end
            
            switch lower(State)
                case 'stop'   %Stop 
                    set(TradeGuideObj.handles.toolbar.Analysis,'State','off');
                    set(TradeGuideObj.handles.toolbar.Stop,'State','on');
                    set(TradeGuideObj.handles.StatusInfo,'String','Ready');
                case 'start'   %Anaylsis
                    set(TradeGuideObj.handles.StatusInfo,'String','Busy');
                    set(TradeGuideObj.handles.toolbar.Analysis,'State','on');
                    set(TradeGuideObj.handles.toolbar.Stop,'State','off');
                    drawnow;
                        
                    TradeGuideObj.Analysis_Callback();

                    set(TradeGuideObj.handles.toolbar.Analysis,'State','off');
                    set(TradeGuideObj.handles.toolbar.Stop,'State','on');
                    set(TradeGuideObj.handles.StatusInfo,'String','Ready'); 
                otherwise
                    error('Toolbox selection not recognised')
            end
            drawnow;
        end
        function [] = Report(varargin)
            obj = varargin{1};

            %% Run Analysis
            Stage = get(obj.handles.Stage.pulldown,'Value');
            % GuiStruct = savecriteria.GuiStruct;

            set(obj.handles.StatusInfo,'String','Analysis Of Table, Please Wait...')
            drawnow;

            %% Get Stage Name
            Selection = obj.GetStage;

            obj = feval(Selection);
            obj.Report;

            set(obj.handles.StatusInfo,'String','Ready')
        end
        function [tabledata] = FindLatest(path,Stage);
            %Written by: Bryan Taylor
            %TODO: Could add caching to this piece of code.

            DataPath = [path,'\',Stage];

            try
            cd(DataPath);
            catch
            uiwait(msgbox('No data exists for this mode'));
            tabledata = -1;
            return
            end

            %% Get list of files
            struct = dir;
            names = struct2cell(struct)';
            [x] = size(names,1);
            names = names(3:x,1);

            %% Find names that are mat files
            [x] = size(names,1);
            count = 1;
            for i = 1:x
                n = findstr(names{i},'.mat');
                if not(isempty(n))
                    newnames(count) = names(i);
                    count = count + 1;
                end
            end

            %% find newest
            Num = strrep(newnames,'_','.');
            Num = strrep(Num,'.mat','');
            Num = str2double(Num);
            n = find(Num == max(Num));

            %% Load data
            load(names{n},'tabledata');
        end
    end
end
