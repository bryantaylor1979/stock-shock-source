classdef TokenViewer < handle
    properties (SetObservable = true)
        ImageIO
        DATASET = dataset([])
    end
    properties (Hidden = true)
        handles
    end
    methods
        function Example(obj)
           %%
           close all 
           clear classes
           
           %%
           obj = TokenViewer;
           ObjectInspector(obj)
           
           %%
           
        end
        function RUN(obj)
            %%
            obj.GetAllTokens()
        end
    end
    methods (Hidden = true)
        function [DATASET] = GetAllTokens(obj)
            %%
            disp('dsfkjhsf')
            names = obj.GetTokenList();
            x = size(names,1);
            for i = 1:x
               name = names{i};
               tempp = load(name);
               temp = tempp.struct;
               out(i) = temp;
            end 
            %%
            NAMES = fieldnames(out);
            y = size(out,2);
            x = size(NAMES,1);
            for i = 1:x
                for j = 1:y
                    %
                    if ischar(out(j).(NAMES{i}));
                        values{j,1} = out(j).(NAMES{i});
                    elseif isempty(out(j).(NAMES{i}))
                        values{j,1} = [];
                    else
                        values(j,1) = out(j).(NAMES{i});
                    end
                end
                if i == 1
                    DATASET = dataset({values,NAMES{i}});
                else
                    DATASET = [DATASET,dataset({values,NAMES{i}})];
                end
                clear values
            end
            obj.DATASET = DATASET;
        end
        function obj = TokenViewer
            obj.ImageIO = ImageIO;
        end
        function names = GetTokenList(obj)
            %%
            obj.ImageIO.Path = 'Y:\URL_Download\Swap\';
            obj.ImageIO.ImageType = 'info.mat';
            obj.ImageIO.RUN;
            names = obj.ImageIO.names;
        end
    end
end