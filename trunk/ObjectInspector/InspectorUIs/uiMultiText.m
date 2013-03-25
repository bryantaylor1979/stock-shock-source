classdef uiMultiText < handle
    properties
        String = {  'Test1'; ...
                    'Test2'}
    end
    properties (Hidden = true)
        handles
    end
    methods
        function Example(obj)
           %%
           close all
           clear classes
           obj = uiMultiText;    
        end
    end
    methods (Hidden = true)
        function obj = uiMultiText(varargin)
            %%
            x = size(varargin,2);
            for i = 1:2:x
               obj.(varargin{i}) =  varargin{i+1};
            end 
            
            %%
            obj.handles.figure = figure(    'MenuBar','none', ...
                                            'Name', 'uiMultiText', ...
                                            'NumberTitle', 'off', ...
                                            'ResizeFcn',@obj.Resize);
            Position = get(obj.handles.figure,'Position');
            Position(3) = 207;
            Position(4) = 116;
            set(obj.handles.figure,'Position',Position);
            
            Position = get(obj.handles.figure,'Position');
            Position(1) = 0;
            Position(2) = 0;

            obj.handles.textbox = uicontrol(    'String',obj.String, ...
                                                'Style','listbox', ...
                                                'Position',Position);
        end
        function Resize(varargin)
            obj = varargin{1}
            disp('hello')
            Position = get(obj.handles.figure,'Position');
            Position(1) = 0;
            Position(2) = 0;
            try
            set(obj.handles.textbox,'Position',Position);
            end
        end
    end
end