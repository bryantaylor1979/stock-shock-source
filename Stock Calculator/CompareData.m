function [Logic] = CompareData(Data1,Data2)

[x1,y1] = size(Data1);
[x2,y2] = size(Data2);

if not(x1 == x2)
   Logic = false;
   return
end
if not(y1 == y2)
   Logic = false;
   return
end

count = 0;
for i = 1:x1
    if strcmp(num2str(Data1(i)),num2str(Data2(i)))
        count = count + 1; 
    else
    end
end

if count == x1
     Logic = true;
else
     Logic = false; 
end