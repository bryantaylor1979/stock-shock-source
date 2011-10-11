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

global savecriteria

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

GuiStruct = savecriteria.GuiStruct;

stagename = struct2data(GuiStruct,'stagename');

n = find(strcmpi(stagename,StageName));
Data = GuiStruct(n).tabledata;

if not(isempty(Attribute))
    [Names] = GetTableColumnNames(StageName);
    n = find(strcmpi(Names,Attribute));
    Data = Data(:,n);
end