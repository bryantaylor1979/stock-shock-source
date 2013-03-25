classdef FeederObject < handle
    properties (Hidden = true)
        InputObject
    end
    methods (Hidden = true)
        function obj = FeederObject()
            %% Do some checks to ensure the object are compliant.
        end
        function LinkObjects(obj)
            %%
            disp('Link')
            addlistener(obj.InputObject,'imageOUT','PostSet',@obj.UpdateLink)
        end
        function UpdateLink(varargin)
            %%
            disp('updating link')
            obj = varargin{1}
            obj.imageIN = obj.InputObject.imageOUT;
            obj.RUN();
        end
    end
end