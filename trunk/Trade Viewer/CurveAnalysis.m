function varargout = CurveAnalysis(varargin)
% Graph viewer for local database
%      CURVEANALYSIS, by itself, creates a new CURVEANALYSIS or raises the existing
%      singleton*.
%
%      H = CURVEANALYSIS returns the handle to a new CURVEANALYSIS or the handle to
%      the existing singleton*.
%
%      CURVEANALYSIS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CURVEANALYSIS.M with the given input arguments.
%
%      CURVEANALYSIS('Property','Value',...) creates a new CURVEANALYSIS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before CurveAnalysis_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to CurveAnalysis_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
%Example:
%   Just Type CurveAnalysis in the command prompt.
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2007, CoLogic, Inc

% Edit the above text to modify the response to help CurveAnalysis

% Last Modified by GUIDE v2.5 20-Feb-2007 21:09:07

% Begin initialization code - DO NOT EDIT

% TODO: Allow this to be used for yahoo and bloomberg
% TODO: Get Current Figure Implementation
% TODO: Same axes range option
% TODO: Compile this program.

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @CurveAnalysis_OpeningFcn, ...
                   'gui_OutputFcn',  @CurveAnalysis_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before CurveAnalysis is made visible.
function CurveAnalysis_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to CurveAnalysis (see VARARGIN)

% Choose default command line output for CurveAnalysis
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

clear global fighandles currentfig conn;
IntialiseDatabase;

%load all symbols into pulldown menu
[tablelist] = GetAllTableNames;
set(handles.Symbols,'String',tablelist);

%load all field names into pulldown menu
[fieldnames] = GetAllFieldNames;

%remove generic data
%datenum & symbol
[x] = size(fieldnames,2);
count = 0;
for i = 1:x
   if ~strcmp(fieldnames{1,i},'datenum')
   if ~strcmp(fieldnames{1,i},'symbol')
      count = count + 1;
      new_fieldnames{1,count} =  fieldnames{i};
   end
   end
end

set(handles.Data,'String',new_fieldnames);

% UIWAIT makes CurveAnalysis wait for user response (see UIRESUME)

%Monitor figures
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = CurveAnalysis_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
% varargout{1} = handles.output;


% --- Executes on selection change in Symbols.
function Symbols_Callback(hObject, eventdata, handles)
% hObject    handle to Symbols (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns Symbols contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Symbols


% --- Executes during object creation, after setting all properties.
function Symbols_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Symbols (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in Data.
function Data_Callback(hObject, eventdata, handles)
% hObject    handle to Data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns Data contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Data


% --- Executes during object creation, after setting all properties.
function Data_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on button press in Add.
function Add_Callback(hObject, eventdata, handles)
% hObject    handle to Add (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[symbol,Fieldname,Range] = GetUserInterfaceData(handles);

%get valid handle
global fighandles currentfig;

figure(currentfig);

%find and update fighandles
[x] = size(fighandles,2);
for i = 1:x
    if (fighandles(i).handle == currentfig)
       location = i;
    end
end
string = fighandles(location).legend;
[x] = size(string,1);
fighandles(location).legend = [string;{[symbol,': ',Fieldname]}]

%START get data from database
string = fighandles(location).legend;
[y] = size(string,1);
if y > 2
   error('A maximum of two set of data are allowed on one graph') 
end
data1 = StockQuote(fighandles(location).symbol,fighandles(location).fieldname,Range);
data2 = StockQuote(symbol,Fieldname,Range);
[datenum] = StockQuote(symbol,'datenum',Range);
%END get data from database

[data1] = ConditionArray(data1);
[data2] = ConditionArray(data2);
[datenum] = ConditionArray(datenum);
%UPDATE GRAPH
[AX,H1,H2] = plotyy(datenum,data1,datenum,data2,'plot');
set(get(AX(1),'Ylabel'),'String',fighandles(location).fieldname);
set(get(AX(2),'Ylabel'),'String',Fieldname);
xlabel('date');
datetick(AX(1));
datetick(AX(2));

set(H1,'LineStyle','--');
set(H2,'LineStyle',':'); 

% --- Executes on button press in New.
function New_Callback(hObject, eventdata, handles)
% hObject    handle to New (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global fighandles currentfig

[symbol,Fieldname,Range] = GetUserInterfaceData(handles);

%get data from database
[data] = StockQuote(symbol,Fieldname,Range);
[datenum] = StockQuote(symbol,'datenum',Range);

%note down the created figure details in the global space
if isempty(fighandles)
    x = 0;
else
   [x] = size(fighandles,2);
end
fighandles(x+1).handle = figure;
currentfig = fighandles(x+1).handle;
fighandles(x+1).legend = {[symbol,': ',Fieldname]};
fighandles(x+1).symbol = symbol;
fighandles(x+1).fieldname = Fieldname;

%NOT REQUIRED
% summary of figure handles for debug
fighandles.handle;
%END NOT REQUIRED

%START BUILD GRAPH
set(currentfig,'Name',symbol);
[datenum] = ConditionArray(datenum);
[data] = ConditionArray(data);
plot(datenum,data,'g--');
ylabel(Fieldname);
xlabel('date');
datetick
legend(fighandles(x+1).legend);
%END BUILD GRAPH

%START GUI BEHAVIOUR
set(handles.Add,'Enable','on');
%END GUI BEHAVIOUR

%monitor until figure is closed
fig = fighandles(x+1).handle;
uiwait(fig);
disp('detected figure closing');

%**************************
%START CLOSING FIGURE ACTION
global fighandles; %figurehandles may have change since the can be multiple 
%sessions of this code. Best to update the local variable with the global variable

%remove from figure list
[x] = size(fighandles,2);
count = 0;
for i = 1:x
    if not(fighandles(i).handle == fig)
        disp('the should be displayed twice');
        count = count + 1;
        newfighandles(count).handle = fighandles(i).handle;
    end
end
% reassign the global variable with the correct data
if exist('newfighandles')
    fighandles = newfighandles;
    [x] = size(fighandles,2);
else
    fighandles = [];
    x = 0;
end
disp([num2str(x),' figures now preset']);
%END CLOSING FIHURE ACTION
%*************************

%GUI Actions
if x == 0;
set(handles.Add,'Enable','off');
end



% --- Executes on selection change in Range.
function Range_Callback(hObject, eventdata, handles)
% hObject    handle to Range (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns Range contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Range

[symbol,Fieldname] = GetUserInterfaceData(handles);

% --- Executes during object creation, after setting all properties.
function Range_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Range (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function [symbol,Fieldname,NewRange] = GetUserInterfaceData(handles)
%

%START get GUI data
[Value] = get(handles.Symbols,'Value');
[String] = get(handles.Symbols,'String');
symbol = String{Value};

[Value] = get(handles.Data,'Value');
[String] = get(handles.Data,'String');
Fieldname = String{Value};

[Value] = get(handles.Range,'Value');
[String] = get(handles.Range,'String');
Range = String{Value};
%END get GUI data

%Interpretate Range
switch lower(Range)
    case 'all'
        NewRange = 'all';
    case 'last year'
        NewRange = [today,today-365];
    case 'last month'
        NewRange = [today,today-30];
    case 'last week'
        NewRange = [today,today-7];
    case 'custom'
        
    otherwise
        
end

function [datenum] = ConditionArray(datenum)

if iscell(datenum)
    datenum = cell2mat(datenum);  
end

