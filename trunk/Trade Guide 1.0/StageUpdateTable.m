function [] = StageUpdateTable(varargin)

ProgramDir = varargin{3};
global h savecriteria

%% Path
h = get(h.figure,'UserData');

%% Database Name
String = get(h.DatabaseSelection.pulldown,'String');
Value = get(h.DatabaseSelection.pulldown,'Value');
DatabaseName = String{Value};
path = [h.path.savedata,DatabaseName];

%% Get Current Stage Name
String = get(h.Stage.pulldown,'String');
Value = get(h.Stage.pulldown,'Value');
Selection = String{Value};

%% Change headings on table

if strcmpi(Selection,'DatabaseViewer_Mat')
    set(h.DatabaseViewer.pulldown,'Enable','on');
    set(h.DatabaseViewer.text,'Enable','on');
    Names = feval([Selection,'Fcn'],'ColumnNames');
    IntialiseTable(Names);
    set(h.toolbars.ConfigMode,'Enable','off');
    feval([Selection,'Fcn']);
    
    cd(path);
    filenames = dir;
    filenames = struct2data(filenames,'name');
    filenames = strrep(filenames,'.mat','');
    [x] = size(filenames,1);
    
    set(h.DatabaseViewer.pulldown,'String',filenames(3:x));
else
    set(h.DatabaseViewer.pulldown,'Enable','off');
    set(h.DatabaseViewer.text,'Enable','off');
    Names = feval([Selection,'Fcn'],'ColumnNames');
    IntialiseTable(Names);
    ConfigPreset = feval([Selection,'Fcn'],'Config');

    if ConfigPreset == false
        set(h.toolbars.ConfigMode,'Enable','off');
    else
        set(h.toolbars.ConfigMode,'Enable','on');
    end

    %% Update Data of table
    try
    [tabledata] = FindLatest(path,Selection);
    if iscell(tabledata)
        set(h.table,'Data',tabledata);
    else
        set(h.table,'Data',[]);
    end
    end
end

