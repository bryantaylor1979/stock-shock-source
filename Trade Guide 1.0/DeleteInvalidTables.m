function [] = DeleteInvalidTables();
%DeleteInvalidTables
%The database must be intialised

% 
%Get table list
[ans] = CheckDatabaseIntergrity;
array = struct2cell(ans);
Status = array(2,:);
n = find(strcmp(Status,'FAIL'));

invalidsymbols = array(1,n);
[x] = size(invalidsymbols,2);
for i = 1:x
    invalidsymbols{1,i}
    DeleteTable(invalidsymbols{1,i})
end