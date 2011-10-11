function [Symbols,Category,Type] = ReadInstruments(varargin);
%Read Instruments for saxo text file.
%
%A list of CFD's symbols names
%
%Example:- All symbols
%   [symbols] = ReadInstruments('All');
% 
%Example:- Contracts for Difference Symbols from American Stock Exchange
%   [symbols] = ReadInstruments('ContractsForDifference','American');
%
%Example:- Contracts for Difference Symbols
%   [symbols] = ReadInstruments('Shares');
%
%Example:- Contracts for Difference Symbols
%   [symbols] = ReadInstruments('Indices');
%
%Written by:    Bryan Taylor
%Date Created:  27th May 2008
%Date Modified: 27th May 2008

% [line]=textread('Shares.txt','%s%*[^\n]','delimiter','');
% 
% [x] = size(line,1);

fid = fopen('Shares.txt');
N = textscan(fid,'%s%s%s','delimiter',':()');

Mode = varargin{1};

Symbols = N{1};
Category = N{2};
Type = N{3};

switch Mode
    case 'Shares'
        n = find(strcmp('Shares',Type));
    case 'ContractsForDifference'
        n = find(strcmp('ContractsForDifference',Type));
    otherwise %Indices
        n = find(strcmp('Indices',Category)); 
end
Symbols = Symbols(n);
Category = Category(n);
Type = Type(n);

[x] = size(varargin,2);
if x == 2
    Cat = varargin{2};
    Category = Category(n);
    [symbols,Suffix] = FindCFDCat(symbols,Category,Cat);
end          

function [symbols,Suffix] = FindCFDCat(symbols,Category,Cat)
%Find contrast for difference symbols
%
%Written by:    Bryan Taylor
%Date Created:  27th May 2008
switch Cat
    case 'American Stock Exchange'
        n = find(strcmp('xase ',Category));
    case 'Amsterdam Stock Exchange'   
        n = find(strcmp('xams ',Category));
    case 'Australia'   
        n = find(strcmp('xasx ',Category));
    case 'Australian Stock Exchange'   
        n = find(strcmp('xbru ',Category));
    case 'Copenhagen Stock Exchange'    
        n = find(strcmp('xcse ',Category));
    case 'Frankfurt Stock Exchange'    
        n = find(strcmp('xetr ',Category));
    case 'Helsinki'    %Not Found
        n = find(strcmp('xhel ',Category));
    case 'Lisbon Stock Exchange'    
        n = find(strcmp('xlis ',Category));
    case 'London Stock Exchange'    
        n = find(strcmp('xlon ',Category));
    case 'Milan Stock Exchange'    
        n = find(strcmp('xmil ',Category));
    case 'NASDAQ Stock Exchange'    
        n = find(strcmp('xnas ',Category));
    case 'New York Stock Exchange'    
        n = find(strcmp('xnys ',Category));
    case 'Oslo Stock Exchange'    
        n = find(strcmp('xosl ',Category));
    case 'Paris Stock Exchange'    
        n = find(strcmp('xpar ',Category));
    case 'Singapore Stock Exchange'    
        n = find(strcmp('xses ',Category));
    case 'Barcelona Stock Exchange'    
        n = find(strcmp('xmce ',Category));
    case 'Stockholm Stock Exchange'    
        n = find(strcmp('xome ',Category));
    case 'Swiss Exchange'    
        n = find(strcmp('xswx ',Category));
    case 'Tokyo'    %Not found
        n = find(strcmp('xtks ',Category));
    case 'Vienna Stock Exchange'    
        n = find(strcmp('xwbo ',Category));
    case 'Virt-X'    
        n = find(strcmp('xvtx ',Category));
    otherwise
end
symbols = symbols(n);
Category = Category(n);
Type = Type(n);

[Suffix] = TickerSymbolSuffixLookup(Cat);

%Add suffix to the end of the symbol
[x] = size(symbols,1);
if not(strcmpi(Suffix,''));
    Suffix = ['.',Suffix];
else
    Suffix = Suffix;
end
for i = 1:x
    symbols{i} = [symbols{i},Suffix];
end       