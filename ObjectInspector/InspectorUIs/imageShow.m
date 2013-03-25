classdef imageShow < handle
    properties (SetObservable = true)
        box_enable = true
        box_X_Start = 1655
        box_Y_Start = 1638
        box_X_End = 1709
        box_Y_End = 1686
        Visible = true
    end
    properties (SetObservable = true, Hidden = true)
        image
    end
    properties (Hidden = true)
        handles
    end
    methods
        function Example(obj)
            %%
            close all
            clear classes
            raw = ReadRaw();
            raw.RUN;
            ObjectInspector(raw)
            
            %%
            obj = imageShow('image',raw.imageOUT)
            ObjectInspector(obj)
            
            
        end
    end
    methods (Hidden = true)
        function boxEnableUpdate(varargin)
            %%
            x = 1
            obj = varargin{1};
            if obj.box_enable == 1
                set(obj.handles.rect,'Visible','on')
            else
                set(obj.handles.rect,'Visible','off')
            end
        end
        function obj = imageShow(varargin)
            x = size(varargin,2);
            for i = 1:2:x
               obj.(varargin{i}) =  varargin{i+1};
            end    
            obj.handles.figure = figure(    'Name',         'image Show', ...
                                            'NumberTitle',  'off', ...
                                            'MenuBar','none');
            obj.handles.image = imshow(obj.image)
            obj.DrawRectangles;
            if obj.box_enable == 1
                set(obj.handles.rect,'Visible','on')
            else
                set(obj.handles.rect,'Visible','off')
            end
            addlistener(obj,'box_enable','PostSet',@obj.boxEnableUpdate)
            addlistener(obj,{'box_X_Start','box_Y_Start','box_X_End','box_Y_End'},'PostSet',@obj.boxResize)
            addlistener(obj,'image','PostSet',@obj.updateImage)
            addlistener(obj,'Visible','PostSet',@obj.updateVisible)
            
            obj.FilePullDown;
            obj.MetricPullDown;
        end
        function updateVisible(varargin)
            %%
            obj = varargin{1};
            if obj.Visible == true
                set(obj.handles.figure,'Visible','on')
            else
                set(obj.handles.figure,'Visible','off')
            end
        end
        function updateImage(varargin)
            %%
            obj = varargin{1};
            set(obj.handles.image,'CDATA',obj.image);
        end
        function boxResize(varargin)
            %%
            x = 1;
            obj = varargin{1};
            box = [obj.box_X_Start, obj.box_Y_Start, obj.box_X_End - obj.box_X_Start, obj.box_Y_End - obj.box_Y_Start];
            obj.handles.rect.setPosition(box);
        end
        function DrawRectangles(obj)
            %%
            box = [obj.box_X_Start, obj.box_Y_Start, obj.box_X_End - obj.box_X_Start, obj.box_Y_End - obj.box_Y_Start]
            obj.handles.rect = imrect(gca, box);
            obj.handles.rect.setResizable(false);
        end
        function MetricPullDown(obj)
            %%
            h.parent = uimenu(obj.handles.figure);
            set(h.parent,'Label','Metrics');
            
            % histogram
            h.histogram = uimenu(h.parent,'Label','histogram');
            set(h.histogram,'Callback',@obj.histogram);
            
            % dark mesh plot
            h.DarkMesh = uimenu(h.parent,'Label','DarkMesh')
            set(h.DarkMesh,'Callback',@obj.DarkMesh);
        end
        function FilePullDown(obj)
            %%
            h.parent = uimenu(obj.handles.figure);
            set(h.parent,'Label','File')
            h.Save = uimenu(h,'Label','Save');
            set(h.Save,'Callback',@obj.Save)
        end
        function histogram(varargin)
            %%
            obj = varargin{1}
            disp('hello')
            imageHistogram(obj.image)
        end
        function DarkMesh(varargin)
            %%
            obj = varargin{1};
            objMesh = DarkMeshPlot( 'imageIN',  obj.image);
            obj.ObjectPullDown(objMesh)
        end
        function OpenObjectInspector(varargin)
            obj = varargin{1};
            object = varargin{2}
            ObjectInspector(object);
        end
        function Save(varargin)
            %%
            obj = varargin{1};
            [filename, pathname] = uiputfile( ...
                            {   '*.bmp'; ...
                                '*.gif'; ...
                                '*.hdf'; ...
                                '*.jpeg'; ...
                                '*.pgm'; ...
                                '*.png'; ...
                                '*.pnm'; ...
                                '*.ppm'; ...
                                '*.ras'; ...
                                '*.tiff'; ...
                                '*.xwd'; ...
                                '*.*'}, ...
                            'Save as','Untitled.bmp');
            if ischar(filename)
                file = fullfile(pathname, filename);
                imwrite(obj.image,file);
            end
        end
        function ObjectPullDown(obj,object)
            figHandle = object.handle.figure;
            set(figHandle,'MenuBar','none');
            h.parent = uimenu(figHandle);
            set(h.parent,'Label','Options');
            h.Save = uimenu(h,'Label','Inspect');
            set(h.Save,'Callback',@(x,y)obj.OpenObjectInspector(object));
        end    
    end
end