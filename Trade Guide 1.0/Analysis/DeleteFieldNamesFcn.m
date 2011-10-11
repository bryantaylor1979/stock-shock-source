function [Output] = DeleteFieldNamesFcn(varargin)
%Written by:    Bryan Taylor
%Date Created:  15th August 2008 

%% Column Name Declaration
try
if strcmpi(varargin{1},'ColumnNames')
    Output = {  'Symbol'; ...
                'DeletedName'; ...
                'Status'; 
            };
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

global h

[OutPutArray] = GetStageData('DateRange');
fieldname = 'ChangeMarker';

symbols = OutPutArray(:,1);

[x] = size(symbols,1);
for i = 1:x
    Status.PercentageComplete = i/x*100;
    set(h.Status,'String',[num2str(Status.PercentageComplete,3),'% Complete'])
    try
    RemoveColumn(symbols(i),fieldname);
    Status = 'Pass';
    catch
    Status = 'Fail';
    end
    RowInfo{1,1} = symbols(i);
    RowInfo{1,2} = fieldname;
    RowInfo{1,3} = Status;
    AddRow(RowInfo);
end
Output = 1;