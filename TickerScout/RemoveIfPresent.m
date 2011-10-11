function [Tables2Search] = RemoveIfPresent(Symbols,tablelist)
% remove tablelist for Symbols if present

%remove symbols which are already in database
[x] = size(Symbols,1);
[y] = size(tablelist,1);

count = 1;
Tables2Search = [];
h = waitbar(0);
for j = 1:x%x %loop over found symbols
    tic
    present = false;
    symbol = lower(Symbols{j,1});
    n = find(strcmp(lower(tablelist),symbol));
    if isempty(n)
       Tables2Search{count,1} = Symbols{j,1};
       count = count + 1;
    end
    t = toc;
    [p] = rem(j,5000)+1;
    estimate = t*x;
    temp(p) = estimate;
    estimate = floor(mean(temp));
    estimate = estimate - estimate*j/x; % seconds
    minutes = estimate/60;
    

    hours = floor(minutes/60);
    minutes = floor(minutes - hours*60);
    seconds = floor(estimate - hours*60*60 - minutes*60);
    
    
    waitbar(j/x,h,['(',num2str(j),' of ',num2str(x),')','   Time Left:',num2str(hours),'h ',num2str(minutes),' m ',num2str(seconds),' s ']);
end