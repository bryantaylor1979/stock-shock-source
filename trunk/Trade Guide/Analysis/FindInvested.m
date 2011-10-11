function [InvestedSymbols] = FindInvested(TradeStructure)
%Find invested symbols

[x] = size(TradeStructure,2);

InvestedSymbols = [];
for i = 1:x
   symbol = TradeStructure(i).symbol;
   if strcmp(TradeStructure(i).action,'Buy')
       InvestedSymbols = [InvestedSymbols;{symbol}];
   else
       InvestedSymbols = removesymbol(InvestedSymbols,{symbol});
   end
end