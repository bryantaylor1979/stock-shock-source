classdef Stox < handle & ...
                DataSetFiltering
    methods
        function DataSet = StarRating(obj,DataSet2)
            %%
            Overall = obj.GetColumn(DataSet2,'Overall');
            Overall = strrep(Overall,'<img border=0 src=http://uk.stoxline.com/pics/','');
            Overall = strrep(Overall,'s.bmp>','');
            Overall = str2double(Overall);
            
            %Filter off orginal Overall column
            VarNames = get(DataSet2,'VarNames');
            n = find(not(strcmpi(VarNames,'Overall')));
            VarNames = VarNames(n);
            DataSet2 = obj.ColumnFiltering(DataSet2,VarNames);
            
            DataSet = [DataSet2,dataset(Overall)];
        end
    end
end