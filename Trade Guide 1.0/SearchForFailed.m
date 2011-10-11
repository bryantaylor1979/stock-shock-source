function [] = SearchForFailed(Array,Suffix);
%%

n = find(strcmpi(Array(:,3),'FAIL'));
[NumberFailed] = size(n,1);

h = waitbar(0);
for i = 1:NumberFailed
   disp(Array{i,1})
   text = urlread(['http://uk.finance.yahoo.com/q?s=',Array{i,1},'&m=',Suffix,'&d= ']);
   [a] = strread(text,'%s','delimiter',' '); % split line
   k = size(a,1);
   for l = 1:k
        [attr] = strread(a{l},'%s','delimiter','.'); %split arguments
        m = size(attr,1);
        for q = 1:m
            [attr1,val] = strread(attr{q},'%s%s','delimiter','=');
            if strcmpi(attr1,'sym')
                Array{i,4} = val{1};
            end
        end
   end
end

disp('URL searched symbols:');
disp(Array)