function [] = SearchAndAddSymbols(method)
%Search for available symbols
%Please ensure the database is intialised:
%i.e IntialiseDatabase;
%
%INPUTS: 
%   'method' all:-      Search all possible combinations.
%            null:-     Search only combinations that have not yet been
%                       searched
%            failed:-   Search all combination that have been tried before
%                       but not found.

%TODO: Check global connection is valid

AddTextStatus(['SearchAndAddSymbols Executed']);

%% Make sure database is ready to recieve the output data
global h conn2
conn2 = database('Symbol_Inf','','');
try
    AddField('Symbols','Valid','NUMBER');
catch
    disp('Valid field already present')
end

% Get the symbol list that is required for th search.
[Tables2Search] = GetSymbolList(method);

[suffix] = GetSuffix()

%% Remove current list for all possiblities
%TODO: Make this function faster
AddTextStatus(['Removing Symbols if preset']);
% [Tables2Search] = RemoveIfPresent(CompleteSymbolList,CurrentSymbolList);

[x] = size(Tables2Search,1);
for i = 1:x
    set(h.statustext,'String',[num2str(i),' of ',num2str(x)]);
    drawnow
    %complete list
    [Valid,NoOfTimesSearched] = GetData(Tables2Search{i});
    if or(Valid == 0,isnan(Valid)) %Not valid, or null
        NoOfTimesSearched = IncrementNoOfTimeSearched(NoOfTimesSearched);
        [FoundSymbol] = SearchForSymbols({[Tables2Search{i},suffix]}); %search for symbol
        if not(isempty(FoundSymbol))
            AddTextStatus(['Adding new symbol (''',Tables2Search{i},'''): New Data Found']);
            Valid = 1;
        else
            Valid = 0;
        end
        UpdateData(Tables2Search{i},Valid,NoOfTimesSearched)
    else
        AddTextStatus([Tables2Search{i},': Symbol already found']);
    end
end

%TODO: Add summary of function here

function [Valid,NoOfTimesSearched] = GetData(symbol)
%get current info
global h conn2
[suffix] = GetSuffix();
suffix = strrep(suffix,'.','_');
e = exec(conn2,['SELECT ALL Valid',suffix,',NoOfTimesSearched',suffix,' FROM Symbols WHERE symbol LIKE ''',symbol,'''  ']);
e = fetch(e);
Data = e.Data;
Valid = Data{1};
NoOfTimesSearched = Data{2};

function NoOfTimesSearched = IncrementNoOfTimeSearched(NoOfTimesSearched)
%Increment No of times Searched by 1, if null intialise to be 1.
if isnan(NoOfTimesSearched)
    NoOfTimesSearched = 1;
    return
end
NoOfTimesSearched = NoOfTimesSearched + 1;

