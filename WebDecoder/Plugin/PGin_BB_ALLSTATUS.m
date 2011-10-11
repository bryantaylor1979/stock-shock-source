classdef PGin_BB_ALLSTATUS <    handle & ...
                                DataSetFiltering
    properties
    end
    methods %British Bulls
        function O_DataSet = SectorHeading2DatasetColumn(obj,DataSet)
            %%
            Open = obj.GetColumn(DataSet,'Open');
            Ticker = obj.GetColumn(DataSet,'Ticker');
            count = 1;
            
            x = size(DataSet,1)
            for i = 1:x
                if isnan(Open(i))
                    Val = DataSet{i,1};
                else
                    O_DataSet(count,:) = DataSet(i,:);
                    Sector{count,1} = Val;
                    count = count + 1;  
                end
            end
            O_DataSet = [O_DataSet,dataset(Sector)];
        end
    end
    methods % New Generation
        function [DataSet] = Table2DataSet(Table)
            %%
            Table2 = obj.RemoveALL_Formating(Table);
            
            DATASET = dataset(  {Table2(:,1), 'Ticker'}, ...
                                {Table2(:,2), 'Description'}, ...
                                {Table2(:,3), 'SubSector'}, ...
                                {Table2(:,4), 'Prev'}, ...
                                {Table2(:,5), 'Open'}, ...
                                {Table2(:,6), 'High'}, ...
                                {Table2(:,7), 'Low'}, ...
                                {Table2(:,8), 'Close'}, ...
                                {Table2(:,9), 'Change'}, ...
                                {Table2(:,10),'Signal'})
            
            %%
            Ticker =        obj.GetColumn(DATASET,'Ticker');
            Description =   obj.GetColumn(DATASET,'Description');
            SubSector =     obj.GetColumn(DATASET,'SubSector');
            Prev =          obj.ConvertColumn(DATASET,'Prev','Num');
            Open =          obj.ConvertColumn(DATASET,'Open','Num');
            High =          obj.ConvertColumn(DATASET,'High','Num');
            Low =           obj.ConvertColumn(DATASET,'Low','Num');
            Close =         obj.ConvertColumn(DATASET,'Close','Num');
            Change =        obj.ConvertColumn(DATASET,'Change','Per');
            Signal =        obj.GetColumn(DATASET,'Signal');
            
            DATASET2 = dataset(Ticker,Description,SubSector,Prev,Open,High,Low,Close,Change,Signal)
        end
        function VAL = ConvertColumn(obj,Table,ColumnNo,Type)
            %%
            vals = obj.GetColumn(Table,ColumnNo);
            switch lower(Type)
                case 'per'
                    vals = strrep(vals,'%','');
                    VAL = str2double(vals);
                case 'num'
                    VAL = str2double(vals);
                otherwise
            end
%             obj.ColumnFiltering()
        end
    end
end