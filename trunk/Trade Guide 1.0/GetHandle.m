function [handle] = GetHandle(h,Name)
%Extract and 
Buttons = get(h,'Children');
x = size(Buttons,1);

%get tags
for i = 1:x    
    Tags{i}  = get(Buttons(i),'tag');
    if strcmp(Tags{i},Name)
       handle = Buttons(i);
    end
end