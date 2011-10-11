function [Data] = Struct2Data(structure,field)
%Returns columnwise data from specified field.
%
%Inputs:
%   Structure: Structure containing data
%   Field: Fieldname of to reference data.
%
%Output:
%   Columnwise data.
%
%Example:
%[symbols] = DayBestInvestments(date);
%[Data] = Struct2Data(symbols,'symbol')

if isempty(structure)
    Data = [];
    return 
end
names = fieldnames(structure);
n = find(strcmp(field,names));
Array = struct2cell(structure);
Data = Array(n,:);
Data = Data'; %column wise data