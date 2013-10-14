%% Read Shares
clear all
close all
display = true;

ExchangeList = { ...
                'American Stock Exchange'; ...
                'Amsterdam Stock Exchange' ; ...  
                'Australian Stock Exchange'   ; ... 
                'Copenhagen Stock Exchange' ; ...    
                'Frankfurt Stock Exchange' ; ...    
                'Lisbon Stock Exchange'  ; ...   
                'London Stock Exchange'   ; ...  
                'Milan Stock Exchange'  ; ...   
                'NASDAQ Stock Exchange'  ; ...   
                'New York Stock Exchange'   ; ...  
                'Oslo Stock Exchange'  ; ...  
                'Paris Stock Exchange'  ; ...  
                'Singapore Stock Exchange'  ; ...   
                'Barcelona Stock Exchange'   ; ...  
                'Stockholm Stock Exchange'  ; ...   
                'Swiss Exchange'    ; ... 
                'Vienna Stock Exchange'  ; ...   
                'Virt-X'};

[x] = size(ExchangeList,1);

NewArray{1,1} = 'Exchange';
NewArray{1,2} = 'NumberPassed';
NewArray{1,3} = 'NumberFailed';
disp(NewArray)
for i = 1:x
    Exchange = ExchangeList{i};
    [symbols] = ReadInstruments('Shares',Exchange);
    % [symbols] = FailedLookUp(symbols);
    Summary = Verify(symbols);
%     [Suffix] = TickerSymbolSuffixLookup(Exchange);
%     SearchForFailed(FailedSymbols,Suffix);
    
    % Report
    NewArray{i+1,1} = ExchangeList{i};
    NewArray{i+1,2} = Summary.CountPass;
    NewArray{i+1,3} = Summary.CountFail;
    if display == true
        disp([NewArray{i+1,1},' ',num2str(NewArray{i+1,2}),' ',num2str(NewArray{i+1,3})]);
    end
end