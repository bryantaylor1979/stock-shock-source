function [Data] = GetStageData(varargin);
%Get stage data
%
%Example 1: - Return all data from stage in array
%[Data] = GetStageData('CalculateStakeFcn');
%
%Example 2: - Return attribute (column) from stage in an array
%[Data] = GetStageData('CalculateStakeFcn','MoneyPot');
%
%Written by:    Bryan Taylor
%Date Created:  19th April 2008
%Date Modified: 19th April 2008

global h savecriteria

[x] = size(varargin,2);
if x == 1
    StageName = varargin{1};
    Attribute = [];
elseif x == 2
    StageName = varargin{1};
    Attribute = varargin{2};
else
    error('Too many input args')
end

%% Database Name
String = get(h.DatabaseSelection.pulldown,'String');
Value = get(h.DatabaseSelection.pulldown,'Value');
DatabaseName = String{Value};
path = [h.path.savedata,DatabaseName];

%%
[Data] = FindLatest(path,StageName);
if isnumeric(Data)
    uiwait(msgbox(['Data Not found. Please run simulation: ',StageName]))
    return
end

if not(isempty(Attribute))
    [Names] = GetTableColumnNames(StageName);
    n = find(strcmpi(Names,Attribute));
    Data = Data(:,n);
end