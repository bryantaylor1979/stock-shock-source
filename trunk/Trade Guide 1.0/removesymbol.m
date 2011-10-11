function [big_array] = removesymbol(array1,array2)
% remove small array from the big symbol array
% order doesn't matter.
% input array must be column-wise


[x] = size(array1,1);
[y] = size(array2,1);

%get location
% if y>x
%    small_array = array1;
%    big_array = array2;
% else
   small_array = array2;
   big_array = array1;
% end

[x] = size(small_array,1);
[y] = size(big_array,1);
k = 1;

for i = 1:x %first symbol to remove
    n = find(not(strcmp(small_array(i),big_array)));
    big_array = big_array(n);
end

