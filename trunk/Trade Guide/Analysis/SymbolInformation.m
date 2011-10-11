classdef SymbolInformation
    properties
        ColumnNames = { 'Symbol'; ...
                        'Status'; ...
                        'Start Date'; ...
                        'End Date'; ...
                        };
    end
    methods
        function [OutPutArray] = SymbolInformation(varargin)
        %Similar to StockDateRange but for the whole database
        %
        %Example:
        %[OutPutArray] = SymbolInformation()
        %
        %Written by: Bryan Taylor
        %Date Created: 29th July 2007
        %Date Modified: 29th July 2007

            global h savecriteria
            [log,handles] = parseinputs(varargin);

            %list all stocks in database
            [tablelist] = GetAllTableNames();

            [x] = size(tablelist,1);
            datetype = 1;
            EmptyCount = 0;
            FullCount = 0;
            for i = 1:x
                        waitfor(handles.toolbars.Stop,'State','off');
                        set(handles.Status,'String',[num2str(i/x*100,3),'% Complete'])
                        drawnow;
                        [startdate,enddate] = StockDateRange(tablelist{i});
                        if strcmp(startdate,'No Data')
                            %START EMPTY TABLES
                            EmptyCount = EmptyCount + 1;
                            if log == true
                                fprintf('Symbol %s: , Status: EMPTY, Start Date: N/A, End Date: N/A\n',tablelist{i});
                            end
                            OutPutArray{i,1} = tablelist{i};
                            OutPutArray{i,2} = 'EMPTY';
                            OutPutArray{i,3} = 'N/A';
                            OutPutArray{i,4} = 'N/A';
                        else
                            %START FULL TABLES
                            FullCount = FullCount + 1;
                            if log == true
                                fprintf('Symbol %s:, Status: FULL, Start Date: %s, End Date: %s\n',tablelist{i},datestr(startdate,datetype),datestr(enddate,datetype));
                            end
                            OutPutArray{i,1} = tablelist{i};
                            OutPutArray{i,2} = 'FULL';
                            OutPutArray{i,3} = datestr(startdate,datetype);
                            OutPutArray{i,4} = datestr(enddate,datetype);
                        end
                        AddRow(OutPutArray(i,:))
            end

            savecriteria.symbolinfotable = OutPutArray;
            savecriteria.symbolinfojavaobject = get(h.table,'Data');

            set(handles.Status,'String',['Ready'])

            %Summary of information
            if log == true
                disp('Summary of Search:')
                disp(['EMPTY: ',num2str(EmptyCount)])
                disp(['FULL: ',num2str(FullCount)])
            end
            % close(h)
        end
        function [log,handles] = parseinputs(varargin);
            %
            varargin = varargin{1};

            %Default
            log = false;

            %Optional Inputs
            [x] = size(varargin,2);
            for i = 1:2:x
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
    
