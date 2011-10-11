classdef DateRange
    properties
       ColumnNames =   {'Symbol'; ...
                        'Status'; ...
                        'Start Date'; ...
                        'End Date'; ...
                        'NoOfDays_OutOfDate'; ...
                        'Date/Time Processed'; ...
                        };
    end
    methods    
        function [output] = Process(varargin)
        %Similar to StockDateRange but for the whole database
        %
        %Example:
        %[OutPutArray] = SymbolInformation()
        %
        %Written by: Bryan Taylor
        %Date Created: 29th July 2007
        %Date Modified: 29th July 2007

            %% Config Declarations
            try
            if strcmpi(varargin{1},'Config')
               output = false; 
               return
            end
            end

            %% Functional
            global h savecriteria
            [log,handles] = parseinputs(varargin);

            %list all stocks in database
            conn2 = database('SaxoTrader','','');
            [tablelist] = GetAllTableNames(conn2);

            [x] = size(tablelist,1);
            datetype = 1;
            EmptyCount = 0;
            FullCount = 0;
            for i = 1:x
                        waitfor(handles.toolbars.Stop,'State','off');
                        set(handles.Status,'String',[num2str(i/x*100,3),'% Complete'])
                        drawnow;
                        if or(strcmpi(tablelist{i},'ALL'),strcmpi(tablelist{i},'IN'))
                            startdate = 'No Data';
                        else
                        [startdate,enddate] = StockDateRange(conn2,tablelist{i});
                        end
                        if strcmp(startdate,'No Data')
                            %START EMPTY TABLES
                            EmptyCount = EmptyCount + 1;
                            if log == true
                                fprintf('Symbol %s: , Status: EMPTY, Start Date: N/A, End Date: N/A\n',tablelist{i});
                            end
                            TradeStructure(i).Symbol = tablelist{i};
                            TradeStructure(i).Status = 'EMPTY';
                            TradeStructure(i).StartDate = 'N/A';
                            TradeStructure(i).EndDate = 'N/A';
                            TradeStructure(i).NoOfDays_OutOfDate = 'N/A';
                            TradeStructure(i).DateTime = datestr(now);
                        else
                            %START FULL TABLES
                            FullCount = FullCount + 1;
                            if log == true
                                fprintf('Symbol %s:, Status: FULL, Start Date: %s, End Date: %s\n',tablelist{i},datestr(startdate,datetype),datestr(enddate,datetype));
                            end
                            TradeStructure(i).Symbol = tablelist{i};
                            TradeStructure(i).Status = 'FULL';
                            TradeStructure(i).StartDate = datestr(startdate,datetype);
                            TradeStructure(i).EndDate = datestr(enddate,datetype);
                            TradeStructure(i).NoOfDays_OutOfDate = today - enddate;
                            TradeStructure(i).DateTime = datestr(now);
                        end
            end

            LoadStruct(h,TradeStructure);

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
        function [output] = Report(tablehandle)
            %Summary of information
            %
            %Written by:    Bryan Taylor
            %Date Created:  1st April 2008
            %Date Modified: 1st April 2008

            % OutPutArray = savecriteria.symbolinfotable;
            Status = GetStageData('DateRange','Status');
            StartDate = GetStageData('DateRange','Start Date');
            EndDate = GetStageData('DateRange','End Date');

            %time to process
            DateTime = GetStageData('DateRange','Date/Time Processed');
            [x] = size(DateTime,1);
            TimeProcessed = datenum(DateTime{1}) - datenum(DateTime{x});
            DateStr = datestr(TimeProcessed+1,13);

            full = find(strcmpi('full',Status));
            FullCount = size(full,2);

            empty = find(strcmpi('empty',Status));
            EmptyCount = size(empty,2);

            StartDates = datenum(StartDate(full));
            EndDates = datenum(EndDate(full));

            NoOfDays_OutOfDate = GetStageData('DateRange','NoOfDays_OutOfDate');
            % NoOfDays_OutOfDate = cell2mat(GetTableData(tablehandle,'NoOfDays_OutOfDate'));
            [x] = size(NoOfDays_OutOfDate,1);

            for i = 5147:x-2
               if not(ischar(NoOfDays_OutOfDate{i}))
                NoOfDays_OutOfDate_Num(i) = NoOfDays_OutOfDate{i};
               else
                NoOfDays_OutOfDate_Num(i) = NaN;    
               end
            end

            Days0 = size(find(NoOfDays_OutOfDate_Num == 0),2);
            Days1 = size(find(NoOfDays_OutOfDate_Num == 1),2);
            Days2 = size(find(NoOfDays_OutOfDate_Num == 2),2);
            Days3 = size(find(NoOfDays_OutOfDate_Num == 3),2);
            Days3p = size(find(NoOfDays_OutOfDate_Num > 3),2);

            String = {'Table Summary:'; ...
                      '=============='; ...
                      ['Full Tables: ',num2str(FullCount)]; ... 
                      ['Empty Tables: ',num2str(EmptyCount)]; ...
                      ['Total No Of Tables: ',num2str(FullCount+EmptyCount)]; ...
                      ''; ...
                      'Database Date Range: '; ...
                      ['Start Date: ',datestr(min(StartDates))]; ...
                      ['End Date: ',datestr(max(EndDates))]; ...
                      ''; ...
                      'Days Old'; ...
                      '========'; ...
                      ['0 Day old: ',num2str(Days0)]; ...
                      ['1 Day old: ',num2str(Days1)]; ...
                      ['2 Days old: ',num2str(Days2)]; ...
                      ['3 Days old: ',num2str(Days3)]; ...
                      ['3+ Days old: ',num2str(Days3p)]; ...
                      ''; ...
                      ['Time to Process: ',num2str(DateStr)]; ...
                      };

            h = figure;
            Position = get(h,'Position');
            Position(3) = Position(3)*1.3;
            set(h,'Position',Position)

            pie([Days0 Days1 Days2 Days3 Days3p],{'0 Day old','1 Day old','2 Days old','3 Days old','3+ Days old'})
            set(h,'Name','Pie Chart Of Data Staleness', ...
                  'NumberTitle','off')

            text(-2.4,0,String)

            output.NoOfFullTables = FullCount;
            output.NoOfEmptyTables = EmptyCount;
            output.TotalNoOfTables = FullCount + EmptyCount;

            output.StartDateDateNum = min(StartDates);
            output.StartDateStr = datestr(output.StartDateDateNum);
            output.EndDateDateNum = max(EndDates);
            output.EndDateStr = datestr(output.EndDateDateNum);
        end
    end
end


    
