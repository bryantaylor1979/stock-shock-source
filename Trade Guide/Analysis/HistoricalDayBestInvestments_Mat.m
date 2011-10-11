classdef HistoricalDayBestInvestments_Mat
    properties
        ColumnNames = { 'Date'; ...
                        'Status'};
        Mode = 'Silent';
        Config = false; 
    end
    methods
        function [Output] = HistoricalDayBestInvestments_Mat(varargin)
            %
            %Written by:    Bryan Taylor
            %Date Created:  25th August 2008
            %Date Modified: 25th August 2008



            %% Functional

            [Value] = ListBox();

            [startdate,enddate] = GetNumberOfInvestments(); %Total Available range
            if strcmpi(Value,'Continue')
                [sd,ed] = GetDateList(); %Already processed range
                Dates = [ed+1:1:enddate];
            elseif strcmpi(Value,'All')
                Dates = [startdate:enddate];
            else
                error('mode not recognised');
            end

            [x] = size(Dates,2);
            for i = 1:x
                  %Update GUI
                  set(h.Status,'String',['Processing... ',num2str(i),' of ',num2str(x),' (',num2str(round(i/x*100)),'%)']);
                  drawnow;

                  [Status] = DayBestInvestments_MatFcn(1,Dates(i),true);

                  Row{i,1} = Dates(i);
                  Row{i,2} = Status;

                  if i == 1
                      Data = BuyRow;
                  else
                      Data = [Data;Row];
                  end   

                  if strcmpi(Mode,'Visual')
                     set(h.table,'Data',Data);
                  end
            end
            if strcmpi(Mode,'Silent')
                set(h.table,'Data',Data);
            end
            set(h.Status,'String','Ready');
            Output = 1;
        end
        function [startdate,enddate] = GetNumberOfInvestments()
            %Written by:    Bryan Taylor
            %Date Created:  30th April 2008
            prompt= {'Start Date:', ...
                     'End Date:'};    
            name        = 'Inputs for Decsion function';
            numlines    = 1;
            % Get Date Range#
            uiwait(msgbox('This function assumes the NoOfSymbolsPerDay_MatRpt has been run'));
            [output]    = NoOfSymbolsPerDay_MatRpt();
            [enddate]   = output.EndDate;
            [startdate] = output.StartDate;
            % input para gui
            defaultanswer   = {datestr(startdate),datestr(enddate)};
            answer          = inputdlg(prompt,name,numlines,defaultanswer);
            drawnow;
            % Return data
            startdate               = datenum(answer{1});
            enddate                 = datenum(answer{2});
        end
        function [StartDate,EndDate] = GetDateList()
            %Written by:    Bryan Taylor
            %Date Created:  30th April 2008
            path = 'C:\SourceSafe\Stocks & Shares\Programs\Trade Guide\SaveData\HistoricalDayBestInvestments_Mat\';
            cd(path);
            filenames = dir;
            names = struct2data(filenames,'name');
            [x] = size(names,1);
            list = names(3:x);
            StartDate = min(cell2mat(list));
            list = strrep(list,'.mat','');
            list = strrep(list,'Histroical_','');
            list = str2double(list);
            EndDate = max(list);
            StartDate = min(list);
        end
        function [Value] = ListBox();
            %Written by:    Bryan Taylor
            %Date Created:  30th April 2008
            d = dir;
            str = { 'Continue'; ...
                    'All'; ...
                    };
            [s,v] = listdlg('PromptString','Select a mode:',...
                            'SelectionMode','single',...
                            'ListString',str);           
            Value = str{s};
        end
    end
end