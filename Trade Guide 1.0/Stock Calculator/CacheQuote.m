function [Data] = CacheQuote(symbol,fieldname,range)
%Written by: Bryan Taylor
%Date Created: 14th Jan 2008
%Date Modified: 14th Jan 2008

global Index Cache
n = find(strcmp(Index,symbol));
Data = getfield(Cache,{n},'Data');

[x] = size(range);
sizeof = max(x);

if sizeof>1
n = find(cell2mat(Data(:,2))>=range(1));
Data = Data(n,:);
n = find(cell2mat(Data(:,2))<=range(2));
Data = Data(n,:);
else
n = find(cell2mat(Data(:,2))>=range(1));
Data = Data(n,:);  
Date = Data(1);
end