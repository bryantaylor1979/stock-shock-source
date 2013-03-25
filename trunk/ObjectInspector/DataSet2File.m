classdef DataSet2File < handle
    properties (SetObservable = true)
        FileName =  'C:\ISP\awb\output.xls';
        OuputFormat = 'xls'; %xls or csv
        DATASET
    end
    properties (Hidden = true)
        
        OuputFormat_LUT = { 'xls'; ...
                            'csv'};
    end
    methods
        function Example(obj)
            %%
            close all
            clear classes
            obj = DataSet2File
            
            obj.DATASET = dataset({rot90([1:3]),'Number'},{{'Var1';'Var2';'Var3'},'Vars'})
            ObjectInspector(obj)
        end
        function RUN(obj)
            %%
            [path,filename,ext] = fileparts(obj.FileName)
            obj.OuputFormat = ext(2:end);
            switch lower(obj.OuputFormat)
                case 'xls'
                    disp('write xls')
                    obj.DataSet2xls(obj.DATASET,obj.FileName);
                case 'csv'
                    obj.DataSet2csv(obj.DATASET,obj.FileName);
                otherwise
            end
        end
    end
    methods (Hidden = true)
        function obj = DataSet2File()
            
        end
        function DataSet2xls(obj,DATASET,FileName)
            VarNames = get(DATASET,'VarNames');
            if isempty(DATASET)
            DATA2 = {'Empty'};   
            else
            DATA1 = obj.FormatTable(DATASET);
            DATA2 = [VarNames;DATA1];
            end
            %%
            try
                xlswrite(FileName,DATA2);
            catch
                disp(['Path: ',FileName]);
                error('Problem writing xls file'); 
            end
        end
        function DataSet2csv(obj,DataSet,FileName)
            VarNames = get(DataSet,'VarNames');
            if isempty(DATASET)
            DATA2 = {'Empty'};   
            else
            DATA1 = obj.FormatTable(DATASET);
            DATA2 = [VarNames;DATA1];
            end
            %% Date Tag the cvs file.
            [x] = size(DATA2,2);
            DateStamp = cell(1,x);
            DateStamp{1,1} = ['DateStamp: ',datestr(now)];
            DATA2 = [DateStamp;DATA2];
            %%
            try
                obj.writecsv(FileName,DATA2);
            catch
                disp(['Path: ',FileName]);
                error('Problem writing csv file'); 
            end
        end
        function [Output] = FormatTable(obj,DATA)
            %%
            [y,x] = size(DATA);
            
            %%
            for i = 1:x %Date
                Type = DATA{1,i};
                switch class(Type)
                    case 'double'
                       try
                        Num = double(DATA(:,i));
                       catch
                          x = 1; 
                       end
                       Output(:,i) = num2cell(Num,2);
                    case 'char'
                       try
                       TEMP = datasetfun(@cell,DATA(:,i),'UniformOutput',false);
                       Output(:,i) = TEMP{1};
                       catch
                       Output(:,i) = {'Conv Fail'};   
                       end
                    otherwise
                end
            end
        end
    end
end