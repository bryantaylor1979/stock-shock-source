function [Data] = GetTableData(h,Name);
%Written by: Bryan Taylor
%Date Created: 31st March 2008
%Date Modified: 31st March 2008
Table = get(h,'Table');
JavaObject = get(h,'Data');
RowCount = get(Table,'RowCount');
ColumnNames = get(h,'ColumnNames');
[ColumnNames] = Java2Array(ColumnNames);

n = find(strcmp(Name,ColumnNames));
if isempty(n)
   ColumnNames
   error('Column name not recognised') 
end

Data = JavaObject(:,n);
[Data] = Java2Array(Data);

% try
%    Data = cell2mat(Data); 
% end