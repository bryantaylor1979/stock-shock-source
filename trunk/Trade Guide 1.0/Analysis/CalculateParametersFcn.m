function [Output] = CalculateParametersFcn(varargin)
%Calculate Parameters
%
%Written by:    Bryan Taylor
%Date Created:  21st July 2008
%Date Modified: 21st July 2008

Mode = 'fastupdate'; %or update/fastupdate

%% Column Name Declaration
try
if strcmpi(varargin{1},'ColumnNames')
    load CalcSetting CalcSetting
    Output = CalcSetting.CalculationsSelected;
    Output = [{'symbol'};Output];
    return
end
end

%% Config Declarations
try
if strcmpi(varargin{1},'Config')
   Output = true; 
   return
end
end

global conn h
conn = database('SaxoTrader','','');

%% Check
try
[OutPutArray] = GetStageData('CalculateParameters');
[x] = size(OutPutArray,1);
symbol = OutPutArray{x,1};
n = find(strcmpi(OutPutArray,symbol))
Status = 'Update';
StartPoint = n + 1;
catch
Status = 'Complete';   
StartPoint = 1;
end

try
    %% Get Data
    [OutPutArray] = GetStageData('GetFieldNames');

    %% Filter all failed
    n = find(strcmpi(OutPutArray(:,2),'Pass'));
    OutPutArray = OutPutArray(n,:);
catch
    disp('Warning: Could not find getfieldnames report')
    [OutPutArray] = GetStageData('DateRange');
    OutPutArray = OutPutArray(:,1);
end

%% Get Calculations
load CalcSetting CalcSetting
NewCalculation = CalcSetting.CalculationsSelected

Output = 1;
x = size(OutPutArray,1)
h1 = waitbar(0);
for i = StartPoint:x %loop over symbols
    set(h.Status,'String',[num2str((i-StartPoint)/(x-StartPoint)*100,3),'% Complete']);
    drawnow;
    
    %Check Stop
    State = get(h.toolbars.Stop,'State');
    if strcmpi(State,'on')
       close(h1)
       return
    end
    
    clear RowInfo
    waitbar(i/x,h1);
    if iscell(OutPutArray)
        symbol = OutPutArray{i,1};
    else
        symbol = OutPutArray(i,1);
    end
%     disp(symbol);
    [y] = size(NewCalculation,1);
    struct.symbol = symbol;
    for j = 1:y %loop over calculations
%          fprintf(['Calculating & Appending: ',NewCalculation{j},' '])
         try
             [NewData] = feval(NewCalculation{j},symbol);
             Status = 'Pass';
             %        %Check the field name is there
             if not(NewData(1) == -1)           
                try
                AppendData(conn, symbol,NewData,NewCalculation{j},Mode);
                Status = 'Pass';
                catch
                Status = 'Failed to Append';
                end
             end
         catch
         Status = 'Failed to Calc';    
         end
         RowInfo{1,j} = Status; 
         struct = setfield(struct,NewCalculation{j},Status);
         fprintf(['Complete\n'])
    end
    RowInfo = [{symbol},RowInfo];
    AddRow(RowInfo);
    disp(' ');
end
%close(h)

