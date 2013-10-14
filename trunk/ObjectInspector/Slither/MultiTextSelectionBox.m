classdef MultiTextSelectionBox < handle
    %TODO: Have a read only mode
    %TODO: Calculate separation make a common class
    %TODO: Total length and proportions
    properties (SetObservable = true)
        Type = 'MultiTextSelection';
        paramName = 'param';
        paramValue = 'Example';
        LUT = {'Example'; ...
               'Example2'};   
        SpaceFromTop = 0;
        SpaceFromLeft = 8;
        
        ParamNameWidth = 158;
        EditBoxWidth = 140;
        SpacerWidth = 18;
        SetButtonWidth = 26;
        
        SlitherHeight = 22;  
    end
    properties (Hidden = true, SetObservable = true)
        Type_LUT = {'MultiTextSelection'; ...
                    'MultiText' ...
                    };
    end
    properties (Hidden = true)
        handles
    end
    methods 
        function Example(obj)
           %%
           close all
           clear classes
           
           %%
           h = figure;
           figure( h );
    
           %%
           handle = MultiTextSelectionBox(  'Type',          'MultiText', ... 
                                            'paramValue',    'Example2' )
                                        
                                        %%
           ObjectInspector(handle)
           
           %%
           handle.LUT = {  'Example1'; ...
                           'Example3'; ...
                           'Example2'};     
                       
           %%
           handle.paramValue = 'Example1';
        end
    end
    methods (Hidden = true) %COMMON
        function obj = MultiTextSelectionBox(varargin)
            %%
            x = size(varargin,2);
            for i = 1:2:x
                obj.(varargin{i}) = varargin{i+1};
            end
            obj.handles.figure = gcf;
            obj.addMultiTextSelectionBox(  obj.paramName);
            
            %%
            params = {	'SpaceFromTop'; ...
                        'SpaceFromLeft'; ...
                        
                        'ParamNameWidth'; ...
                        'EditBoxWidth'; ...
                        'SpacerWidth'; ...
                        
                        'SlitherHeight' ... 
                        };
            obj.addlistener( params, 'PostSet', @obj.Update);   
            if strcmpi(obj.Type,'MultiTextSelection')
                obj.addlistener( 'LUT',  'PostSet', @obj.UpdateLUT);
            end
            obj.addlistener( 'paramValue',  'PostSet', @obj.paramValueUpdate);
            obj.addlistener( 'paramName',  'PostSet', @obj.paramNameUpdate);
        end
        function Pos = CalculatePos(obj)
            Position = get(obj.handles.figure,'Position');
            height = Position(4) - obj.SpaceFromTop - obj.SlitherHeight;
            
            Pos.paramName = [   obj.SpaceFromLeft, ...
                                height, ...
                                obj.ParamNameWidth, ...
                                obj.SlitherHeight];      
                            
            Pos.editBox2 =   [  obj.SpaceFromLeft+obj.ParamNameWidth, ...
                                height, ...
                                obj.SpacerWidth, ...
                                obj.SlitherHeight];
                            
            %
            Pos.editBox =   [   obj.SpaceFromLeft + obj.ParamNameWidth + obj.SpacerWidth, ...
                                height, ...
                                obj.EditBoxWidth, ...
                                obj.SlitherHeight];
                            
            Pos.setButton = [   obj.SpaceFromLeft + obj.ParamNameWidth + obj.SpacerWidth + obj.EditBoxWidth, ...
                                height, ...
                                obj.SetButtonWidth, ...
                                obj.SlitherHeight];                                  
        end
    end
    methods (Hidden = true) %UPDATES
        function paramValueUpdate(varargin)
            %%
            obj = varargin{1};
            disp('paramValueUpdate')
            Value = find(strcmpi(obj.LUT,obj.paramValue));
            if isempty(Value)
               error('value not found in look-up table') 
            end
            set(obj.handles.EditBox,  'Value',    Value);
        end
        function paramNameUpdate(varargin)
            %%
            obj = varargin{1};
            disp('paramNameUpdate')
            set(obj.handles.ParamName,  'String',    obj.paramName);
        end
        function UpdateLUT(varargin)
            %%
            obj = varargin{1};
            Value = get(obj.handles.EditBox,'Value');
            
            % ensure invalued values don't occur. 
            x = size(obj.LUT,1);
            if Value > x
                Value = x;
            end
            
            set(obj.handles.EditBox,    'String',   obj.LUT, ...
                                        'Value',    Value);
        end
        function Update(varargin)
            disp('helloe')
            obj = varargin{1};
            Pos = obj.CalculatePos();
            set(obj.handles.ParamName   ,'Position',Pos.paramName);
            set(obj.handles.Gap         ,'Position',Pos.editBox2);
            set(obj.handles.EditBox     ,'Position',Pos.editBox);
        end
        function pulldownUpdate(varargin)
            %%
            obj = varargin{1};
            LUT =   get(obj.handles.EditBox,    'String');
            Value = get(obj.handles.EditBox,    'Value');
            obj.paramValue = LUT{Value};
        end
    end
    methods (Hidden = true)
        function addMultiTextSelectionBox(obj,paramName)
            %%
            Pos = obj.CalculatePos();
            

            obj.handles.ParamName = obj.addParamName(paramName,Pos.paramName);
            obj.handles.Gap = obj.addSpacerBox(Pos.editBox2);

            if strcmpi(obj.Type,'MultiTextSelection')
                obj.handles.EditBox = obj.addValueBox(Pos,'popupmenu',obj.paramValue); 
                obj.handles.Button = [];
            else
                obj.handles.EditBox = obj.addValueBox(Pos,'edit','[Multi Text]');
                obj.handles.Button = obj.addMultiTextButton(paramName,Pos.setButton);
            end
    

            obj.handles.ParmeterName = obj.paramValue;             
            obj.handles.Type = 'edit_double';
            obj.handles.SetButton   = 1;            
        end
        function h = addParamName(obj,paramName,Pos)
            % create the popup menu which include all the properties
            h = uicontrol( 'Style',                'edit', ...
                            'string',               paramName, ...
                            'Units',                'pixels', ...
                            'HorizontalAlignment',  'left', ...
                            'Enable',               'inactive', ...
                            'Position',             Pos);            
        end
        function h = addSpacerBox(obj,Pos)
        	h =  uicontrol( 'Style',                'edit', ...
                            'Units',                'pixels', ...
                            'HorizontalAlignment',  'left', ...
                            'Enable',               'inactive', ...
                            'String',               '', ...
                            'Position',             Pos);
        end
        function h = addValueBox(obj,Pos,type,Value)
            % create a edit box for you to type the desired value
            n = find(strcmpi(obj.paramValue,obj.LUT));
            h  = uicontrol( 'Style',                type, ...
                            'Units',                'pixels', ...
                            'HorizontalAlignment',  'left', ...
                            'String',               Value, ...
                            'Position',             Pos.editBox, ...
                            'Value',                n);
           if strcmpi(type,'popupmenu')         
               set(h,       'String',   obj.LUT, ...
                            'Callback', @obj.pulldownUpdate);
           end        
        end
    end
    methods (Hidden = true) % Add botton types
        function h = addMultiTextButton(obj,paramName,Pos)
            filename = fullfile( matlabroot,'toolbox','matlab','icons','pageicon.gif');
            [X map] = imread(filename);
            icon = ind2rgb(X,map);
            
            % create a pushbutton to confirm the assignment
            h  = uicontrol( 'Style',                'pushbutton', ...
                            'CDATA' ,               icon, ...
                            'Units',                'pixels', ...
                            'Callback',             @(x,y)obj.runMultiTextBox(paramName), ...
                            'position',             Pos);
        end
        function runMultiTextBox(obj,paramName)
            %%
            obj = uiMultiText('String',obj.LUT);
        end        
    end
end