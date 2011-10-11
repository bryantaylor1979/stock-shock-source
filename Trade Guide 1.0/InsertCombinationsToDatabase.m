function [ output_args ] = InsertCombinationsToDatabase( input_args )
%INSERTCOMBINATIONSTODATABASE Summary of this function goes here
%   Detailed explanation goes here

if debug == true
    [Symbols] = EveryCombinationSymbolsList(2);
else
    [Symbols] = EveryCombinationSymbolsList(2);
    [Symbols2] = EveryCombinationSymbolsList(3);
    [Symbols3] = EveryCombinationSymbolsList(4);
    Symbols = [Symbols;Symbols2;Symbols3];
end