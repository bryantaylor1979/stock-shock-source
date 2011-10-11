function [] = CreateCache()

global savecriteria settings Cache Index
OutPutArray = savecriteria.symbolinfotable;
[startdateout,enddateout] = NoOfSymbolsPlot(false);



%remove all empty tables
n = find(strcmp(OutPutArray(:,2),'FULL'));
NewArray = OutPutArray(n,:);

[x,y] = size(NewArray);
h = waitbar(0);
Cache = struct([]);
for i = 1:x
    waitbar(i/x,h);
    startdate = datenum(NewArray{i,3});
    enddate = datenum(NewArray{i,4});
    STARTDATE = max([startdateout,startdate]);
    ENDDATE = min([enddateout,enddate]);
    
    DATA = StockQuote(NewArray{i,1},GetAllFieldNames(),[STARTDATE,ENDDATE]);
    Cache = setfield(Cache,{i},'symbol',NewArray{i,1});
    Index{i} = NewArray{i,1};
    Cache = setfield(Cache,{i},'Data',DATA);
end
close(h)