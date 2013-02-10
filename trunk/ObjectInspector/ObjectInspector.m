classdef ObjectInspector < handle
    properties
        handles
    end
    methods
        function Example(obj)
           %%
           close all
           clear classes
           
           %% Single Entry
           handle = Ycbcr2RGB_ColourGamut('Y',0.6);
           obj = ObjectInspector(handle);
           
           %% Multiple Entries        
           csp = RB_Norm_ColourSpaceGen(   'method',                   'direct', ...
                                           'ImageSize',                 256, ...
                                           'ValueSacrifice_Enable',     true, ...
                                           'LumTarget',                 256, ...
                                           'RemoveClipped',             true);
           obj = ObjectInspector(csp);
        end
        function obj = ObjectInspector(ObjHandle)
           %% Vars
           obj.handles.ObjHandle = ObjHandle;
            
            
           %%
           Params = obj.GetParamList();
           FigureHeight = 500;
           obj.GenerateFigure(FigureHeight); %78 old value
           MaxControls = 10;
           Spacing = 22;
           handles = obj.AddAllControls(MaxControls,FigureHeight,Spacing,Params);
        end
    end
    methods %Support
        function RemoveAllControls(obj,handles)
            %% Remove Slithers
            x = size(handles,2)
            for i = 1:x
                obj.deleteEditBox(handles(i))
            end            
        end
        function handles = AddAllControls(obj,MaxControls,FigureHeight,Spacing,Params)
            %% Add all slithers
            
            x = size(Params,1);
            if x > MaxControls
                x = MaxControls;
            end
            for i = 1:x
                handles(i) = obj.addEditBox(Params{i},FigureHeight,Spacing*(i));
            end
        end
        function Params = GetParamList(obj)
            % This function will only return properties that are not
            % hidden. So change the hidden property of the class def if you
            % don't want them to appear. It may be more flexible to add a
            % parameter to hide visible or make hidden properties appear on
            % the GUI. For now it will not be considered. 
            
            %%
            Params = properties(obj.handles.ObjHandle);
        end
        function GenerateFigure(obj,figureHeight)
            %%
            obj.handles.figure = figure;
            set(obj.handles.figure, 'Position',     [0, 0 , 350, figureHeight], ...
                                    'MenuBar',      'none', ...
                                    'Name',         'Object Inspector', ...     
                                    'NumberTitle',  'off');
            movegui(obj.handles.figure,'center'); 
        end
    end
    methods %GUI - Edit Box
        function handle = addEditBox(obj,paramName,FigureHeight,H_StartLoc)
            %%
            mode = 'pixels'; %pixels or normalized
            if strcmpi(mode,'pixels')
                
                height = FigureHeight - H_StartLoc;
                Gap_Border2ParamBox = 8;
                ParameterBoxWidth = 158;
                SlitherHeight = 22;  
                
                % edit box
                EditBoxWidth = 158;
                Gap_ParamBox2EditBox = 0;
                
                % set button
                Gap_EditBox2SetButtom = 0;
                SetButtonWidth = 26;
                
           else
                FigureHeight = 0.706;
                
                height = FigureHeight - H_StartLoc;
                Gap_Border2ParamBox = 0.02;
                ParameterBoxWidth = 0.46;
                SlitherHeight = 0.3;
                
                % edit box
                EditBoxWidth = 0.445;
                Gap_ParamBox2EditBox = 0;
                
                % set button
                SetButtonWidth = 0.07;
                Gap_EditBox2SetButtom = 0;
            end
            
            %%
            Pos.editBox =   [   Gap_Border2ParamBox+ParameterBoxWidth+Gap_ParamBox2EditBox, ...
                                height, ...
                                EditBoxWidth, ...
                                SlitherHeight];
                            
            Pos.paramName = [   Gap_Border2ParamBox, ...
                                height, ...
                                ParameterBoxWidth, ...
                                SlitherHeight];
                            
            Pos.setButton = [   Gap_Border2ParamBox+ParameterBoxWidth+Gap_ParamBox2EditBox+EditBoxWidth+Gap_EditBox2SetButtom, ...
                                height, ...
                                SetButtonWidth, ...
                                SlitherHeight];     
            
            figure( obj.handles.figure )
            % create the popup menu which include all the properties
            h1 = uicontrol( 'Style',                'edit', ...
                            'string',               paramName, ...
                            'Units',                mode, ...
                            'HorizontalAlignment',  'left', ...
                            'Enable',               'inactive', ...
                            'Position',             Pos.paramName);
    
            % create a edit box for you to type the desired value
            h2 = uicontrol( 'Style',                'edit', ...
                            'Units',                mode, ...
                            'HorizontalAlignment',  'left', ...
                            'String',               num2str(obj.handles.ObjHandle.(paramName)), ...
                            'Position',             Pos.editBox);
    
            % create a pushbutton to confirm the assignment
            h3 = uicontrol( 'Style',                'pushbutton', ...
                            'String' ,              'Set', ...
                            'Units',                mode, ...
                            'Callback',             @(x,y)obj.setEditBox(paramName,h2), ...
                            'position',             Pos.setButton);

                        
            handle.Type = 'edit_double';
            handle.ParamName   = h1;
            handle.EditBox     = h2;
            handle.SetButton   = h3;
            
            
            %%
            h = findprop(obj.handles.ObjHandle,paramName);
            if h.SetObservable == false
                error(['Please change "',paramName,'", parameter to SetObservable = true'])
            end
            obj.handles.ObjHandle.addlistener(paramName,'PostSet',@(x,y)obj.updateEditBox(paramName,h2));
            
        end
        function updateEditBox(varargin)
            obj = varargin{1};
            paramName = varargin{2};
            h2 = varargin{3};
            %%
            if ischar(obj.handles.ObjHandle.(paramName))
                set(h2,'String',obj.handles.ObjHandle.(paramName));
            else
                set(h2,'String',num2str(obj.handles.ObjHandle.(paramName)));
            end
        end
        function deleteEditBox(obj,handle)
            %%
            try
            delete(handle.ParamName);
            end
            try
            delete(handle.EditBox);
            end
            try
            delete(handle.SetButton);
            end
        end
        function setEditBox(obj,paramName,handle)
            %%
            Value = get(handle,'String');
            Value2write = str2num(Value);
            if isempty(Value2write)
                Value2write = Value;
            end
            obj.handles.ObjHandle.(paramName) = Value2write;
        end        
    end
end