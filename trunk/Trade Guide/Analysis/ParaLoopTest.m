Range = 365*200; %Last 200 years
StartDate = today-Range;
EndDate = today;

[tablelist] = GetAllTableNamesMat();

[x] = size(tablelist,1)

matlabpool open;
h = waitbar(0);
count = 0;
tic
parfor j = 1:x
      drawnow
      YahooBaseSymbol = strrep(tablelist{j},'_','.');
      [data] = fetch(yahoo,YahooBaseSymbol,{'Close','Open','Low','High','Volume'},StartDate,EndDate);
      save(['C:\temp\',YahooBaseSymbol],'data')
end
toc
matlabpool close;