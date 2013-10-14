classdef Video_MonitorRT <  handle 
        properties
            handles
            InstallDir = 'C:\sourcecode\matlab\Programs\CAF\';
        end
        methods 
            function Example()
                %%
                close all
                clear classes
                obj = Video_MonitorRT;
                
            end
            function obj = Video_MonitorRT()
                
                %% load videos
                obj.LoadVidnLogs();
                obj.handles.listener = obj.handles.Vid.addlistener('Vid_FrameNumber','PostSet',@obj.Update);
            end
            function LoadVidnLogs(obj)             
                %%
                obj.handles.Vid = videoView(); 
                
                root = obj.handles.Vid.root;
                videoName = obj.handles.Vid.videoName;
                
                drawnow
                NumberOfFrames = obj.handles.Vid.GetTotalNumberOfFrames();
                
                LogName = strrep(videoName,'.mp4','.log');
                obj.LoadLogs(root,LogName);               
            end
            function LoadLogs(obj,root,LogName)
                %% load Logs
                obj.handles.Logs = runLogs([root,LogName])
            end
            function GotoFrameNumber(obj,Frame)
                %%
                
                names = fieldnames(obj.handles.Logs.handles.objPlogs.handles);
                x = size(names,1);
                for i = 1:x
                    H1 = obj.handles.Logs.handles.objPlogs.handles.(names{i});
                    H1.SetFrame(Frame);
                    H1.Update_FrameMarker(Frame);   
                end
                drawnow
            end
            function CAF_Window_OverLay(obj)
                %%
                h = imrect(obj.handle.vidaxes, [10 10 100 100]);
                CDATA = get(obj.handle.vidgui,'CDATA');         
            end
            function Update(varargin)
               obj = varargin{1}; 
               Frame = obj.handles.Vid.Vid_FrameNumber;
               obj.GotoFrameNumber(Frame);
            end
        end
end