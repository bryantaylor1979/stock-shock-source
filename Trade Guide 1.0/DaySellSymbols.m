function [s_rev2] = DaySellSymbols(symbols,date)

report = true;

% update structure
s_rev2 = struct([]);
if isempty(symbols)  
    return
end
[s] = StructureQuote(symbols,[date]);
new_s = s;

%% find symbols that have the sell signal
[x] = size(new_s,2);
for i = 1:x
    tradesignal(i) = new_s(i).tradesignal(1);
    new_s(i).action = 'Sell';
end
n = find(tradesignal==0); %buy = 1; sell = 0;

% update structure
s_rev2 = new_s(n);

if report == true
    [x] = size(s_rev2,1);
    if x == 1
%         disp('None of the invested symbols required to be sold')
    else
    end
end