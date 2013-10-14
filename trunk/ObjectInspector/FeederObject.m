classdef FeederObject < handle
    properties (Hidden = true)
        InputObject
        % ClassType should be set IN THE METRIC START-UP FUNCTION BEFORE EXECUTING
        % LINKOBJECTS
        ClassType                   %box - operates from box selection
                                    %image - operates from whole image
                                    %macbeth - operates from macbeth chart
                                    %line - operates from line. 
                                    

    end
    methods (Hidden = true)
        function obj = FeederObject()
            %% Do some checks to ensure the object are compliant.
        end
        function LinkObjects(obj)
            %%
            disp('Link')
            if isempty(obj.ClassType)
               disp('please declare class of input object.  box, image, macbeth, line')
            end
            switch obj.ClassType
                case 'image'
                    addlistener(obj.InputObject,'imageOUT','PostSet',@obj.UpdateLink);
                case 'box'
                    addlistener(obj.InputObject,'imageOUT_cropped','PostSet',@obj.UpdateLink);
                case 'line'
                    addlistener(obj.InputObject,'imageOUT_line','PostSet',@obj.UpdateLink);
                otherwise
                    error('class not supported')
            end     
        end
        function UpdateLink(varargin)
            %%
%             disp('updating link')
            obj = varargin{1};
            switch obj.ClassType
                case 'image'
                    obj.imageIN = obj.InputObject.imageOUT;
                case 'box'
                    obj.imageIN = obj.InputObject.imageOUT_cropped;
                case 'line'
                    obj.imageIN = obj.InputObject.imageOUT_line;
            end
            obj.RUN();
        end
    end
end