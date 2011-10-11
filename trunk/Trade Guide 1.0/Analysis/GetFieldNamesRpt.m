function [output] = GetFieldNamesRpt(tablehandle);
%Written by: Bryan Taylor
%Date Created:  19th July 2008
%Date Modified: 19th July 2008

Datenum = GetTableData(tablehandle,'Pass');
output = 1;
[x] = size(Datenum,1);
n = find(strcmpi(Datenum,'Pass'));
n1 = find(strcmpi(Datenum,'Fail'));
PassSize = size(n,1);
FailSize = size(n1,1);

String = {['Number Of Symbols in Database: ',num2str(x)]; ...
            ['Failed: ',num2str(FailSize)]; ...
            ['Pssed: ',num2str(PassSize)]; ...
        };
uiwait(msgbox(String))