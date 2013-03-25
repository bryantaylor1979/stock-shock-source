classdef Batcher < handle
    properties (SetObservable = true)
        ParameterRecord = true %Log parameter described in Params2Log
        ClassName
        ParamName  
        Value
        Values
        PercentageComplete = '0%'
        TotalInterations = 0;
        SuccessfullInterations = 0;
        FailedInterations = 0;
        Params2Log = {  'RedEnergy'; ...
                        'GreenEnergy'; ...
                        'BlueEnergy'};
        ObjHandle
        DATASET = dataset([])
    end
    properties (Hidden = true) 
    end
    methods
        function Example(obj)
            %%
            close all
            clear classes
            
            WB_Sim = WB_Simulator;
            ObjectInspector(WB_Sim)
            Values = {  'C:\ISP\awb\024_imx105.raw'; ...
                        'C:\ISP\awb\025_imx105.raw'; ...
                        'C:\ISP\awb\030_imx105.raw'};
                    
            obj = Batcher(  'ObjHandle',     WB_Sim, ...
                            'ParamName',    'input_filename', ...
                            'Values',        Values)
            ObjectInspector(obj)
        end
        function RUN(obj)
            %%
            x = max(size(obj.Values));
            y = max(size(obj.Params2Log));
            obj.TotalInterations = x;
            obj.SuccessfullInterations = 0;
            obj.FailedInterations = 0;
            obj.PercentageComplete = '0%';
            for i = 1:x % x
                obj.Value = obj.Values{i};
                obj.ObjHandle.(obj.ParamName) = obj.Value;
                try
                    obj.ObjHandle.RUN;
                    obj.SuccessfullInterations = obj.SuccessfullInterations + 1;
                catch
                    obj.FailedInterations = obj.FailedInterations + 1;   
                end
                obj.PercentageComplete = [num2str(i/x*100),'%'];
                drawnow;
                
                % Log parameters
                for j = 1:y
                    Values(i,j) = obj.ObjHandle.(obj.Params2Log{j});
                end
            end
            %%
            if obj.ParameterRecord == true
                %%
                [x,p] = size(obj.Values);
                if not(p == 1)
                Names = rot90(obj.Values);
                else
                Names = obj.Values;    
                end
                DATASET = dataset({Names,obj.ParamName});
                for j = 1:y
                    DATASET = [DATASET,dataset({Values(:,j),obj.Params2Log{j}})];
                end
                obj.DATASET = DATASET;
            end
        end
    end
    methods (Hidden = true)
        function obj = Batcher(varargin)
            %%
            x = size(varargin,2);
            for i = 1:2:x
                obj.(varargin{i}) = varargin{i+1};
            end
            
            %%
            obj.ClassName = class(obj.ObjHandle);
        end
    end
end