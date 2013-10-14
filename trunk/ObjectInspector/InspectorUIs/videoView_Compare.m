classdef videoView_Compare <    handle & ...
                                WindowROI
    properties (SetObservable = true, GetObservable = false)
        InstallDir = 'C:\sourcecode\matlab\Programs\CAF\';
        VideoPath = 'C:\sourcecode\matlab\Programs\ObjectInspector\InspectorUIs\videoView_files\examples\';
        Offset = 61;
        VIDEO %HEADING
        videoName = '00_Capri_HD.mp4';
        AssumedTimeStamp
        Vid_FrameNumber = 1;
        NumberOfFrameJump = 1;
    end
    properties (Hidden = true) %HIDE for now. compare tools
        mode = 'single'; %compare or single
        VIDEO_COMPARE %HEADING
        video1Name = '00_Capri_HD.mp4';
        video2Name = '00_S2_HD.mp4';
        Vid1_FrameNumber
        Vid2_FrameNumber        
    end
    properties (Hidden = true)
        handle
    end
    methods (Hidden = true)
        function obj = videoView_Compare(varargin)
            %%
            x = max(size(varargin));
            for i = 1:2:x
                obj.(varargin{i}) = varargin{i+1};
            end
%             if isempty(obj.videoName)
%                 [obj.videoName, obj.root] = obj.GetFileName();
%             end
            if strcmpi(obj.mode,'compare')
                obj.OpenVideos(obj.VideoPath,obj.video1Name,obj.video2Name,obj.Offset)
            else
                obj.OpenVideo(obj.VideoPath,obj.videoName); 
                % ROI stuff
                obj.roi = obj.LoadROI(obj.ROI_Profile);
                obj.ROI_handles = obj.DisplayROI(obj.roi);   
                obj.EnableROI(obj.roi_enable);
                obj.AddROIButton();
            end    
            obj.handle.listeners.PostSet = obj.addlistener(fieldnames(obj),'PostSet',@obj.SETGET); 
        end
        function Example(obj)
            %% Compare Hidden Functionality.
            close all
            clear classes
            obj = videoView_Compare;
            ObjectInspector(obj)
            
            %% go to frame
            obj.GotoFrame('Vid1',200);
            
            %%
            obj.GotoFrame_Vid1(80)
            
            %%
            obj.GotoNextFrame_Vid1
            
            %%
            obj.GotoPreviousFrame_Vid1
            
            %%
            obj.GotoFrame_Vid2(80)
            
            %%
            obj.GotoNextFrame_Vid2
            
            %%
            obj.GotoPreviousFrame_Vid2
            
            %%
            obj.GotoNextFrame
            
            %%
            obj.GotoPreviousFrame
            
            %%
            Offset = obj.GetFrameDifference
        end
        function ExampleSingleVideo(obj)
            %%
            close all
            clear classes
            VideoPath = 'C:\Users\bryant\Desktop\CAF Blurry\';
            videoName = '20130605_152508.mp4';
            obj = videoView_Compare(    'VideoPath',VideoPath, ...
                                        'videoName',videoName);
            ObjectInspector(obj)
            
            %%
            obj.GotoNextFrame_Vid
            obj.Vid_FrameNumber
        end
        function GotoFrame(obj,vid,frameNumber)
            %%
            if strcmpi(vid,'Vid2')
                Offset = obj.GetFrameDifference();
                obj.GotoFrame_Vid1(frameNumber+Offset);
                obj.GotoFrame_Vid2(frameNumber);
            elseif strcmpi(vid,'Vid1')
                Offset = obj.GetFrameDifference();
                obj.GotoFrame_Vid1(frameNumber);
                obj.GotoFrame_Vid2(frameNumber-Offset);
            end
        end
        function GotoNextFrame(obj)
            %%
            obj.GotoNextFrame_Vid1;
            obj.GotoNextFrame_Vid2;
        end
        function GotoPreviousFrame(obj)
            %%
            obj.GotoPreviousFrame_Vid1;
            obj.GotoPreviousFrame_Vid2;
        end
        function Offset = GetFrameDifference(obj)
            %%
            Offset = obj.Vid1_FrameNumber - obj.Vid2_FrameNumber;
        end
        function [filename, VideoPath] = GetFileName(obj)
            %%
            PWD = pwd;
            cd([obj.InstallDir,'Logs\'])
            [filename, VideoPath] = uigetfile( { ...
                '*.mp4',   'All log files (*.mp4)';...
                '*.*',           'All Files (*.*)'}, ...
                'Pick a file');
        end
    end
    methods (Hidden = true) %Get video info
        function NumberOfFrames = GetTotalNumberOfFrames(obj)
            %%
            NumberOfFrames = obj.handle.vid.NumberOfFrames;
        end
        function FrameRate = GetFrameRate(obj)
            %%
            FrameRate = obj.handle.vid.FrameRate;
        end
        function Duration = GetDuration(obj)
            Duration = obj.handle.vid.Duration;
        end
        function TimeStamps = GetTimeStamps(obj)
            %% Example
            GetTotalNumberOfFrames = obj.GetTotalNumberOfFrames
            VideoPath = obj.VideoPath;
            filename = obj.videoName;

            %%
            StepSize = 100;
            Interations = floor(GetTotalNumberOfFrames/10);
            
            %%
            h = waitbar(0);
            TimeStamps = [];
            time = 0;
            for i = 1:Interations
                tic
                waitbar(i/GetTotalNumberOfFrames,h,['TimePerInt: ',num2str(time/StepSize)]);
                startframeNum = (i-1)*StepSize+1;
                endframeNum = (i-1)*StepSize+StepSize;
                [video, audio] = mmread([VideoPath,filename],[startframeNum:endframeNum]);
                TimeStamps = [TimeStamps,video.times];
                time = toc; 
            end
            RemInterations = rem(GetTotalNumberOfFrames,10);
            startframe = Interations*StepSize + 1;
            endframeNum = Interations*StepSize + RemInterations; 
            [video, audio] = mmread([VideoPath,filename],[startframeNum:endframeNum]);
            TimeStamps = [TimeStamps,video.times];
            close(h)
        end
    end
    methods  (Hidden = true) %Video 1 controls
        function GotoNextFrame_Vid1(obj)
            %%
            frameNumber = obj.Vid1_FrameNumber + 1;
            
            obj.GotoFrame_Vid1(frameNumber);
        end
        function GotoPreviousFrame_Vid1(obj)
            %%
            frameNumber = obj.Vid1_FrameNumber - 1;
            obj.GotoFrame_Vid1(frameNumber);
        end  
        function GotoFrame_Vid1(obj,frameNumber)
            %%
            VIDEO = read(obj.handle.vidCapri, frameNumber);
            set(obj.handle.capri,'CDATA',VIDEO);
            obj.Vid1_FrameNumber = frameNumber;          
        end
    end
    methods  (Hidden = true) %Video 2 controls
        function GotoNextFrame_Vid2(obj)
            %%
            frameNumber = obj.Vid2_FrameNumber + 1;
            obj.GotoFrame_Vid2(frameNumber);
        end
        function GotoPreviousFrame_Vid2(obj)
            %%
            frameNumber = obj.Vid2_FrameNumber-1;
            obj.GotoFrame_Vid2(frameNumber)
        end
        function GotoFrame_Vid2(obj,frameNumber)
            %%
            VIDEO = read(obj.handle.vidS2, frameNumber);
            set(obj.handle.s2,'CDATA',VIDEO);
            obj.Vid2_FrameNumber = frameNumber;
        end
    end
    methods  (Hidden = true) %Video controls
        function GotoNextFrame_Vid(varargin)
            %%
            obj = varargin{1};
            frameNumber = obj.Vid_FrameNumber + obj.NumberOfFrameJump;
            
            %%
            total_seconds = frameNumber*1/30;
            seconds = rem(total_seconds,60);
            minutes = floor(total_seconds/60);
            obj.AssumedTimeStamp = ['Time: ',num2str(minutes),' min ',num2str(seconds),' sec'];
            
            %%
            obj.GotoFrame_Vid(frameNumber);
        end
        function GotoPreviousFrame_Vid(varargin)
            %%
            obj = varargin{1};
            frameNumber = obj.Vid_FrameNumber - obj.NumberOfFrameJump;
            
            %%
            total_seconds = frameNumber*1/30;
            seconds = rem(total_seconds,60);
            minutes = floor(total_seconds/60);
            obj.AssumedTimeStamp = ['Time: ',num2str(minutes),' min ',num2str(seconds),' sec'];
            
            obj.GotoFrame_Vid(frameNumber)
        end  
        function GotoFrame_Vid(obj,frameNumber)
            %%
            VIDEO = read(obj.handle.vid, frameNumber);
            set(obj.handle.vidgui,'CDATA',VIDEO);
            obj.Vid_FrameNumber = frameNumber;          
        end
    end
    methods  (Hidden = true)
        function OpenVideos(obj,VideoPath,video1Name,video2Name,Offset)
            %%
            set(0,'DefaultFigureWindowStyle','normal')
            handle.vidCapri    = VideoReader([VideoPath,video1Name]);
            handle.vidS2       = VideoReader([VideoPath,video2Name]);

            image = read(handle.vidCapri, 1+Offset); 
            figure
            handle.capri = imshow(image);
            set(gcf,'Name',video1Name);

            image = read(handle.vidS2, 1);  
            figure
            handle.s2 = imshow(image);
            set(gcf,'Name',video2Name);
            obj.handle = handle;
            
            obj.Vid1_FrameNumber = 1+Offset;
            obj.Vid2_FrameNumber = 1;
        end
        function OpenVideo(obj,VideoPath,videoName)
            %%
            obj.handle.vid    = VideoReader([VideoPath,videoName]);  
            image = read(obj.handle.vid, 1); 
            obj.handle.figure = figure;
            obj.handle.vidgui = imshow(image);
            obj.handle.vidaxes = gca;
            set(gcf,'Name',videoName);
            obj.Vid_FrameNumber = 1;
            
            %% adding a toolbar
            h = uitoolbar(obj.handle.figure);
            set(obj.handle.figure,'ToolBar','none');
            
            %%
            [X map] = imread(fullfile(...
                matlabroot,'toolbox','matlab','icons','prev.gif'));
            icon = ind2rgb(X,map);
            hpt2 = uipushtool(h,'CData',icon,'TooltipString','Back 1 frame');
             
            %%
            [X map] = imread(fullfile(...
            matlabroot,'toolbox','matlab','icons','next3.gif'));
            icon = ind2rgb(X,map);
            hpt1 = uipushtool(h,'CData',icon,'TooltipString','Skip 1 frame');
            
            %%
            set(hpt2,'ClickedCallback',@obj.GotoPreviousFrame_Vid);
            set(hpt1,'ClickedCallback',@obj.GotoNextFrame_Vid);
            
            obj.handle.toolbar = h;
        end
    end
    methods (Hidden = true) %Support
        function SETGET(varargin)
            %%
            disp('hello')
            obj = varargin{1};
            property = varargin{2}.Name;
            
            switch property
                case 'Vid_FrameNumber'
                    %%
                    obj.GotoFrame_Vid(obj.Vid_FrameNumber);
                otherwise
            end    
        end
    end 
end


