function [symbols] = DayBestInvestments(date)

%Create a structure of that days information
%This function should adaptive create a structure based on the available
%fields.

[symbolset] = GetDaySymbolSet(date,'discrete')
save date date
save symbolset symbolset
[s] = StructureQuote(symbolset,[date]);

%TODO: investigate why there is two changemarker in had two entries??

%% find symbols that have the changemarker
% [x] = size(s,2);
% for i = 1:x
%     changermarker(i) = s(i).changemarker(1);
% end
% n = find(changermarker==1);

% update structure
new_s = s;

%% find symbols that have the buy
[x] = size(new_s,2);
for i = 1:x
    temp = new_s(i).TradeSignal;
    if isempty(temp)
        tradesignal(i) = NaN;
    else
        tradesignal(i) = cell2mat(temp);
    end
end
n = find(tradesignal==1); %buy = 1; sell = 0;

% update structure
s_rev2 = new_s(n);

%TODO: Don't understand how
%% rank the remaining
[x] = size(s_rev2,2);
if x == 0;
    symbols = struct([]);
    return
end
for i = 1:x
    PercentageChange(i) = s_rev2(i).PercentageChange(1);
end

%rank them in order
rank = sort(PercentageChange,'descend');

%get the required number of investments
i = 1;
while i<x+1
   n = find(rank(i)== PercentageChange);
   [y] = size(n,2); %this cope if two symbols have the same Percentage Change.
   for j = 1:y
    symbols(i) = s_rev2(n(j));
    i = i + 1;
   end
end

% return the required number of investments
% symbols = symbols(1:NumberOfInvestments);

% %remove any negative percentagechange
% [x] = size(symbols,2);
% for i = 1:x
%     PercentageChange = s_rev2(i).PercentageChange(1);
%     if PercentageChange<0
%         
%     end
% end