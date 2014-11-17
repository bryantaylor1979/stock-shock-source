classdef dataset < handle & ...
                   dynamicprops
    properties
    end
    methods (Static)
        function Example(obj)
            %%
            close all
            clear classes
            obj = dataset({[1,2,3,4],'Num'},{{'a','b','c'},'String'})
        end
    end
    methods
        function obj = dataset(varargin)
            x = size(varargin,2);
            for i = 1:x
                set = varargin{i};
                VarName = set{2};
                Values = set{1};
                obj.addprop(VarName);
                obj.(VarName) = Values;
            end
        end
    end
end