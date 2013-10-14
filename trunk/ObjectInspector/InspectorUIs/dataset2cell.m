function c = dataset2cell(DATASET)
                
            VarNames = get(DATASET,'VarNames');
            [x] = size(VarNames,2);
            for i = 1:x
                temp = GetColumn(DATASET,VarNames{i});
                if not(iscell(temp))
                    temp = num2cell(temp);
                end
                Array(:,i) = temp;
            end
            c = [VarNames;Array];
end
function [Data] = GetColumn(DATA,ColumnName)
        h = get(DATA);
        if isempty(DATA)
            Data = [];
            return
        end
        n = find(strcmpi(h.VarNames,ColumnName));
        if isempty(n)
           error(['ColumnName: ',ColumnName])
        end
        Data2 = DATA(:,n);
        switch class(Data2{1,1})
            case 'char'
                Data = datasetfun(@cell,Data2,'UniformOutput',false);
                Data = Data{1,1};
            case 'double'
                Data = double(Data2);
            case 'logical'
                Data = double(Data2);
            otherwise
               error(['Class not recognised: ',class(Data2{1,1})])
        end
end
