function [OutPutArray] = SymbolInformation(varargin)
%Similar to StockDateRange but for the whole database
%
%Example:
%[OutPutArray] = SymbolInformation()

global handles

[log,conn] = parseinputs(varargin);

%list all stocks in database
[tablelist] = GetAllTableNames(conn);

[x] = size(tablelist,1);
datetype = 1;
EmptyCount = 0;
FullCount = 0;

for i = 1:x
            SetElapsedTime;
            [State] = CheckPauseStopStatus();
            waitfor(handles.startbutton,'Enable','off');
            if strcmp(State,'stop')
                
            end
            
            waitbar2(handles.taskprogress,i/x);
            set(handles.tasktext,'String',['Progress: ',num2str(i),' of ',num2str(x)])
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
end

%Summary of information
if log == true
    disp('Summary of Search:')
    disp(['EMPTY: ',num2str(EmptyCount)])
    disp(['FULL: ',num2str(FullCount)])
end

function [log,conn] = parseinputs(varargin);
%
varargin = varargin{1};
conn = varargin{1};

%Default
log = false;

%Optional Inputs
[x] = size(varargin,2);
for i = 2:2:x
   switch lower(varargin{i})
       case 'log'
          log = varargin{i+1};
       otherwise
   end
end
    
