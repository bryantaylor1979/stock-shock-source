function [nodes] = ExpandFcn(tree, value)
%Tree expand function 
%
%Written by: Bryan Taylor
%Date Created: 28th January 2008
%Date Modified: 28th January 2008

global DatabaseStats
FieldNames = fieldnames(DatabaseStats);
switch lower(value)
    case 'stats'
         [x] = size(FieldNames,1);
         for i = 1:x
             nodes(i) = uitreenode(FieldNames{i}, FieldNames{i},[''], false);
         end
    otherwise
         n = find(strcmp(value,FieldNames));
         value = num2str(getfield(DatabaseStats,FieldNames{n}));
         nodes(1) = uitreenode(value, value,[''], true);
end