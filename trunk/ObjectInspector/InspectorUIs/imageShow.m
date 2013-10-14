classdef imageShow < handle
    % IMAGESHOW
    % =========
    %
    % Description
    % Load images and run metrics. Supports most images types including
    % raws
    %
    % Sub-Components: 
    properties (SetObservable = true)
        ImageName = ''; % add image name and it will appear on the figure name
        box_enable = false
        box_X_Start = 1655
        box_Y_Start = 1638
        box_X_End = 1709
        box_Y_End = 1686
        Visible = true
        LineMoving = false;
        LinePos
        Intial_Zoom_Factor = 1;
    end
    properties (SetObservable = true)
        imageOUT
        imageOUT_cropped
        imageOUT_line
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
            close all
            clear classes
            
            %%
            file = 'P:\imx175\output\VersionsOnDatabase\BRCM_Sim\auto\2013-03-26_Samsung_1830_01_Baffin_DL_bayer.bmp';
            raw = ReadImage('FileName',file)
            raw.RUN;
%             ObjectInspector(raw);
            
            %% Example of running wb debug information
            file = 'C:\Users\bryant\Desktop\Compare\20130310_101951_v4_smallstats.bmp';
            raw = ReadImage('FileName',file)
            raw.RUN;
            
            %% Nearest
            raw.imageOUT(:,:,1) = raw.imageOUT(:,:,1).*1.0253;
            raw.imageOUT(:,:,1) = raw.imageOUT(:,:,1).*1.0366;
            
            %% Bi-Linear
            raw.imageOUT(:,:,1) = raw.imageOUT(:,:,1).*1.0218;
            raw.imageOUT(:,:,1) = raw.imageOUT(:,:,1).*1.0365;
            
            %%
            obj = imageShow(    'imageOUT', raw.imageOUT, ...
                                'ImageName',file);
                            
            %%
            raw = ReadImage()
            
            %%
            methods(obj.handles.scrollpanel);
            
            %%
            obj = imageShow('imageOUT',raw.imageOUT,'ImageName',file);
            ObjectInspector(obj)
            
            %%
            ObjectInspector(obj)
            
            %%
            obj.imageOUT = raw.imageOUT;
        end
    end
    methods (Hidden = true)
        function obj = imageShow(varargin)
            x = size(varargin,2);
            for i = 1:2:x
               obj.(varargin{i}) =  varargin{i+1};
            end 

            addlistener(obj,'ImageName','PostSet',@obj.updateImageName);
            
            obj.InitGUI();
        end
        function InitGUI(obj)
            if isempty(obj.ImageName)
                figureName =  'image Show';
            else
                figureName =  ['image Show - ',obj.ImageName];
            end
            obj.handles.figure = figure(    'Name',         figureName, ...
                                            'NumberTitle',  'off', ...
                                            'ResizeFcn',    @obj.Resize, ...
                                            'MenuBar',      'none', ...
                                            'Visible',      'off');

            if obj.imageOUT.fsd == 1023 %10bit data stretched to 16bit. 
                image = obj.imageOUT.image;
                image( image > obj.imageOUT.fsd ) = obj.imageOUT.fsd;
                image( image < 0.0 ) = 0.0;
                image = uint16(double(image)*2^6);
            end
            obj.handles.image = imshow(image);
            obj.imageOUT_cropped = obj.imageOUT;
            
            obj.AddScrollPanel();
            obj.handles.impixelinfo = impixelinfo();
            
            
            obj.BoxSelection();
            obj.FilePullDown();
            obj.MetricPullDown();
            obj.DebugPullDown();
            obj.PipeLineView_PullDown();
            
            obj.AddMagBox();
            obj.AddToolBar();
            set(obj.handles.figure,'Visible','on');            
        end
        function DetectMouseState(varargin)
            %%
            obj = varargin{1};
            
            %%
            disp('Button down fcn')
            disp('end')
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
        function updateImageName(varargin)
            %%
            obj = varargin{1};
            if isempty(obj.ImageName)
                figureName =  'image Show';
            else
                figureName =  ['image Show - ',obj.ImageName];
            end
            set(obj.handles.figure,'Name',figureName);
        end
        function updateImage(varargin)
            %%
            obj = varargin{1};
            set(obj.handles.image,'CDATA',obj.imageOUT);
        end
        function FilePullDown(obj)
            %%
            h.parent = uimenu(obj.handles.figure);
            set(h.parent,'Label','File');
            
            h.Save = uimenu(h.parent,'Label','Save');
            set(h.Save,'Callback',@obj.Save);
            
            h.Load = uimenu(h.parent,'Label','Load');
            set(h.Load,'Callback',@obj.LoadImage);
        end
        function OpenObjectInspector(varargin)
            obj = varargin{1};
            object = varargin{2};
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
                imwrite(obj.imageOUT,file);
            end
        end  
        function LoadImage(varargin)
            %%
            obj = varargin{1};
            
            PWD = pwd;
            if not(isempty(obj.ImageName))
                [path, filename] = fileparts(obj.ImageName);
                cd(path);
            end
            
            [filename, pathname, filterindex] = uigetfile( ...
               {'*.bmp;*.jpg;*.pgm;*.png;*.raw', 'All Image Files (*.bmp, *.jpg, *.pgm, *.png, *.raw)';
                '*.bmp',    'Bitmap (*.bmp)'; ...
                '*.jpg',    'Jpeg (*.jpg)'; ...
                '*.pgm',    'Pgm (*.pgm)'; ...
                '*.png',    'Png (*.png)'; ...
                '*.raw',    'Raw (*.raw)'; ...
                '*.*',      'All Files (*.*)'}, ...
                'Pick a file');
            if filterindex == 0
                disp('user has cancelled') 
                return 
            end
            [~,~,ext] = fileparts(filename);
            if strcmpi(ext,'.raw')
                disp('load raw image')
                %%
                raw = ReadRaw('FileName',fullfile(pathname,filename));
                raw.RUN;
                obj.imageOUT = raw.imageOUT;
            else
                obj.imageOUT =  imread([pathname,filename]);
            end
            try
            cd(PWD);
            obj.ImageName = fullfile(pathname,filename);
            end
            
            %%
            close(obj.handles.figure)
            obj.InitGUI();
        end
    end
    methods (Hidden = true) %Visible draggable box
        function BoxSelection(obj)
            obj.DrawRectangles;
            if obj.box_enable == 1
                set(obj.handles.rect,'Visible','on');
            else
                set(obj.handles.rect,'Visible','off');
            end
            addlistener(obj,'box_enable','PostSet',@obj.boxEnableUpdate);
            addlistener(obj,{'box_X_Start','box_Y_Start','box_X_End','box_Y_End'},'PostSet',@obj.boxResize);
            addlistener(obj,'imageOUT','PostSet',@obj.updateImage);
            addlistener(obj,'Visible','PostSet',@obj.updateVisible);  
        end
        function boxEnableUpdate(varargin)
            %%
            obj = varargin{1};
            if obj.box_enable == 1
                set(obj.handles.rect,'Visible','on')
                obj.handles.rect.setResizable(false);
            else
                set(obj.handles.rect,'Visible','off')
                obj.handles.rect.setResizable(false);
            end
        end
        function DrawRectangles(obj)
            %%
            box = [obj.box_X_Start, obj.box_Y_Start, obj.box_X_End - obj.box_X_Start, obj.box_Y_End - obj.box_Y_Start];
            obj.handles.rect = imrect(gca, box);
            obj.handles.rect.setResizable(false);
            obj.handles.rect.setPositionConstraintFcn(@obj.PositionConstraint);
        end
        function boxResize(varargin)
            %%
            obj = varargin{1};
            box = [obj.box_X_Start, obj.box_Y_Start, obj.box_X_End - obj.box_X_Start, obj.box_Y_End - obj.box_Y_Start];
            obj.handles.rect.setPosition(box);
        end
        function constrained_position =  PositionConstraint(varargin)
           obj = varargin{1};
           constrained_position = [obj.box_X_Start, obj.box_Y_Start, obj.box_X_End - obj.box_X_Start, obj.box_Y_End - obj.box_Y_Start];
        end
    end
    methods (Hidden = true) %Zoom tool bar
        function ZoomIn(varargin)
            %%
            obj = varargin{1};
            Step = 0.1;
            Mag = obj.handles.zoomapi.getMagnification();
            obj.handles.zoomapi.setMagnification(Mag+Step);
        end
        function ZoomOut(varargin)
            %%
            obj = varargin{1};
            Step = 0.1;
            Mag = obj.handles.zoomapi.getMagnification();
            obj.handles.zoomapi.setMagnification(Mag-Step)      ;      
        end
    end
    methods (Hidden = true) %imshow features
        function AddScrollPanel(obj)
            %%
            obj.handles.scrollpanel = imscrollpanel(obj.handles.figure,obj.handles.image);
            
            %%
            Org_Position = get(obj.handles.scrollpanel,'Position');
            Position = Org_Position;
            Border = 0.025;
            Position(2) = Org_Position(2)+Border;
            Position(4) = Org_Position(4)-Border;
            set(obj.handles.scrollpanel,'Position',Position); 
            
            obj.handles.zoomapi = iptgetapi(obj.handles.scrollpanel);
            obj.handles.zoomapi.setMagnification(obj.Intial_Zoom_Factor);
        end
        function AddMagBox(obj)
            obj.handles.hMagBox = immagbox(obj.handles.figure,obj.handles.image);
            pos = get(obj.handles.hMagBox,'Position');
            FigPos = get(obj.handles.figure,'Position');
            set(obj.handles.hMagBox,'Position',[FigPos(3)-59 2 pos(3) pos(4)]); 
        end
        function Resize(varargin)
            try
            obj = varargin{1};
            pos = get(obj.handles.hMagBox,'Position');
            FigPos = get(obj.handles.figure,'Position');
            set(obj.handles.hMagBox,'Position',[FigPos(3)-59 2 pos(3) pos(4)]); 
            end
        end
    end
    methods  (Hidden = true) %METRIC (Hidden = true)
        function HSV_plot(varargin)
           obj = varargin{1};
           object = HSV_viewer('InputObject',obj);
           object.imageIN = obj.imageOUT_cropped;
           object.RUN
           obj.ObjectPullDown(object)
        end
        function MetricPullDown(obj)
            %%
            h.parent = uimenu(obj.handles.figure);
            set(h.parent,'Label','Metrics');
            
            % histogram
            h.histogram = uimenu(h.parent,'Label','Histogram');
            set(h.histogram,'Callback',@obj.histogram);
            
            % wb_stats_prediction
            h.wb_stats_prediction = uimenu(h.parent,'Label','wb_stats_prediction');
            set(h.wb_stats_prediction,'Callback',@obj.wb_stats_prediction_Callback);
            
            % pdf_map_detection
            h.wb_stats_prediction = uimenu(h.parent,'Label','pdf_map_detection');
            set(h.wb_stats_prediction,'Callback',@obj.pdf_map_detection_Callback);
            
            % rb Norm
            h.rbNorm = uimenu(h.parent,'Label','rbNorm');
            set(h.rbNorm,'Callback',@obj.rbNorm_Callback);
            
            % dark mesh plot
            h.SurfacePlot = uimenu(h.parent,'Label','SurfacePlot');
            set(h.SurfacePlot,'Callback',@obj.SurfacePlot);
            
            % hsv plo
            h.HSV_plot = uimenu(h.parent,'Label','HSV_plot');
            set(h.HSV_plot,'Callback',@obj.HSV_plot);
            
            % pixel profile
            h.pixel_profile = uimenu(h.parent,'Label','Pixel Profile');
            set(h.pixel_profile,'Callback',@obj.PixelProfile);

            h.KTouch_LensShading = uimenu(h.parent,'Label','KTouch LensShading');
            set(h.KTouch_LensShading,'Callback',@obj.KTouch_LensShading);

        end
        function histogram(varargin)
            %%
            obj = varargin{1};
            object = imageHistogram('InputObject',obj);
            object.imageIN = obj.imageOUT_cropped;
            object.RUN
            obj.ObjectPullDown(object)
%             obj.ObjectPullDown(hist)
        end
        function rbNorm_Callback(varargin)
            %%
            obj = varargin{1};
            object = PDF('InputObject',obj);
            object.imageIN = obj.imageOUT_cropped;
            object.RUN
            obj.ObjectPullDown(object)
        end
        function wb_stats_prediction_Callback(varargin)
            %%
            obj = varargin{1};
            disp('hello')
            object = wb_stats_prediction('InputObject',obj);
            object.imageIN = obj.imageOUT;
            object.RUN
            obj.ObjectPullDown(object)
%             obj.ObjectPullDown(hist)
        end
        function pdf_map_detection_Callback(varargin)
            %%
            obj = varargin{1};
            disp('hello')
            object = PDF_DetectionMap('InputObject',obj);
            object.imageIN = obj.imageOUT;
            object.RUN
            obj.ObjectPullDown(object)
%             obj.ObjectPullDown(hist)
        end
        function SurfacePlot(varargin)
            %%
            obj = varargin{1};
            objMesh = SurfacePlot(         'imageIN',  obj.imageOUT);
%             obj.ObjectPullDown(objMesh)
        end
        function KTouch_LensShading(varargin)
            obj = varargin{1};
            objLS = LS_Metric('imageIN',obj.imageOUT); 
            objLS.RUN();
            ObjectInspector(objLS); 
        end
        function PixelProfile(varargin)
            obj = varargin{1};
            objPixelProfile = PixelProfilePlot( 'InputObject',obj);
            objPixelProfile.imageIN = obj.imageOUT_line;
            objPixelProfile.RUN;
            obj.ObjectPullDown(objPixelProfile);
            obj.handles.pp = objPixelProfile;
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
    methods (Hidden = true) %DEBUG
        function DebugPullDown(obj)
            h.parent = uimenu(obj.handles.figure);
            set(h.parent,'Label','Debug');   
            
            %% White Balance
            h.whitebalance = uimenu(h.parent,'Label','White Balance');
            obj.BuildWhiteBalancePullDown(h);
            
            %% Lens Shading
            h.lenshading = uimenu(   h.parent, ...
                                    'Label','Lens Shading');
            obj.BuildLensShadingPullDown(h);
        end
        function BuildLensShadingPullDown(obj,h)
            h.LS_SurfacePLot = uimenu(h.lenshading,'Label','Applied LS Surface Plot');
            set(h.LS_SurfacePLot,'Callback',@obj.LS_SurfacePLot_RUN);
        end
        function LS_SurfacePLot_RUN(varargin)
            obj = varargin{1};
            disp('LS hello') 
            [PATH,NAME,EXT] = fileparts(obj.ImageName);
            filename = [NAME,'.sim_log.txt']
            
            LSV = LensShadingViewer(    'Path',PATH, ...
                                        'filename',filename);
            LSV.RUN;
        end
        function BuildWhiteBalancePullDown(obj,h)
            %
            Exists = obj.ColourWeightPlotter_Check(0,'op_pdf_colours_curve');
            
            %
            if Exists == true
                h.colourweight = uimenu(h.whitebalance, 'Label','colour weight plots', ...
                                                        'Enable','on');
            else
                h.colourweight = uimenu(h.whitebalance, 'Label','colour weight plots', ...
                                                        'Enable','off');
            end
            
            % op_pdf_colours_curve0
            h.op_pdf_colours_curve0 = uimenu(h.colourweight,'Label','op_pdf_colours_curve0');
            set(h.op_pdf_colours_curve0,'Callback',@(x,y)obj.ColourWeightPlotter_RUN(0,'op_pdf_colours_curve'));
            
            % op_pdf_colours_curve1
            h.op_pdf_colours_curve1 = uimenu(h.colourweight,'Label','op_pdf_colours_curve1');
            set(h.op_pdf_colours_curve1,'Callback',@(x,y)obj.ColourWeightPlotter_RUN(1,'op_pdf_colours_curve'));            
            
            % op_colour_hist_curve0
            h.op_colour_hist_curve0 = uimenu(h.colourweight,'Label','op_colour_hist_curve0');
            set(h.op_colour_hist_curve0,'Callback',@(x,y)obj.ColourWeightPlotter_RUN(0,'op_colour_hist_curve'));
            
            % op_pdf_colours_curve1
            h.op_colour_hist_curve1 = uimenu(h.colourweight,'Label','op_colour_hist_curve1');
            set(h.op_colour_hist_curve1,'Callback',@(x,y)obj.ColourWeightPlotter_RUN(1,'op_colour_hist_curve'));
            
            % op_weighted_colours_curve0
            h.op_weighted_colours_curve0 = uimenu(h.colourweight,'Label','op_weighted_colours_curve0');
            set(h.op_weighted_colours_curve0,'Callback',@(x,y)obj.ColourWeightPlotter_RUN(0,'op_weighted_colours_curve'));
            
            % op_weighted_colours_curve1
            h.op_weighted_colours_curve1 = uimenu(h.colourweight,'Label','op_weighted_colours_curve1');
            set(h.op_weighted_colours_curve1,'Callback',@(x,y)obj.ColourWeightPlotter_RUN(1,'op_weighted_colours_curve'));
            
            
            
            
            %% op_weighted_colours_curve1
            Exists = obj.wb_stats_image_Check();
            if Exists == true
            h.wb_stats_image = uimenu(h.whitebalance,   'Label',    'wb_stats_image', ...
                                                        'Enable',   'on', ...
                                                        'Callback', @obj.wb_stats_image_RUN);
            else
            h.wb_stats_image = uimenu(h.whitebalance,   'Label',    'wb_stats_image', ...
                                                        'Enable',   'off', ...
                                                        'Callback', @obj.wb_stats_image_RUN);    
            end          
            
            %% op_weighted_colours_curve1
            h.wb_stats_image_from_tiff = uimenu(h.whitebalance,'Label','wb_stats_image_from_tiff');
            set(h.wb_stats_image_from_tiff, 'Callback',@obj.wb_stats_calc_from_tiff_RUN);     
            
            %% plotAWB Scatter3D
            h.Scatter3D = uimenu(h.whitebalance,'Label','Scatter3D');
            set(h.Scatter3D,'Callback',@(x,y)obj.plotAWBDebug_RUN('Scatter3D'));
            
            %% plotAWB Surface3D
            h.Surface3D = uimenu(h.whitebalance,'Label','Surface3D');
            set(h.Surface3D,'Callback',@(x,y)obj.plotAWBDebug_RUN('Surface3D'));
            
            %% plotAWB ContourPlot_Posteriors
            h.ContourPlot_Posteriors = uimenu(h.whitebalance,'Label','ContourPlot_Posteriors');
            set(h.ContourPlot_Posteriors,'Callback',@(x,y)obj.plotAWBDebug_RUN('ContourPlot_Posteriors'));
            
            %% plotAWB ContourPlot_Priors
            h.ContourPlot_Priors = uimenu(h.whitebalance,'Label','ContourPlot_Priors');
            set(h.ContourPlot_Priors,'Callback',@(x,y)obj.plotAWBDebug_RUN('ContourPlot_Priors'));
            
            %% Grids
            h.p_t_prior.grids = uimenu(h.whitebalance,'Label','p_t_prior.grids');
            set(h.p_t_prior.grids,'Callback',@(x,y)obj.p_t_prior_RUN('grids',NaN));   
            
            %% Scatter
            h.p_t_prior.scatters = uimenu(h.whitebalance,'Label','p_t_prior.scatters');
            set(h.p_t_prior.scatters,'Callback',@(x,y)obj.p_t_prior_RUN('scatters',NaN));   
            
            %% Grid 0
            h.p_t_prior.grid_0 = uimenu(h.whitebalance,'Label','p_t_prior.grid_0');
            set(h.p_t_prior.grid_0,'Callback',@(x,y)obj.p_t_prior_RUN('grid',0));        
            
            %% Grid 1
            h.p_t_prior.grid_1 = uimenu(h.whitebalance,'Label','p_t_prior.grid_1');
            set(h.p_t_prior.grid_1,'Callback',@(x,y)obj.p_t_prior_RUN('grid',1)); 
            
            %% Scatter 0
            h.p_t_prior.scatter_0 = uimenu(h.whitebalance,'Label','p_t_prior.scatter_0');
            set(h.p_t_prior.scatter_0,'Callback',@(x,y)obj.p_t_prior_RUN('scatter',0));        
            
            %% Scatter 1
            h.p_t_prior.scatter_1 = uimenu(h.whitebalance,'Label','p_t_prior.scatter_1');
            set(h.p_t_prior.scatter_1,'Callback',@(x,y)obj.p_t_prior_RUN('scatter',1)); 
            
                        
            %% Surface 0
            h.p_t_prior.surface_0 = uimenu(h.whitebalance,'Label','p_t_prior.surface_0');
            set(h.p_t_prior.surface_0,'Callback',@(x,y)obj.p_t_prior_RUN('surface',0));        
            
            %% Surface 1
            h.p_t_prior.surface_1 = uimenu(h.whitebalance,'Label','p_t_prior.surface_1');
            set(h.p_t_prior.surface_1,'Callback',@(x,y)obj.p_t_prior_RUN('surface',1)); 
            
            %% pdf_weights_vs_CT
            h.pdf_weights_vs_CT_Grid0 = uimenu(h.whitebalance,'Label','pdf_weights_vs_CT - Grid0');
            set(h.pdf_weights_vs_CT_Grid0,'Callback',@(x,y)obj.pdf_weights_vs_CT_RUN(0)); 
            
            %% pdf_weights_vs_CT
            h.pdf_weights_vs_CT_Grid1 = uimenu(h.whitebalance,'Label','pdf_weights_vs_CT - Grid1');
            set(h.pdf_weights_vs_CT_Grid1,'Callback',@(x,y)obj.pdf_weights_vs_CT_RUN(1));             
        end
        function ColourWeightPlotter_RUN(obj,CurveNum,filename_str)
            %%
            cp = ColourWeightPlotter;
            [path,filename,ext] = fileparts(obj.ImageName);
            cp.Name = filename;
            cp.Path = path;
            cp.curve = CurveNum;
            cp.filename_str = filename_str;
            cp.RUN;
        end
        function Exists = ColourWeightPlotter_Check(obj,CurveNum,filename_str)
            cp = ColourWeightPlotter;
            [path,filename,ext] = fileparts(obj.ImageName);
            cp.Name = filename;
            cp.Path = path;
            cp.curve = CurveNum;
            cp.filename_str = filename_str;
            Exists = cp.CheckFileExists;
        end
        function wb_stats_image_RUN(varargin)
            %%
            obj = varargin{1};
            [path,filename,ext] = fileparts(obj.ImageName);
            
            wb = wb_stats_image;
            wb.bitDepth = 11;
            wb.filename = fullfile(path,[filename,'.awb_stats_mean.csv']);
            wb.RUN;
        end
        function Exists = wb_stats_image_Check(obj)
            [path,filename,ext] = fileparts(obj.ImageName);
            
            wb = wb_stats_image;
            wb.bitDepth = 11;
            wb.filename = fullfile(path,[filename,'.awb_stats_mean.csv']);
            
            Exists = wb.CheckFileExists; 
        end
        function wb_stats_calc_from_tiff_RUN(varargin)
            obj = varargin{1};
           [path,filename,ext] = fileparts(obj.ImageName);
            wb = wb_stats_calc_from_tiff;
            wb.Path = path;
            wb.filename = [filename,'_from_pipeline_wg.tiff'];
            wb.RUN();
        end
        function wb_stats_image_scatter_RUN(varargin)
            %%
            obj = varargin{1};
            [path,filename,ext] = fileparts(obj.ImageName);
            
            wb = wb_stats_image_scatter;
            wb.filename = fullfile(path,[filename,'.awb_stats_mean.csv']);
            wb.RUN;
        end
        function p_t_prior_RUN(varargin)
            %%
            obj = varargin{1};
            mode = varargin{2};
            gridNo = varargin{3};
            [path,filename,ext] = fileparts(obj.ImageName); 
            
            ptPrior = p_t_prior;
            ptPrior.mode = mode;
            ptPrior.GridNo = gridNo;
            ptPrior.path = path;
            ptPrior.filename = fullfile([filename]);
            ptPrior.RUN;
        end
        function pdf_weights_vs_CT_RUN(varargin)
            %%
            obj = varargin{1};
            gridNo = varargin{2};
            [path,filename,ext] = fileparts(obj.ImageName); 
            fig = pdf_weights_vs_CT;
            fig.path = path;
            fig.GridNo = gridNo;
            fig.filename = filename;
            fig.RUN();
        end
        function plotAWBDebug_RUN(obj,mode)
            %%
            obj = plotAWBDebug;
            obj.mode = mode;
            obj.RUN;
        end
    end
    methods (Hidden = true)
        function PipeLineView_PullDown(obj)
            %%
            h.parent = uimenu(obj.handles.figure);
            set(h.parent,'Label','PipeView');       
            
            %% BAYER
         
            obj.handles.pipe.tx = uimenu(h.parent,'Label','TX - Transposer');
            set(obj.handles.pipe.tx, 'Callback',@(x,y)obj.ImBD_RUN('tx'));
            
            obj.handles.pipe.bl = uimenu(h.parent,'Label','BL - Black Level');
            set(obj.handles.pipe.bl, 'Callback',@(x,y)obj.ImBD_RUN('bl'));

            obj.handles.pipe.bd = uimenu(h.parent,'Label','BD - Bayer denoise');
            set(obj.handles.pipe.bd, 'Callback',@(x,y)obj.ImBD_RUN('bd'));
            
            obj.handles.pipe.ls = uimenu(h.parent,'Label','LS - Lens Shading');
            set(obj.handles.pipe.ls, 'Callback',@(x,y)obj.ImBD_RUN('ls'));            
            
            obj.handles.pipe.st = uimenu(h.parent,'Label','ST - Statistics');
            set(obj.handles.pipe.st, 'Callback',@(x,y)obj.ImBD_RUN('st'));
            
            obj.handles.pipe.wg = uimenu(h.parent,'Label','WG - White balance/gain');
            set(obj.handles.pipe.wg, 'Callback',@(x,y)obj.ImBD_RUN('wg')); 
            
            obj.handles.pipe.dp = uimenu(h.parent,'Label','DP - Defective pixel auto correction');
            set(obj.handles.pipe.dp, 'Callback',@(x,y)obj.ImBD_RUN('dp'));   
            
            obj.handles.pipe.rs = uimenu(h.parent,'Label','RS - Bayer resampling');
            set(obj.handles.pipe.rs, 'Callback',@(x,y)obj.ImBD_RUN('rs'));    
            
            obj.handles.pipe.xc = uimenu(h.parent,'Label','XC - Crosstalk correction');
            set(obj.handles.pipe.xc, 'Callback',@(x,y)obj.ImBD_RUN('xc'));           
            
            %% RGB
            %demosaic? 
            obj.handles.pipe.dm = uimenu(h.parent,'Label','DM - Demosaicing/Sharpening');
            set(obj.handles.pipe.dm, 'Callback',@(x,y)obj.ImBD_RUN('dm'));           
            
            % colour correction? 
            %gamma
            obj.handles.pipe.gm = uimenu(h.parent,'Label','GM - Gamma correction');
            set(obj.handles.pipe.gm, 'Callback',@(x,y)obj.ImBD_RUN('gm'));    
            
            %% YUV
            obj.handles.pipe.yg = uimenu(h.parent,'Label','YG - YCbCr conversion');
            set(obj.handles.pipe.yg, 'Callback',@(x,y)obj.ImBD_RUN('yg'));             
            
            obj.handles.pipe.fc = uimenu(h.parent,'Label','FC - False colour suppression');
            set(obj.handles.pipe.fc, 'Callback',@(x,y)obj.ImBD_RUN('fc'));               
            
            obj.handles.pipe.cp = uimenu(h.parent,'Label','CP - Colour processing');
            set(obj.handles.pipe.cp, 'Callback',@(x,y)obj.ImBD_RUN('cp'));               
            
             
            obj.handles.pipe.gd = uimenu(h.parent,'Label','GD - Distortion correction/high resolution resize');
            set(obj.handles.pipe.gd, 'Callback',@(x,y)obj.ImBD_RUN('gd'));             

            obj.handles.pipe.ho = uimenu(h.parent,'Label','HR - High resolution output');
            set(obj.handles.pipe.ho, 'Callback',@(x,y)obj.ImBD_RUN('ho'));      
            
            obj.handles.pipe.cc = uimenu(h.parent,'Label','CC - Colour conversion');
            set(obj.handles.pipe.cc, 'Callback',@(x,y)obj.ImBD_RUN('cc'));     
            
            obj.handles.pipe.yc = uimenu(h.parent,'Label','YC - YUV colour conversion/colour correction');
            set(obj.handles.pipe.yc, 'Callback',@(x,y)obj.ImBD_RUN('yc'));            
            
            
            %% STAGE UNKNOWN

            
            obj.handles.pipe.yd = uimenu(h.parent,'Label','YD - YCbCr denoise');
            set(obj.handles.pipe.yd, 'Callback',@(x,y)obj.ImBD_RUN('yd'));       

            
            obj.handles.pipe.co = uimenu(h.parent,'Label','CO - Clear overlaps');
            set(obj.handles.pipe.co, 'Callback',@(x,y)obj.ImBD_RUN('co'));    
            

%             h.lr = uimenu(h.parent,'Label','LR - Low resolution resize');
%             set(h.lr, 'Callback',@(x,y)obj.ImBD_RUN('lr'));   
            

            
            obj.handles.pipe.lo = uimenu(h.parent,'Label','LO - Low resolution output');
            set(obj.handles.pipe.lo, 'Callback',@(x,y)obj.ImBD_RUN('lo'));
            
            obj.handles.pipe.sw = uimenu(h.parent,'Label','SW - Software stage output');
            set(obj.handles.pipe.sw, 'Callback',@(x,y)obj.ImBD_RUN('sw'));         
            
            obj.handles.pipe.ca = uimenu(h.parent,'Label','CA - Chromatic aberration correction');
            set(obj.handles.pipe.ca, 'Callback',@(x,y)obj.ImBD_RUN('ca'));
            
            obj.handles.pipe.cb = uimenu(h.parent,'Label','CB - Colour bias/preferred colours');
            set(obj.handles.pipe.cb, 'Callback',@(x,y)obj.ImBD_RUN('cb'));   
        end
        function ImBD_RUN(varargin)
            %%
            obj = varargin{1};
            stage = varargin{2};
            
            %%
            [pathname, filename] = fileparts(obj.ImageName);
            filename = [filename,'_from_pipeline_',stage,'.tiff']
            image_IN = imread(fullfile(pathname,filename));
            
            %%
            switch lower(stage)
                %% RGB Assumed
                case {      'ho','sw', ...
                            'yg', 'yc', ...
                            'gm'}
                    obj.imageOUT =  image_IN.*2^3;  
                %% YUV assumed
                case {'fc','cp','gd', 'cc', 'yd', 'co'}
                    ycbcr(:,:,1) = double(image_IN(:,:,1))./2^13;
                    ycbcr(:,:,2) = double(image_IN(:,:,1))./2^13;
                    ycbcr(:,:,3) = double(image_IN(:,:,1))./2^13;
                    obj.imageOUT = ycbcr;
                case {'lo'}
                    ycbcr(:,:,1) = double(image_IN(:,:,1))./2^16;
                    ycbcr(:,:,2) = double(image_IN(:,:,1))./2^16;
                    ycbcr(:,:,3) = double(image_IN(:,:,1))./2^16;
                    obj.imageOUT = ycbcr;
                %% bayer   
                case {'bl'} % bayer start
                    imageOUT(:,:,1) = double(image_IN)./2^10;
                    imageOUT(:,:,2) = double(image_IN)./2^10;
                    imageOUT(:,:,3) = double(image_IN)./2^10;
                    obj.imageOUT =  imageOUT;
                case {'bd','tx','ls','st','wg'} % images are blue
                    ch1 = double(image_IN)./2^13;
                    imageOUT(:,:,1) = ch1;
                    imageOUT(:,:,2) = ch1;
                    imageOUT(:,:,3) = ch1;
                    obj.imageOUT =  imageOUT;
                case {'dp','rs','xc','dm'}
                    imageOUT(:,:,1) = double(image_IN)./2^14;
                    imageOUT(:,:,2) = double(image_IN)./2^14;
                    imageOUT(:,:,3) = double(image_IN)./2^14;
                    obj.imageOUT =  imageOUT;                    
                otherwise 
                    obj.imageOUT =  image_IN./2^6;
            end
            names = fieldnames(obj.handles.pipe);
            x = max(size(names));
            for i  = 1:x
               set(obj.handles.pipe.(names{i}),'Checked','off') ;
            end
            set(obj.handles.pipe.(stage),'Checked','on');
        end
    end
    methods (Hidden = true) %UI box selection
        function AddToolBar(obj)
            %%
            h = uitoolbar(obj.handles.figure);
            
            %% load
            filename = fullfile( matlabroot,'toolbox','matlab','icons','opendoc');
            load(filename);
            hpt = uipushtool(h,'CData',cdata,'TooltipString','Load Image');
            set(hpt,'ClickedCallback',@obj.LoadImage);
            
            %% save
            filename = fullfile( matlabroot,'toolbox','matlab','icons','savedoc');
            load(filename);
            hpt = uipushtool(h,'CData',cdata,'TooltipString','Save As');
            set(hpt,'ClickedCallback',@obj.Save);
            
            %% arrow
            filename = fullfile( matlabroot,'toolbox','matlab','icons','pointer');
            load(filename)
            hpt = uitoggletool(h,   'CData',cdata, ...
                                    'TooltipString','Arrow', ...
                                    'Separator','on');
            obj.handles.pointer = hpt;
            set(obj.handles.pointer,'State','on')
            set(hpt,'ClickedCallback',@obj.Escape);
            
            %% line
            filename = fullfile( matlabroot,'toolbox','matlab','icons','line');
            load(filename)
            hpt = uitoggletool(h,'CData',lineCData,'TooltipString','Line Selection');
            set(hpt,'ClickedCallback',@obj.SelectLine);
            obj.handles.lineSelection = hpt;       
            
            %% box
            filename = fullfile( matlabroot,'toolbox','matlab','icons','help_block.png');
            [X] = imread(filename);
            X = double(X)/256;
            icon = obj.ChangeBG_Colour(X,[NaN,NaN,NaN]);
            hpt = uitoggletool(h,'CData',icon,'TooltipString','Box Selection');
            set(hpt,'ClickedCallback',@obj.SelectBox);
            obj.handles.boxSelection = hpt;
            
            %% zoom in
            filename = fullfile( matlabroot,'toolbox','matlab','icons','tool_zoom_in.png')
            [X] = imread(filename);
            X = double(X)/2^16;
            icon = obj.ChangeBG_Colour(X,[NaN,NaN,NaN]);
            hpt = uipushtool(h,     'CData',icon, ...
                                    'TooltipString','Zoom In', ...
                                    'Separator','on');
            set(hpt,'ClickedCallback',@obj.ZoomIn);
            
            %% zoom out
            filename = fullfile( matlabroot,'toolbox','matlab','icons','tool_zoom_out.png')
            [X] = imread(filename);
            X = double(X)/2^16;
            icon = obj.ChangeBG_Colour(X,[NaN,NaN,NaN]);
            hpt = uipushtool(h,'CData',icon,'TooltipString','Zoom Out');
            set(hpt,'ClickedCallback',@obj.ZoomOut);
        end
        function SelectBox(varargin)
            %%
            obj = varargin{1};
            set(obj.handles.pointer,'State','off')
            set(obj.handles.boxSelection,'State','on');
            set(obj.handles.lineSelection,'State','off'); 
            delete(obj.handles.rect);
            figure(obj.handles.figure);
            setappdata(obj.handles.figure,'imcrop','on'); %To allow us to cancel - See Escape for rest of code. 
            [I2,RECT] = imcrop;
            
            if isempty(RECT)

            else
                box = [RECT(1),RECT(2),RECT(1)+RECT(3),RECT(2)+RECT(4)];
                obj.box_enable = true;
                obj.box_X_Start = box(1);
                obj.box_Y_Start = box(2);
                obj.box_X_End = box(3);
                obj.box_Y_End = box(4);
                obj.BoxSelection;
                obj.imageOUT_cropped = I2;
            end
            set(obj.handles.boxSelection,'State','off')
            set(obj.handles.pointer,'State','on')
            set(obj.handles.lineSelection,'State','off')
        end
        function SelectLine(varargin)
            obj = varargin{1};
            set(obj.handles.pointer,        'State','off'   );
            set(obj.handles.boxSelection,   'State','off'   );
            set(obj.handles.lineSelection,  'State','on'    ); 
            try
            delete(obj.handles.line);
            delete(obj.handles.line1);
            delete(obj.handles.line2);
            end
            figure(obj.handles.figure);
            setappdata(obj.handles.figure,'imline','on'); %To allow us to cancel - See Escape for rest of code. 
            
            obj.handles.line = imline(gca);
%             obj.handles.line.setResizable(false);
%             id = addNewPositionCallback(obj.handles.line,@(x,help y)obj.MoveLineCallback(obj.handles.line));
            pos = wait(obj.handles.line);
            obj.handles.linePos = pos;

            obj.imageOUT_line = improfile(obj.imageOUT,pos(:,1),pos(:,2));
            delete(obj.handles.line)
            obj.handles.line1 = line(pos(:,1),pos(:,2));
            obj.handles.line2 = line(pos(:,1),pos(:,2));
            
            
            %%
            set(obj.handles.line1,  'Color',        [1,1,1], ...
                                    'LineWidth',    1.5)
            set(obj.handles.line2,'Color',[0,0,1])
            
            %%
            set(obj.handles.boxSelection,   'State',    'off');
            set(obj.handles.pointer,        'State',    'on');
            set(obj.handles.lineSelection,  'State',    'off');       
            
        end
        function pos  = MoveLineCallback(varargin)
             obj = varargin{1};
%            obj.LineMoving = true;
             disp('new')
%              get(obj.handles.line)
             disp('last')
             pos = obj.handles.linePos;
% %% MONITOR POS
%             h = varargin{2};
%             if isempty(obj.LinePos)
%                 pos = getPosition(h);
%                 obj.imageOUT_line = improfile(obj.imageOUT,pos(1,:),pos(:,2));
%                 obj.LinePos = pos;
%                 return 
%             end
%             disp('last')
%             disp(obj.LinePos)
%             disp('new')
%             pos = getPosition(h);
%             disp(pos)
%             if not(obj.LinePos(1,1) == pos(1,1))
%                 % updating
%                 disp('Not updating since moving')
% %                 obj.imageOUT_line = improfile(obj.imageOUT,pos(1,:),pos(:,2));
%             else
%                 disp('updating')
%                 obj.imageOUT_line = improfile(obj.imageOUT,pos(1,:),pos(:,2));
%                 obj.LinePos = pos;
%             end
        end
        function icon = ChangeBG_Colour(obj,icon,Colour)
            [x,y,z] = size(icon);
            icons = reshape(icon,x*y,3);
            MASK = (icons(:,1)==0).*(icons(:,2)==0).*(icons(:,3)==0);
            n = find(MASK == 1);
            icons(n,1) = Colour(1);
            icons(n,2) = Colour(2);
            icons(n,3) = Colour(3);
            icon = reshape(icons,x,y,3);            
        end
        function Escape(varargin)
            %%
            obj = varargin{1};
            set(obj.handles.lineSelection,'State','off');
            tmp = getappdata(obj.handles.figure,'imcrop');
            if ~isempty(tmp) && strcmp(tmp,'on') %if imcrop is ON cancel
                r = java.awt.Robot;
                r.keyPress(java.awt.event.KeyEvent.VK_DELETE);
                r.keyRelease(java.awt.event.KeyEvent.VK_DELETE);
                setappdata(obj.handles.figure,'imcrop','off');
            end
            obj.imageOUT_cropped = obj.imageOUT;
        end
    end
end