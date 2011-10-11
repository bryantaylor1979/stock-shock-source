function nodes = myExpfcn(tree, value)

switch lower(value)
    case 'options'
         nodes(1) = uitreenode('descion', 'Descion',[''], true);
         nodes(2) = uitreenode('CalculateStake','Calc Stake',[''],true);
         nodes(3) = uitreenode('DayAssets','Profit Analysis',[''],true);
    otherwise
%          error('Parent tree node value not recognised')   
end