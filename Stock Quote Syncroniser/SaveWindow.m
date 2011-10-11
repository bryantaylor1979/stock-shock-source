function [] = SaveWindow()

global handles
String = get(handles.textbox,'String');

[x,y] = size(String);

[filename, pathname] = uiputfile( ...
       {'*.log';'*.txt';'*.*'}, ...
        'Save as');
fid = fopen([pathname,filename],'wt');
for i =1:x
    fprintf(fid,[String{i},'\n'],i);
end
fclose(fid);