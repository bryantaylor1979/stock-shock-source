classdef uiDataSetTable < handle 
    properties (SetObservable = true)
        figureName = 'Table'
        DATASET
        ObjectHandle
        ParamName
    end
    properties (Hidden = true)
         border = 5;
         handle
         rot90 = false
    end
    methods
        function Example(obj)
            %%
            close all
            clear classes
            DATA = dataset({rot90([1:5]),'Var1'},{rot90([1:5]),'Var2'});
            obj = uiDataSetTable('DATASET',DATA);
            
            %%
            ObjectInspector(obj)  
        end
        function RUN(obj)
            %%
            colnames = get(obj.DATASET,'VarNames');
            get(obj.DATASET);
            
            CELL = dataset2cell(obj.DATASET);
            obj.plot(obj.figureName,colnames,CELL(2:end,:),obj.rot90);
        end
    end
    methods (Hidden = true)
        function CreateToolBar(obj)
            %%
            ht = uitoolbar(obj.handle.figure)
            filename = fullfile( matlabroot,'toolbox','matlab','icons','savedoc');
            load(filename)
            %%
%             [X] = imread(filename);
%             icon = ind2rgb(X,map);
            hpt = uipushtool(ht,    'CData',cdata, ...
                                    'TooltipString','Save', ...
                                    'ClickedCallback',@obj.Save);
            
            filename = fullfile( matlabroot,'toolbox','matlab','icons','opendoc'); 
            load(filename)
            hpt = uipushtool(ht,    'CData',cdata, ...
                                    'TooltipString','Load', ...
                                    'ClickedCallback',@obj.Load);
        end
        function obj = uiDataSetTable(varargin)
            x = size(varargin,2);
            for i = 1:2:x
                obj.(varargin{i}) = varargin{i+1};
            end
            obj.RUN();
        end
        function Save(varargin)
            %%
            obj = varargin{1};
            
            %%
            [filename, pathname] = uiputfile( ...
                        {'*.xls';'*.csv';'*.*'}, ...
                        'Pick a file');
            %%        
            [name,~,ext] = fileparts(filename);
            datasetObj = DataSetFiltering2;   
            file = fullfile(pathname,filename)
            
            %%
            if strcmpi(ext,'.xls')
               datasetObj.DataSet2xls(obj.DATASET,file); 
            else
               datasetObj.DataSet2csv(obj.DATASET,file);  
            end
        end
        function Load(varargin)
            %%
            disp('Load')
            obj = varargin{1}; 
            
            %%
            [filename, pathname] = uigetfile( ...
                        {'*.xls';'*.csv';'*.*'}, ...
                        'Pick a file')
             
            %% xls 2 dataset
            DATASET = obj.xls2dataset(fullfile(pathname,filename));
            
            CELL = dataset2cell(DATASET);
            colnames = get(DATASET,'VarNames');
            set(obj.handle.table,  'Data', CELL(2:end,:), ...
                                    'ColumnName',colnames);
            obj.ObjectHandle.(obj.ParamName) = DATASET;
        end
        function DATASET = xls2dataset(obj,filename)
            [num,text,raw] = xlsread(filename);
            ColumnNames = raw(1,:);
            x = size(ColumnNames,2);
            raw = raw(2:end,:);
            DATASET = dataset();
            for i = 1:x
                name = ColumnNames{i};
                col1 = raw(:,i);
                try
                NumData = cell2mat(col1);
                DATASET = [DATASET,dataset({NumData,name})];
                catch
                DATASET = [DATASET,dataset({col1,name})];
                end
            end            
        end
        function plot(obj,figureName,colnames,data,direction)
            %% figure
%             ndata= data(68580,4);
            ndata= data;
            disp('plot')
            obj.handle.figure = figure( 'Name',figureName, ...
                                        'MenuBar','none');
            
            Dim = obj.CalculatedTableDim();
            if direction == false
                obj.handle.table = uitable(obj.handle.figure,  'Data', ndata, ...
                                'ColumnName', colnames, ...
                                'Position', Dim);
            else
                obj.handle.table = uitable(obj.handle.figure,  'Data', ndata', ...
                                'RowName', colnames, ...
                                'Position', Dim);
            end
            
            %%
            set(obj.handle.figure,'ResizeFcn',@obj.Resize)
            
            obj.CreateToolBar;
        end
        function Resize(varargin)
            %%
            obj = varargin{1};
            Dim = obj.CalculatedTableDim();
            set(obj.handle.table,'Position',Dim);
        end
        function Dim = CalculatedTableDim(obj)
            Dim = get(obj.handle.figure,'Position');
            Dim(1:2) = ceil(obj.border/2);
            Dim(3) = Dim(3) - obj.border; %75
            Dim(4) = Dim(4) - obj.border; %25            
        end
    end
end