function [] = Analysis(handles)
%Written by:    Bryan Taylor
%Date Created:  22nd April 2008
%Date Modified: 22nd April 2008

global h settings savecriteria

%% Run Analysis
Stage = get(h.Stage.pulldown,'Value');
if Stage == 1; 
else
GuiStruct = savecriteria.GuiStruct;
end

[functions] = StageDeclaration();
[x] = size(functions,1);
try
    output = GuiStruct(Stage).output
    Inprogress = true;
catch
    Inprogress = false; 
end
if Inprogress == true;
    output = feval([functions{Stage},'Fcn'],handles,output);
else
    output = feval([functions{Stage},'Fcn'],handles);
end

%% Save Information
GuiStruct(Stage).tabledata = get(h.table,'Data');
GuiStruct(Stage).stagename = functions{Stage};
GuiStruct(Stage).output = output;
savecriteria.GuiStruct = GuiStruct;
savecriteria.stage = Stage;
savecriteria.currentstagename = functions{Stage}; 

%% Move tool to next stage
if Stage == x
    Stage = Stage - 1;
end
set(h.Stage.pulldown,'Value',Stage+1); %move the tool onto the next stage