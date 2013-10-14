classdef WindowROI < handle
    properties (SetObservable = true)
        ROI_Profile = 'search';
        roi_enable = 'on'
    end
    properties (Hidden = true)
        roi_enable_LUT = {  'on'; ...
                            'off'};
        roi
        ROI_handles  
        ROI_Profile_LUT = {     'motion_detection'; ...
                                'motion_detection_multi'; ...
                                'search'};
    end
    methods (Hidden = true)
        function Example(obj)                           
           %%
           obj.roi = obj.LoadROI();
           obj.ROI_handles = obj.DisplayROI(obj.roi(1));

           %%
           obj.DeleteROIs(obj.ROI_handles)
           
           %%
           obj.EnableROI('off')
           
           %%
           obj.EnableROI('on')
        end
        function AddROIButton(obj)
            %%
           [X map] = imread(fullfile(matlabroot,'toolbox','matlab','icons','box.gif'));
           icon = ind2rgb(X,map);
           
           hpt1 = uitoggletool( obj.handle.toolbar , ...
                                    'CData', icon, ...
                                    'TooltipString', 'Display WROI');
           set(hpt1,'State',obj.roi_enable);                 
           set(hpt1,'ClickedCallback',@obj.ToggleROI)            
        end
        function ToggleROI(varargin)
            %%
            obj = varargin{1};
            if strcmpi(obj.roi_enable,'off') 
                obj.EnableROI('on');
                obj.roi_enable = 'on';
            else
                obj.EnableROI('off');
                obj.roi_enable = 'off';                
            end
        end
        function EnableROI(obj,logic)
            %%
            x = max(size(obj.ROI_handles));
            for i = 1:x
                set(obj.ROI_handles(i),'Visible',logic);
                obj.ROI_handles(i).setResizable(false);
            end
        end
        function h = DisplayROI(obj,roi)
           [XDIM,YDIM] = obj.getimagesize();
           roi = obj.Percentage2Pixel(roi,XDIM,YDIM);
           h = obj.DrawRectangles(roi);            
        end
        function roi = LoadROI(obj,mode)
            switch mode
                case 'search'
                   roi(1).REGION = 0;
                   roi(1).x_offset = 0.4;
                   roi(1).y_offset = 0.4;
                   roi(1).width = 0.2;
                   roi(1).height = 0.2;
                   
                case 'motion_detection'
                   roi(1).REGION = 0;
                   roi(1).x_offset = 0.3;
                   roi(1).y_offset = 0.3;
                   roi(1).width = 0.4;
                   roi(1).height = 0.4;
                   
                case 'motion_detection_multi'
                   roi(1).REGION = 0;
                   roi(1).x_offset = 0.3;
                   roi(1).y_offset = 0.3;
                   roi(1).width = 0.4;
                   roi(1).height = 0.4;

                   roi(2).REGION = 1;
                   roi(2).x_offset = 0.1;
                   roi(2).y_offset = 0.1;
                   roi(2).width = 0.1;
                   roi(2).height = 0.1;

                   roi(3).REGION = 2;
                   roi(3).x_offset = 0.1;
                   roi(3).y_offset = 0.45;
                   roi(3).width =    0.1;
                   roi(3).height =   0.1;

                   roi(4).REGION = 3;
                   roi(4).x_offset = 0.1;
                   roi(4).y_offset = 0.8;
                   roi(4).width =    0.1;
                   roi(4).height =   0.1;

                   roi(5).REGION = 4;
                   roi(5).x_offset = 0.45;
                   roi(5).y_offset = 0.1;
                   roi(5).width =    0.1;
                   roi(5).height =   0.1;

                   roi(6).REGION = 5;
                   roi(6).x_offset = 0.45;
                   roi(6).y_offset = 0.8;
                   roi(6).width =    0.1;
                   roi(6).height =   0.1;

                   roi(7).REGION = 6;
                   roi(7).x_offset = 0.8;
                   roi(7).y_offset = 0.1;
                   roi(7).width =    0.1;
                   roi(7).height =   0.1;

                   roi(8).REGION = 7;
                   roi(8).x_offset = 0.8;
                   roi(8).y_offset = 0.45;
                   roi(8).width =    0.1;
                   roi(8).height =   0.1;

                   roi(9).REGION = 8;
                   roi(9).x_offset = 0.8;
                   roi(9).y_offset = 0.8;
                   roi(9).width =    0.1;
                   roi(9).height =   0.1;  
                otherwise 
                    error('ROI mode not recognised')
            end
        end
        function DeleteROIs(obj,h)
           x = size(h,2);
           for i = 1:x
               h(i).delete;
           end            
        end
        function [XDIM,YDIM] = getimagesize(obj)
            %%
            [YDIM,XDIM,ZDIM] = size(get(obj.handle.vidgui,'CDATA'))
        end
        function h = DrawRectangles(obj,roi)
            %%
            x = size(roi,2)
            for i = 1:x
                box = [roi(i).x_offset_per, roi(i).y_offset_per, roi(i).width_per, roi(i).height_per]
                h(i) = imrect(gca, box);
                h(i).setResizable(false)
            end
        end
        function roi = Percentage2Pixel(obj,roi,XDIM,YDIM)
            %%
            x = size(roi,2);
            for i = 1:x
                roi(i).x_offset_per = roi(i).x_offset*XDIM;
                roi(i).width_per = roi(i).width*XDIM;
                roi(i).y_offset_per = roi(i).y_offset*YDIM;
                roi(i).height_per = roi(i).height*YDIM;
            end
        end
    end
end