function [output] = DateRangeFcn(varargin)
%Similar to StockDateRange but for the whole database
%
%Example:
%[OutPutArray] = SymbolInformation()
%
%Written by: Bryan Taylor
%Date Created: 29th July 2007
%Date Modified: 29th July 2007

%% Column Names Declarations
try
if strcmpi(varargin{1},'ColumnNames')
    output = {   'Symbol'; ...
                 'Status'; ...
                 'Start Date'; ...
                 'End Date'; ...
                 'NoOfDays_OutOfDate'; ...
                 'Date/Time Processed'; ...
                 };
    return
end
end

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
    
