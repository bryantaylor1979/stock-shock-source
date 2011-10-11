function [Exchange] = CatergoryLUT(Cat)
%Find contrast for difference symbols
%
%Written by:    Bryan Taylor
%Date Created:  27th May 2008
switch Cat
    case 'xase ' 
        Exchange = 'American Stock Exchange';
    case 'xams '
        Exchange = 'Amsterdam Stock Exchange';  
    case 'xasx '
        Exchange = 'Australia';  
    case 'xbru '
        Exchange = 'Australian Stock Exchange'; 
    case 'xcse '
        Exchange = 'Copenhagen Stock Exchange';    
    case 'xetr '
        'Frankfurt Stock Exchange'    
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