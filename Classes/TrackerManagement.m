classdef TrackerManagement < handle
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
        function structout = RemoveCompleted(obj,struct)
            %%
            ProgramNames = fieldnames(struct);
            for i = 1:max(size(ProgramNames))
                MacroNames = fieldnames(struct.(ProgramNames{i}));
                for j = 1:max(size(MacroNames))
                    val = struct.(ProgramNames{i}).(MacroNames{j});
                    if val.Complete == false
                        structout.(ProgramNames{i}).(MacroNames{j}) = struct.(ProgramNames{i}).(MacroNames{j});
                    end
                end
            end
            if not(exist('structout'))
                disp('All task are complete. Program will be terminated')
                error('Program terminated')
            end
        end
        function structout = RemoveStarted(obj,struct)
            %%
            ProgramNames = fieldnames(struct);
            for i = 1:max(size(ProgramNames))
                MacroNames = fieldnames(struct.(ProgramNames{i}));
                for j = 1:max(size(MacroNames))
                    val = struct.(ProgramNames{i}).(MacroNames{j});
                    if val.Started == false
                        structout.(ProgramNames{i}).(MacroNames{j}) = struct.(ProgramNames{i}).(MacroNames{j});
                    end
                end
            end
        end
    end
end