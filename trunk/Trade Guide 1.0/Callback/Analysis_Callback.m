function [] = Analysis_Callback(handles,ProgramDir)
%
%Written by:    Bryan Taylor
%Date Created:  22nd April 2008
%Date Modified: 22nd April 2008

global savecriteria

handles = get(handles.figure,'UserData')
path = handles.path.savedata;

%% Database Name
String = get(handles.DatabaseSelection.pulldown,'String');
Value = get(handles.DatabaseSelection.pulldown,'Value');
DatabaseName = String{Value};

%% Run Analysis
Stage = get(handles.Stage.pulldown,'Value');
[functions] = StageDeclaration();
[x] = size(functions,1);
try
    output = GuiStruct(Stage).output;
    Inprogress = true;
    ButtonName=questdlg('Data already preset, do you want to overwrite or add to the data?', ...
                        'Table Status', ...
                        'Overwrite','Add','Cancel','Overwrite');
                    
    if strcmpi(ButtonName,'overwrite')
        %% Change headings on table
        Names = feval([functions{Stage},'Fcn'],'ColumnNames');
        IntialiseTable(Names);
    end
catch
    Inprogress = false; 
end
if Inprogress == true;
    output = feval([functions{Stage},'Fcn'],handles,output);
else
    output = feval([functions{Stage},'Fcn'],handles);
end

%% Save Information
tabledata = get(handles.table,'Data');
StageName = functions{Stage};
try 
    path = [path,DatabaseName,'\',StageName,'\'];
    cd(path);
catch
    mkdir(path);
end
SaveFolder = [path,strrep(num2str(now),'.','_')];
save(SaveFolder,'tabledata');
newsavecriteria = {StageName,SaveFolder,now};  % Create new row of detials
if isempty(savecriteria)
savecriteria.simulation_index = [newsavecriteria];    
else
savecriteria.simulation_index = [savecriteria.simulation_index;newsavecriteria]; % Append to list
end