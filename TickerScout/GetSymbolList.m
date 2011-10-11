function [CompleteSymbolList] = GetSymbolList(method)
%This function need to know the exchange and what you want searched.
%
%Exchange:  US
%           UK
%
%Written by:    Bryan Taylor
%Date Created:  28th January 2008
%Date Modified: 28th January 2008

%% Get All Possible Combinations
global conn2
conn2 = database('Symbol_Inf','','');
if not(isempty(conn2.Message))
    msgbox(conn2.Message)
end

[suffix] = GetSuffix();
suffix = strrep(suffix,'.','_');
switch lower(method)
    case 'all'
        String = ['SELECT ALL symbol FROM Symbols'];
        AddTextStatus('All - Search all symbols')
    case 'null'
        String = ['SELECT ALL symbol,Valid',suffix,' FROM Symbols WHERE Valid',suffix,' IS NULL'];
        AddTextStatus('Null - Symbols that have not been searched only')  
    case 'failed'
        String = ['SELECT ALL symbol,Valid',suffix,' FROM Symbols WHERE Valid',suffix,' = 0'];
        AddTextStatus('Failed - Symbols that have been searched but nothing was found')

    otherwise
end
String
e = exec(conn2,String);
struct = fetch(e);
CompleteSymbolList = struct.data;
[x] = size(CompleteSymbolList,1);
AddTextStatus(['Number of Symbols Found: ',num2str(x)])
