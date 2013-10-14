%%
classdef ObjectOrganiser < handle
    properties (SetObservable = true)
        NodeNameSelected 
    end
    properties (Hidden = true)
        struct
        handles
    end
    methods
        function Example(obj)
            %%
            close all
            clear classes
            
            %%
            obj = ObjectOrganiser()
            
            %%
            ObjectInspector(obj)
        end
    end
    methods (Hidden = true)  
        function obj = ObjectOrganiser(varargin)
            %%
            if isempty(varargin)
                Map = 'Released';
            else
                Map = varargin{1};
            end
            MidPoint = 176;
            obj.struct = obj.LUT(Map);
            h = figure( 'NumberTitle',  'off', ...
                        'Name',         'ObjectOrganiser', ...
                        'MenuBar',      'none', ...
                        'Resize',       'off');
            
            root = uitreenode('v0', 'Level1', 'Modules', [], false);
            t = uitree(     'v0',   'Root', root, ...
                            'ExpandFcn',            @obj.myExpfcn, ...  
                            'SelectionChangeFcn',   @obj.SelectionChange, ...
                            'Position',             [0,0,MidPoint,420]);
                        
            obj.handles.figure = h;
            h = uicontrol(  obj.handles.figure, ...
                            'Position',             [MidPoint+3,30,559-MidPoint,390], ...
                            'Style',                'edit', ...
                            'Max',                  2, ...
                            'HorizontalAlignment',  'left');
                        
            obj.handles.ModuleDescription = h;
            obj.handles.Explorer = t;
            
            %%
            h = uicontrol()
            
            %%
            set(h,  'Position', [484,1,77,27], ...
                    'String',   'RUN', ...
                    'TooltipString', 'Run the selected module', ...
                    'Callback', @obj.RUN_Press)
                get(h)
        end
        function RUN_Press(varargin)
            obj = varargin{1};
            disp('hello')
            [GroupName,ModuleName] = obj.FindNode(obj.struct,obj.NodeNameSelected);
            functionName = obj.struct.(GroupName).(ModuleName).functionName;
            OBJ = eval(functionName)
            if obj.struct.(GroupName).(ModuleName).runObjectInspector == true
                ObjectInspector(OBJ)
            end
        end
        function struct = LUT(obj,Map)
            %%
            try
                eval(Map)
            catch
                error('map not recognised')
            end
        end
        function nodes = myExpfcn(varargin)
            disp('hello')
            obj  = varargin{1}
            tree = varargin{2}
            value = varargin{3}
            
            if strcmpi(value,'Level1')
                include_sub_node = false;
                nodes = obj.BuildNodes(obj.struct,include_sub_node)
            else
                include_sub_node = true;
                nodes = obj.BuildNodes(obj.struct.(value),include_sub_node)
                disp('Level2')
            end
        end
        function nodes = BuildNodes(obj,struct,include_sub_node)
            names = fieldnames(struct);
            x = size(names,1);
            for i = 1:x
                nodes(i) = uitreenode('v0', names{i}, names{i}, [], include_sub_node);
            end            
        end
        function SelectionChange(varargin)
            obj = varargin{1};
            tree = varargin{2};
            value = varargin{3};
            value = get(value,'CurrentNode');
            Value = value.getName;
            Num = get(Value,'Bytes');
            String = sprintf('%s',Num);
            obj.NodeNameSelected = String;
            disp('Selection Changed')
            
            [GroupName,ModuleName] = obj.FindNode(obj.struct,obj.NodeNameSelected);
            
            functionName = obj.struct.(GroupName).(ModuleName).functionName
            string = help(functionName);

            set(obj.handles.ModuleDescription,'String',string);
        end
        function [GroupName,ModuleName] = FindNode(obj,struct,NodeNameSelected)
            %% Find Node
            names = fieldnames(struct)
            x = size(names,1)
            for i = 1:x
                GroupName = names{i};
                modules_struct = struct.(GroupName);
                modules_names = fieldnames(modules_struct);
                y = size(modules_names,1);
                for j = 1:y
                    if strcmpi(modules_names(j),NodeNameSelected)
                        ModuleName = modules_names{j};
                        return
                    end
                end
            end            
        end
    end
end