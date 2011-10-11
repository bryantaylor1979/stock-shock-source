function [output] = ValidDateRangeFcn(varargin)
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
                 'PC_StartDate'; ...
                 'PC_EndDate'; ...
                 'TS_StartDate'; ...
                 'TS_EndDate'; ...
                 'Max_StartDate'; ...
                 'Min_EndDate'; ...
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


str = {'Silent(Quick)';'Visual(Slow)'};
[s,v] = listdlg('PromptString','Select a Mode:',...
                'SelectionMode','single',...
                'ListString',str);
if v == 0
   uiwait(msgbox('No selection made'));
   return   
else
   Mode = str{s}; 
end

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
                if strcmpi(Mode,'Silent(Quick)')
                    TradeStructure(i).Symbol = tablelist{i};
                    TradeStructure(i).Status = 'EMPTY';
                    TradeStructure(i).StartDate = 'N/A';
                    TradeStructure(i).EndDate = 'N/A';
                    TradeStructure(i).PC_StartDate = 'N/A';
                    TradeStructure(i).PC_EndDate = 'N/A';
                    TradeStructure(i).TS_StartDate = 'N/A';
                    TradeStructure(i).TS_EndDate = 'N/A';
                    TradeStructure(i).Max_StartDate = 'N/A';
                    TradeStructure(i).Min_EndDate = 'N/A';
                    TradeStructure(i).NoOfDays_OutOfDate = 'N/A';
                    TradeStructure(i).DateTime = 'N/A';
                else
                    Row{1,1} = tablelist{i};
                    Row{1,2} = 'EMPTY';
                    Row{1,3} = 'N/A';
                    Row{1,4} = 'N/A';
                    Row{1,5} = 'N/A';
                    Row{1,6} = 'N/A';
                    Row{1,7} = 'N/A';
                    Row{1,8} = 'N/A';
                    Row{1,9} = 'N/A';
                    Row{1,10} = 'N/A';
                    Row{1,11} = 'N/A';
                    Row{1,12} = 'N/A';
                end
            else
                %START FULL TABLES
                FullCount = FullCount + 1;
                if log == true
                    fprintf('Symbol %s:, Status: FULL, Start Date: %s, End Date: %s\n',tablelist{i},datestr(startdate,datetype),datestr(enddate,datetype));
                end
                [Data] = GetData(tablelist{i});
                [PC_StartDate,PC_EndDate,TS_StartDate,TS_EndDate,Max_StartDate,Min_EndDate] = AnalysisOfData(Data);
                
                if strcmpi(Mode,'Silent(Quick)')
                    TradeStructure(i).Symbol = tablelist{i};
                    TradeStructure(i).Status = 'FULL';
                    TradeStructure(i).StartDate = datestr(startdate,datetype);
                    TradeStructure(i).EndDate = datestr(enddate,datetype);
                    try
                    TradeStructure(i).PC_StartDate = datestr(PC_StartDate,datetype);
                    TradeStructure(i).PC_EndDate = datestr(PC_EndDate,datetype);
                    TradeStructure(i).TS_StartDate = datestr(TS_StartDate,datetype);
                    TradeStructure(i).TS_EndDate = datestr(TS_EndDate,datetype);
                    TradeStructure(i).Max_StartDate = datestr(Max_StartDate,datetype);
                    TradeStructure(i).Min_EndDate = datestr(Min_EndDate,datetype);
                    catch
                    TradeStructure(i).PC_StartDate = 'N/A';
                    TradeStructure(i).PC_EndDate = 'N/A';
                    TradeStructure(i).TS_StartDate = 'N/A';
                    TradeStructure(i).TS_EndDate = 'N/A';
                    TradeStructure(i).Max_StartDate = 'N/A';
                    TradeStructure(i).Min_EndDate = 'N/A';                           
                    end
                    TradeStructure(i).NoOfDays_OutOfDate = today - enddate;
                    TradeStructure(i).DateTime = datestr(now);
                else
                    Row{1,1} = tablelist{i};
                    Row{1,2} = 'FULL';
                    Row{1,3} = datestr(startdate,datetype);
                    Row{1,4} = datestr(enddate,datetype);
                    try
                    Row{1,5} = datestr(PC_StartDate,datetype);
                    Row{1,6} = datestr(PC_EndDate,datetype);
                    Row{1,7} = datestr(TS_StartDate,datetype);
                    Row{1,8} = datestr(TS_EndDate,datetype);
                    Row{1,9} = datestr(Max_StartDate,datetype);
                    Row{1,10} = datestr(Min_EndDate,datetype);
                    catch
                    Row{1,5} = 'N/A';
                    Row{1,6} = 'N/A';
                    Row{1,7} = 'N/A';
                    Row{1,8} = 'N/A';
                    Row{1,9} = 'N/A';
                    Row{1,10} = 'N/A';                           
                    end
                    Row{1,11} = today - enddate;
                    Row{1,12} = datestr(now);
                end
            end
            if not(strcmpi(Mode,'Silent(Quick)'))
            AddRow(Row);
            end
end

if strcmpi(Mode,'Silent(Quick)')
    LoadStruct(h,TradeStructure);
end

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
    
function [Data] = GetData(symbol);

conn = database('SaxoTrader','','');
sqlstatement = ['SELECT ALL datenum,PercentageChange,TradeSignal FROM ',symbol];

curs=exec(conn, sqlstatement);
curs=fetch(curs);
Data = curs.Data;

function [PC_StartDate,PC_EndDate,TS_StartDate,TS_EndDate,Max_StartDate,Min_EndDate] = AnalysisOfData(Data)
%
    %filter percentage change nans
    n = find(isnan(cell2mat(Data(:,2)))==0);
    Pc = Data(n,:);
    PC_StartDate = min(cell2mat(Pc(:,1)));
    PC_EndDate = max(cell2mat(Pc(:,1)));
    
    %filter tradesignal nans
    n = find(isnan(cell2mat(Data(:,3)))==0);
    Pc = Data(n,:);
    TS_StartDate = min(cell2mat(Pc(:,1)));
    TS_EndDate = max(cell2mat(Pc(:,1)));
    
Max_StartDate = max([TS_StartDate,PC_StartDate]);
Min_EndDate = min([TS_EndDate,PC_EndDate]);
if isempty(PC_StartDate)
    PC_StartDate = 'N/A';
    PC_EndDate = 'N/A';
    Max_StartDate = 'N/A';
    Min_EndDate = 'N/A'; 
end
if isempty(TS_StartDate)
    TS_StartDate = 'N/A';
    TS_EndDate = 'N/A';
    Max_StartDate = 'N/A';
    Min_EndDate = 'N/A'; 
end
