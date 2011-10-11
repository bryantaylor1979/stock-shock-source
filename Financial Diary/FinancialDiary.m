classdef FinancialDiary
    properties
        InstallDir = 'C:\HmSourceSafe\Stocks & Shares\Programs\Financial Diary\';
        DataFileName = 'Dates.xls';
        EmailAdresses = {'bryan.taylor@st.com'; ...
                         'bryan.taylor@talktalk.net'}
        TableArray
        SelectedArray
        Visible = 'on';
        handles
        ProgramName = 'Financial Diary'
        Rev = 0.01;
        UpdateRate = 60*60*24; % 1 Day
        ColumnNames = { 'Symbol', ...
                        'Date', ...
                        'DateNum', ...
                        'DayToGo', ...
                        'Description', ...
                        'Status', ...
                        'Info Link', ...
                        }; %Describes the output of ReadData
        Reminders = [21,14,7,1]; %Alerts before events
    end
    properties %table filtering
        Filtering_Past = true
        Filtering_RemoveBlanks = true;
        Filtering_Future_Enable = true;
        Filtering_Future_NoOfDays = 45; %number
    end
    methods
        function [obj] = FinancialDiary()   
            obj = obj.ReadData;
            obj = obj.CreateGUI;
            obj.Filter(true);
        end
        function [obj] = ReadData(obj)
            %%
            [NUMERIC,TXT,RAW] = xlsread([obj.InstallDir,obj.DataFileName]);
            
            %Format
            Symbols = RAW(:,1);
            [x] = size(Symbols,1); %Process each row of the table
            for i = 2:x %first row is the headings
                %Pad Symbol Data
                if isnan(Symbols{i});
                    Symbols{i} = CurrentSymbol;
                else
                    CurrentSymbol = Symbols{i};
                end
                % Create datenum column
                Date = RAW{i,2};
                if ischar(Date)
                    DateNum{i,1} = datenum(Date,'dd/mm/yyyy');
                    DaysToGo{i,1} = datenum(Date,'dd/mm/yyyy') - floor(now);
                else
                    DaysToGo{i,1} = NaN;
                    DateNum{i,1} = NaN;
                end
            end
            RAW(:,1) = Symbols;
            Row = 3;
            RAW = [RAW(:,1:Row-1),DateNum,DaysToGo,RAW(:,Row:end)];
            obj.TableArray = RAW(2:end,1:7);
        end
        function [obj] = SetTableArray(obj)
            set(obj.handles.table,'Data',obj.TableArray);
            set(obj.handles.table,'ColumnName',obj.ColumnNames);
        end
        function [Table] = GetTableArray(obj)
            % Get the table display in the GUI.
            Table = get(obj.handles.table,'Data');
            ColumnNames = rot90(get(obj.handles.table,'ColumnName'));
            Table = [ColumnNames;Table];
        end
        function [obj] = SetSelectedArray(obj)
            set(obj.handles.table,'Data',obj.SelectedArray);
            set(obj.handles.table,'ColumnName',obj.ColumnNames);
        end
        function [obj] = Filter(obj,logic)
            %% logic - display tablearray or selected array
            SelectedTable = obj.TableArray;
            
            %Remove Blanks
            if obj.Filtering_RemoveBlanks == true
                Dates = cell2mat(SelectedTable(:,3));
                n = not(isnan(Dates));
                SelectedTable = SelectedTable(n,:);
            end
            
            %Remove Past Dates
            if obj.Filtering_Past == true
                Dates = cell2mat(SelectedTable(:,3));
                n = Dates>=floor(now); %Current day
                SelectedTable = SelectedTable(n,:);
            end
            %Remove Future Dates
            if obj.Filtering_Future_Enable == true
                Dates = cell2mat(SelectedTable(:,3));
                n = Dates<=floor(now) + obj.Filtering_Future_NoOfDays; %Current day
                SelectedTable = SelectedTable(n,:);                
            end
            
            %Display
            obj.SelectedArray = SelectedTable;
            if logic == true 
                obj.SetSelectedArray;
            else
                obj.SetTableArray;
            end
        end
        function [obj] = Update(varargin)
            obj = varargin{1};
            obj = obj.ReadData; 
            obj.Filter(true);
        end
    end
    methods  % GUI
        function [obj] = CreateGUI(obj)
            %%
            obj.handles.figure = figure('Toolbar','none',...
                                        'Visible',obj.Visible, ...
                                        'Menubar','none');
            set(obj.handles.figure, 'Name',[obj.ProgramName,' - Viewer (R',num2str(obj.Rev),')'], ...
                                    'NumberTitle','off');
            
            obj.handles.table = uitable( obj.handles.figure, ...
                    'Data', [], ...
                    'ColumnName', []);
                
            set(obj.handles.figure,'ResizeFcn',@obj.Resize);
            
            %Toolbar
            image = imread([obj.InstallDir,'Icons\refresh3.jpg']);
            image = imresize(image,[16,16]);
            
            obj.handles.status = uicontrol( 'Style','text', ...
                                            'Position',[2,2,100000,22], ...
                                            'HorizontalAlignment','left', ...
                                            'String','Ready');
                                        
            obj.handles.toolbar = uitoolbar(obj.handles.figure);
            obj.handles.refresh = uipushtool(obj.handles.toolbar,'CDATA',image, ...
                                                'TooltipString','Refresh', ...
                                                'ClickedCallback',@obj.UpdateTable);
            
            image = imread([obj.InstallDir,'Icons\ticker2.jpg']);
            image = imresize(image,[16,16]);
            obj.handles.auto = uitoggletool(obj.handles.toolbar,'CDATA',image, ...
                                                'TooltipString','Auto-Updater');

            image = imread([obj.InstallDir,'Icons\Filter.jpg']);
            image = imresize(image,[16,16]);
            obj.handles.filter = uitoggletool(obj.handles.toolbar,'CDATA',image, ...
                                                'TooltipString','Filter On Best Buys');
                                            
            image = imread([obj.InstallDir,'Icons\Filter2.jpg']);
            image = imresize(image,[16,16]);
            obj.handles.filter2 = uitoggletool(obj.handles.toolbar,'CDATA',image, ...
                                                'TooltipString','Filter On Invested Symbols');
                                                      
            obj.handles.timer = timer('TimerFcn',@obj.Update, 'Period', obj.UpdateRate,'ExecutionMode','fixedDelay');                               
            set(obj.handles.auto,'ClickedCallback',@obj.Timer);
            set(obj.handles.filter,'ClickedCallback',@obj.Filter);
            set(obj.handles.filter2,'ClickedCallback',@obj.FilterInvested);
                                            
            
            stop(obj.handles.timer)
        end 
        function [obj] = CreateSettingsGUI(obj)
            %%
            obj.handles.settings.figure = figure;
            obj.handles.fliter.Past = uicontrol(obj.handles.settings)
        end
        function [obj] = Resize(varargin)
            obj = varargin{1};
            Position = get(obj.handles.figure,'position');
            set(obj.handles.table,'Position',[1,25,Position(3),Position(4)-25])
        end
        function [obj] = Timer(varargin)
            obj = varargin{1};
            switch get(obj.handles.auto,'State')
                case 'off'
                    stop(obj.handles.timer)
                case 'on'
                    start(obj.handles.timer)
                otherwise
            end
        end
        function [obj] = SendEmail(obj)
            %%
            Data = obj.GetTableArray;
            
            xlswrite([obj.InstallDir,'Data.xls'],Data);
            disp('Complete')
            %% 
            setpref('Internet','SMTP_Server','smtp.talktalk.net');
            setpref('Internet','E_mail','bryan.taylor@talktalk.net');
            sendmail(   obj.EmailAdd, [obj.ProgramName,' - ',datestr(now)], ...
                         {'Program details: '; ...
                         ['Name: ',obj.ProgramName]; ...
                         ['Rev: ',num2str(obj.Rev)]; ...
                         ['Date: ',datestr(now)]; ...
                         }, ...
                         {[obj.InstallDir,'Data.xls']}); 
        end
    end
end