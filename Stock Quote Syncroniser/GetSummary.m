function [Summary] = GetSummary(SummaryStruct)

status = Struct2Data(SummaryStruct,'status');

n = find(strcmp(status,'Updated'));
x = size(n,1);
Summary.Updated = x;

n = find(strcmp(status,'Stale'));
x = size(n,1);
Summary.Stale = x;

n = find(strcmp(status,'NoNewData'));
x = size(n,1);
Summary.NoNewData = x;