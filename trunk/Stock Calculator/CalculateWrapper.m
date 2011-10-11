function [] = CalculateWrapper(symbols,Calculation)
%This function calculates the daily price difference.
%
%Calculate the daily price difference
%
%Example: 
%Calculation = {    'DayDiff'; ...
%                   'PriceMean'};
%CalculateWrapper('all',Calculation);
%
%Written by:    Bryan Taylor
%Date Created:  25th Feburary 2008
%Date Modified: 25th Feburary 2008
%
%Copyright 2007, CoLogic, Inc

%TODO: Add Price (P) to database.
%TODO: Create example using P price data from local database

global handles Status
conn = database('SaxoTrader','','');

%Get List of FieldNames
SetElapsedTime;
set(handles.symboltext,'String','Stage1: Getting Field Names From Database');
set(handles.tasktext,'String','');
waitbar2(handles.taskprogress,0);
waitbar2(handles.totalprogress,0);
drawnow;
[fieldnames] = GetAllFieldNames(conn);
SetElapsedTime


set(handles.symboltext,'String','Stage2: Check fieldnames exist... ');

%% Check fieldnames exist
if ischar(Calculation)
    NewCalculation{1} = Calculation;
else
    NewCalculation = Calculation;
end
[y] = size(NewCalculation,1);
for i = 1:y
    try
        n = find(strcmp(fieldnames,NewCalculation{i}));
        if isempty(n)
            error([NewCalculation{i},' field is not available. Please up date field structure'])
        end
    catch
        disp(['FieldName does not exists. Adding field: ',NewCalculation{i}]);
        [symbols] = GetAllTableNames(conn);
        x = size(symbols,1);
        for j = 1:x
            AddField(conn,symbols{j},NewCalculation{i},'NUMBER')    
        end
    end
end
SetElapsedTime;
   
%% Get Table Names
set(handles.tasktext,'String',['Stage 3 - GetTableNames...']);
drawnow;
mode = 'full';
switch lower(mode)
    case 'all'
        [symbols] = GetAllTableNames(conn);
    case 'full'
        [OutPutArray] = SymbolInformation(conn);
        if not(iscell(OutPutArray))
           return 
        end
        n = find(strcmp(OutPutArray(:,2),'FULL'));
        symbols = OutPutArray(n,1);
    otherwise
end

waitbar2(handles.taskprogress,0);
set(handles.tasktext,'String',['Stage 4 - Process Calculations'])

x = size(symbols,1);
for i = 1:x %loop over symbols
   symbol = symbols{i,1};
   
   set(handles.symboltext,'String',['Stage 4 - Process Calculations, Symbol: ',symbol])
   waitbar2(handles.totalprogress,i/x);
   %get data
   [y] = size(NewCalculation,1);
   for j = 1:y %loop over calculations
        CheckFieldNameExists(NewCalculation{j});
        waitbar2(handles.taskprogress,0);
        drawnow;
        [NewData] = feval(NewCalculation{j},symbol);
        %Check the field name is there
        if not(NewData(1) == -1)           
            try
            AppendData(conn, symbol,NewData,NewCalculation{j});
            catch
            disp(['Failed Symbol: ',symbol,'    Para:',NewCalculation{j}])
            end
        else
            [State] = CheckPauseStopStatus();
            waitfor(handles.startbutton,'Enable','off');              
            if strcmp(Status,'Stop');
                return
            end
        end
        SetElapsedTime
   end
end
close(h)

function [] = AppendData(conn,symbol,data,FieldName);
%Append Data to databased
%
%Written by: Bryan Taylor
%Date Created: 25th Febuary 2008
%Date Modified: 25th Febuary 2008

%Check the field name is there
global handles Status

[y] = size(data,1);

[Date,OldData] = StockQuote(symbol,{'DateNum';FieldName},'all');
if CompareData(data,OldData)
    set(handles.tasktext,'String',['Progress: Skipped (UpToDate)','          Updating Field: ',FieldName])
    waitbar2(handles.taskprogress,1);
    drawnow;
else
    for j = 1:y
        SetElapsedTime
        waitbar2(handles.taskprogress,j/y);
        drawnow;
        waitfor(handles.startbutton,'Enable','off');
        if strcmp(Status,'Stop')
            return
        end
        set(handles.tasktext,'String',['Progress: ',num2str(j),' of ',num2str(y),'          Updating Field: ',FieldName])
        if not(data(j) == OldData(j))
            whereclause = ['WHERE datenum = ',num2str(Date(j))];
            try
            update(conn, symbol, {FieldName}, data(j), whereclause);
            catch
            disp(['Symbol: ',symbol,' DateNum: ',num2str(OldData(j))])
            error('Update not possible')
            end
        end
    end
end

function [] = CheckFieldNameExists(FieldName) 
%% Check the field name exists in the database
[fieldnames] = GetAllFieldNames();
n = find(strcmp(fieldnames,FieldName));
if isempty(n)
    error([FieldName,' field is not available. Please up date field structure'])
end
  