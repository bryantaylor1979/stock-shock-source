classdef TrackerManagement2 < handle
    properties
    end
    methods
        function SaveStatus(obj,struct,date,Name)
            %%
           filename = [obj.InstallDir,'Track\',Name,'_',strrep(datestr(date),'-','_'),'.mat'];
           filename = [obj.StockData,'Schedular\Track\',Name,'_',strrep(datestr(date),'-','_'),'.mat'];
           save(filename)
        end
        function [struct, Error] = LoadStatus(obj,date,Name)
            %%
            filename = [obj.InstallDir,'Track\',Name,'_',strrep(datestr(date),'-','_'),'.mat'];
            filename = [obj.StockData,'Schedular\Track\',Name,'_',strrep(datestr(date),'-','_'),'.mat'];
            try
                disp(['Load Path: ',filename])
                load(filename)
                Error = 0;
            catch
                struct = [];
                Error = -1;                
            end
        end
        function N_DATASET = Planner2DataSet(obj,DATASET)
            %%
            NumberOfFields = size(DATASET.table,2)
            FieldNames = DATASET.FieldNames
            for i = 1:NumberOfFields
                FieldName = FieldNames{i}
                columndata = DATASET.table(:,i)
                column = dataset({columndata,FieldName})
                if i == 1
                    N_DATASET = column;
                else
                    N_DATASET = [N_DATASET,column];
                end
            end
        end
    end
end