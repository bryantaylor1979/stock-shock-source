classdef  DateRange_Mat
    properties
        ColumnNames = {     'Symbol'; ...
                            'Status'; ...
                            'Start Date'; ...
                            'End Date'; ...
                            'NoOfDays_OutOfDate'; ...
                            'Date/Time Processed'; ...
                      }; 
        Config = false;
    end
    methods (Hidden = false) 
        function [output] = Process(varargin)
            %Similar to StockDateRange but for the whole database
            %
            %Example:
            %[OutPutArray] = SymbolInformation()
            %
            %Written by: Bryan Taylor
            %Date Created: 29th July 2007
            %Date Modified: 29th July 2007

            %% Functional
            [log,handles] = parseinputs(varargin);

            %% list all stocks in database
            h = get(h.figure,'UserData');
            String = get(h.DatabaseSelection.pulldown,'String');
            Value = get(h.DatabaseSelection.pulldown,'Value');
            DatabaseName = String{Value};

            %% 
            [tablelist] = GetAllTableNames(DatabaseName);

            [x] = size(tablelist,1);
            datetype = 1;
            EmptyCount = 0;
            FullCount = 0;
            parfor i = 1:x
                waitfor(handles.toolbars.Stop,'State','off');
                set(handles.Status,'String',[num2str((1-i/x)*100,3),'% Complete'])
                drawnow;

                [startdate,enddate,errorcode] = StockDateRangeMat(DatabaseName,tablelist{i});
                if strcmp(startdate,'No Data')
                    %START EMPTY TABLES
                    EmptyCount = EmptyCount + 1;
                    if log == true
                        fprintf('Symbol %s: , Status: EMPTY, Start Date: N/A, End Date: N/A\n',tablelist{i});
                    end
                    Data(i,:) = {tablelist{i},'EMPTY','N/A','N/A','N/A',datestr(now)};
                else
                    %START FULL TABLES
                    FullCount = FullCount + 1;
                    if log == true
                        fprintf('Symbol %s:, Status: FULL, Start Date: %s, End Date: %s\n',tablelist{i},datestr(startdate,datetype),datestr(enddate,datetype));
                    end
                    Data(i,:) = {tablelist{i},'FULL',datestr(startdate,datetype),datestr(enddate,datetype),today - enddate,datestr(now)};
                end
            end

            set(h.table,'Data',Data);
            set(handles.Status,'String',['Ready'])

            %Summary of information
            if log == true
                disp('Summary of Search:')
                disp(['EMPTY: ',num2str(EmptyCount)])
                disp(['FULL: ',num2str(FullCount)])
            end
            output.NoOfEmpty = EmptyCount;
            output.NoOfFull = FullCount;
            % close(h)
        end
        function [tablelist] = GetAllTableNames(DatabaseName);
            % written by:   Bryan Taylor 
            % Date Created: 25th August 2008

            path = ['C:\SourceSafe\Stocks & Shares\Programs\Trade Guide\SaveData\',DatabaseName,'\Download_Mat\Data'];
            cd(path);
            filenames = dir;
            filenames = struct2data(filenames,'name');
            filenames = strrep(filenames,'.mat','');
            [x] = size(filenames,1);
            tablelist = filenames(3:x);
        end
    end
    methods (Hidden = true) 
        function [log,handles] = parseinputs(varargin);
            %
            handles = varargin{1};
            handles = handles{1};

            %Default
            log = false;

            %Optional Inputs
            [x] = size(varargin,2);
            for i = 2:2:x
               switch lower(varargin{i})
                   case 'log'
                      log = varargin{i+1};
                   case 'handles'
                      handles = varargin{i+1};
                   otherwise
               end
            end
        end   
    end
end