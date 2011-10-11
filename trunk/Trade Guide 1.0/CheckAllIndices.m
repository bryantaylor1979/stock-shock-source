%% Read Indices
% Read indices from saxo trader
[symbols] = ReadInstruments('Indices');
saxosymbols = symbols; %Saxo Symbol

[symbols] = FailedLookUp(symbols);

%% Check yahoo is available
conn = yahoo;
[x] = size(symbols,1);

Array{1,1} = 'Saxo Symbol'; %Saxo Symbol
Array{1,2} = 'Yahoo Symbol'; %yahoo Symbol
Array{1,3} = 'Status'; %Test Status

h = waitbar(0);
for i = 1:x
    waitbar(i/x,h);
    yahoostr = ['^',strrep(symbols{i},'.I','')];
    try 
        D = FETCH(conn,yahoostr,'open',today-365,today,'m');
        Status = 'PASS'; 
    catch
        Status = 'FAIL';
    end
    Array{i+1,1} = saxosymbols{i};
    Array{i+1,2} = yahoostr; %yahoo Symbol
    Array{i+1,3} = Status; %Test Status
end
disp(Array);
close(h);