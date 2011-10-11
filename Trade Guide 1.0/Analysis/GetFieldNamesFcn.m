function [Output] = GetFieldNamesFcn(varargin)
%
%Written by:    Bryan Taylor
%Date Created:  15th July 2008
%Date Modified: 15th July 2008

%% Column Name Declaration
try
if strcmpi(varargin{1},'ColumnNames')
    Output = {  'Symbol'; ...
                'Pass'; ...
                'FieldNameAdded'; ...
                'FieldNamesFailed'; ...
            };
    return
end
end

%% Config Declarations
try
if strcmpi(varargin{1},'Config')
   Output = false; 
   return
end
end

%% Functional
global h
h = varargin{1};

%% Get the calculation selected
set(h.Status,'String',['Loading Optional Fields']);
drawnow;
load CalcSetting CalcSetting
Status = 'Ready';
Calculation = CalcSetting.CalculationsSelected;

%% Int Database
set(h.Status,'String',['Get fieldnames... Please be patient']);
drawnow;
conn = database('SaxoTrader','','');
try
    error()
    [l] = GetAllFieldNames();
    globalfail = true;
    temp2 = l(:,2);
    [x] = size(temp2,1);
catch
    globalfail = false; 
    [OutPutArray] = GetStageData('DateRange');
    symbols = OutPutArray(:,1);
    [x] = size(symbols,1)
end

%% Filter
set(h.Status,'String',['Analysis of fields']);
drawnow;


%Add compusory terms to calculation
Calculation = ...
    [Calculation; ...
    {'symbol'; ...
     'datenum'; ...
     'close'; ...
     'open'; ...
     'low'; ...
     'high'; ...
     'volume'; ...
     'closeadj'}];
 
[y] = size(Calculation,1)

new = {};
for i = 1:x
    FieldNamesAdded = 0;
    FieldNamesFailed = 0;
    for j = 1:y
        Fieldnames = temp2{i};
        FieldPass(j) = isempty(find(strcmpi(Calculation(j),Fieldnames)));
        Total = sum(FieldPass);
        TradeStructure(i).Symbol = l{i,1};
        if Total == 0
           TradeStructure(i).Pass = 'Pass';
           TradeStructure(i).FieldNameAdded = 'False';
        else
           TradeStructure(i).Pass = 'Fail'; 
           %identify fields to be added
           if FieldPass(j) == 1
              try
              AddField(conn,l{i,1},Calculation{j},'NUMBER');
              FieldNamesAdded = FieldNamesAdded+1;
              catch
              FieldNamesFailed = FieldNamesFailed+1;
              end
           end
        end
    end
    TradeStructure(i).FieldNameAdded = FieldNamesAdded;
    TradeStructure(i).FieldNamesFailed = FieldNamesFailed;
end

LoadStruct(h,TradeStructure);
set(h.Status,'String',['Ready']);
Output = 1;