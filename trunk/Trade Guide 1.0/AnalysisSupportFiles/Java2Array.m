function [NewData] = Java2Array(Data)
%Written by: Bryan Taylor
%Date Created: 31st March 2008
%Date Modified: 31st March 2008
[x,y] = size(Data)
temp = Data(1);
y = size(temp,1);
for i = 1:x
        for j = 1:y
            value = Data(i,j); 
            NewData{i,j} = value;
        end
end