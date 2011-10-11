function [tabledata] = FindLatest(path,Stage);
%Written by: Bryan Taylor
%TODO: Could add caching to this piece of code.

DataPath = [path,'\',Stage];

try
cd(DataPath);
catch
uiwait(msgbox('No data exists for this mode'));
tabledata = -1;
return
end

%% Get list of files
struct = dir;
names = struct2cell(struct)';
[x] = size(names,1);
names = names(3:x,1);

%% Find names that are mat files
[x] = size(names,1);
count = 1;
for i = 1:x
    n = findstr(names{i},'.mat');
    if not(isempty(n))
        newnames(count) = names(i);
        count = count + 1;
    end
end

%% find newest
Num = strrep(newnames,'_','.');
Num = strrep(Num,'.mat','');
Num = str2double(Num);
n = find(Num == max(Num));

%% Load data
load(names{n},'tabledata');