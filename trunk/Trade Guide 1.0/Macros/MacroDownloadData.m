function [] = MacroDownloadData(obj,event,handles)

global h savecriteria currentdirectory

cd([currentdirectory,'\SaveData\Download'])
[filename, pathname, filterindex] = uigetfile( ...
       {'*.mat','MAT-files (*.mat)'}, ...
        'Pick a file', ...
        'MultiSelect', 'on');
    
[x] = size(filename,2)

% Set Mode
[functions] = StageDeclaration();
Stage = find(strcmpi(functions,'Download'));
set(h.Stage.pulldown,'Value',Stage);
        
for i = 1:x
    load([pathname,filename{i}])

    Names = feval(['DownloadFcn'],'ColumnNames');
    IntialiseTable(Names);
    set(h.table,'Data',java2array(Data));
    
    drawnow;
    output = DownloadRpt(handles.table,false);
    
    NoOfTablesUpdated(i) = output.NoOfTablesUpdated;
    
    name = strrep(filename{i},'Download_','');
    name = strrep(name,'.mat','');
    datenum(i) = str2num(strrep(name,'_','.'));
    
    clear Names Data
end

figure, scatter(datenum,NoOfTablesUpdated)
datetick;
ylabel('No Symbols Updated')
xlabel('Date/Time')