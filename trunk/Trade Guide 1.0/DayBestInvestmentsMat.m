function [symbols] = DayBestInvestmentsMat(symbolset)
%Create a structure of that days information
%This function should adaptive create a structure based on the available
%fields

if isempty(symbolset)
   error('Input symbols set is empty'); 
end

%% find symbols that have the buy
try
tradesignal = cell2mat(symbolset(:,11));
catch
   uiwait(msgbox('Please calculate parameters'));
   error('Please calculate parameters');
end
n = find(tradesignal==1); %buy = 1; sell = 0;

if isempty(n) %No trades for this day.
    symbols = {'No symbols'};
    return
end

% update structure
symbols = symbolset(n,:);

%Remove all Percentage Change that are NaN

% %rank them in order
symbolsset = dataset(symbols(:,1),cell2mat(symbols(:,2)),cell2mat(symbols(:,3)),cell2mat(symbols(:,4)),cell2mat(symbols(:,5)),cell2mat(symbols(:,6)),cell2mat(symbols(:,7)),cell2mat(symbols(:,8)),cell2mat(symbols(:,9)),cell2mat(symbols(:,10)),cell2mat(symbols(:,11)));
symbols = sortrows(symbolsset,{'Var10'},'descend');

[x] = size(symbols,1);
for i = 1:x
    Array{i,1} = symbols{i,1};
end
num = [double(symbols(:,2)),double(symbols(:,3)),double(symbols(:,4)),double(symbols(:,5)),double(symbols(:,6)),double(symbols(:,7)),double(symbols(:,8)),double(symbols(:,9)),double(symbols(:,10)),double(symbols(:,11))];
symbols = [Array,num2cell(num)];

%remove nans
symbols = symbols(not(isnan(cell2mat(symbols(:,10)))),:); %remove nans