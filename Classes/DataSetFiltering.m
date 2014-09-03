classdef DataSetFiltering < handle
    methods 
        function [obj] = Filter(varargin)
            obj = varargin{1};
            State = get(obj.handles.filter,'State');
            persistent TableArray 
            switch State
                case 'on'
                    TableArray = get(obj.handles.table,'Data');
                    
                    %Filter on BUY
                    [x] = size(TableArray,1);
                    n = find(strcmpi(TableArray(:,3),'Buy'));
                    SelectArray = TableArray(n,:);
                    
                    %Filter on profit
                    [x]=size(SelectArray,1);
                    n = [];
                    for i = 1:x
                        if SelectArray{i,10}>obj.Threshold
                           n = [n,i]; 
                        end
                    end
                    SelectArray = SelectArray(n,:);
                    
                    set(obj.handles.table,'Data',SelectArray);
                case 'off'                    
                    set(obj.handles.table,'Data',TableArray);
                otherwise
            end
        end 
        function [DATASET] = NumRange(obj,DATASET2,ColumnName,Range)
            DATA = obj.GetColumn(DATASET2,ColumnName);
            n = find(DATA > Range(1));
            if isempty(n)
                DATASET = [];
                return
            end
            DATASET3 = DATASET2(n,:);
            
            DATA = obj.GetColumn(DATASET3,ColumnName);
            n = find(DATA < Range(2));
            DATASET = DATASET3(n,:);
        end
        function [Data] = GetColumn(obj,DATA,ColumnName)
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
                case 'int32'
                    Data = datasetfun(@cell,Data2,'UniformOutput',false);
                    Data = Data{1,1};
                otherwise
                   error(['Class not recognised: ',class(Data2{1,1})])
            end
        end
        function [NewDATASET] = ColumnFiltering(obj,DATASET,Columns)
            %%
            VarNames = get(DATASET,'VarNames');
            
            %Check names exist
            [x] = size(Columns,2);
            String = [];
            for i = 1:x
                logic = isempty(find(strcmpi(Columns{i},VarNames)));
                if logic == 1  
                    if isempty(String)
                        String = [Columns{i}];
                    else
                        String = [String,', ',Columns{i}];
                    end
                end
            end
            if not(isempty(String))
                error(['ColumnFiltering not possible: "',String,'" columns does not exist'])
            end
            
           
            for i = 1:x
                [Data] = obj.GetColumn(DATASET,Columns{i});
                if strcmpi(Columns{i},'DateStr')
                    Columns{i} = 'Date';
                end
                
                if i == 1
                NewDATASET = dataset({Data,Columns{i}});  
                else
                NewDATASET = [NewDATASET,dataset({Data,Columns{i}})];
                end
            end
        end
        function [DATASET] = ColumnStr(obj,DATASET2,ColumnName,String)
            %%
            CLASS = class(String);
            if strcmpi(CLASS,'char') % Single
                [DATASET] = obj.ColumnStrSingle(DATASET2,ColumnName,String);
            else % Multiple
                x = max(size(String));
                for i = 1:x
                    if i == 1
                    DATASET = obj.ColumnStrSingle(DATASET2,ColumnName,String{i});
                    else
                    DATASET = [DATASET;obj.ColumnStrSingle(DATASET2,ColumnName,String{i})];   
                    end
                end
            end
        end
        function [DATASET] = RemoveNaN(obj,DATASET2,ColumnName)
            DATA = obj.GetColumn(DATASET2,ColumnName)
            n = find(not(isnan(DATA)));
            DATASET = DATASET2(n,:);
        end

        function Array = Dataset2Array(obj,DATASET)
            VarNames = get(DATASET,'VarNames');
            [x] = size(VarNames,2);
            for i = 1:x
                VarNames{i}
                temp = obj.GetColumn(DATASET,VarNames{i});
                if not(iscell(temp))
                    temp = num2cell(temp);
                end
                Array(:,i) = temp;
            end
            Array = [VarNames;Array];
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
        function Cell = DataSet2cell(obj,DataSet)
            Headings = get(DataSet,'VarNames');
            DATA = obj.FormatTable(DataSet);
            Cell = [Headings;DATA];
        end
        function DATASET = Array2DataSet(obj,Array)
            %%
            Symbol = Array(:,1);
            DateOfEvent = Array(:,2);
            Price = cell2mat(Array(:,3));
            Action = Array(:,4);
            Confrimation = Array(:,5);
            Profit = cell2mat(Array(:,6));
            DATASET = dataset(Symbol,DateOfEvent,Price,Action,Confrimation,Profit);
        end
        
        function Array2xls(obj,Array,FileName)
            try
                xlswrite(FileName,Array);
            catch
                disp(['Path: ',FileName]);
                error('Problem writing xls file'); 
            end
        end
        function Array2csv(obj,Array,FileName)
            VarNames = {'Symbol','DateOfEvent','Price','Action','Confrimation','Profit'};
            DATA2 = [VarNames;Array];
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
        function DATASET = AddDateStr(obj,ColumnName,DATASET)
            %%
            DATA = obj.GetColumn(DATASET,ColumnName);
            x = size(DATA,1);
            for i = 1:x
               DateStr{i,1} = datestr(DATA(i));
            end
            DATASET = [dataset(DateStr),DATASET];
        end
        
        function DATASET = AddPreFix2ColumnNames(obj,PreFix,DATASET)
            VarNames = get(DATASET,'VarNames');
            x = size(VarNames,2);
            for i = 1:x
                NewVarNames{i} = [PreFix,VarNames{i}];
                Var = obj.GetColumn(DATASET,VarNames{i});
                DATASET = [DATASET,dataset({Var,NewVarNames{i}})];
            end
            DATASET = obj.ColumnFiltering(DATASET,NewVarNames);
        end
        function DATASET = RemovePreFix2ColumnNames(obj,PreFix,DATASET)
            VarNames = get(DATASET,'VarNames');
            x = size(VarNames,2);
            for i = 1:x
                NewVarNames{i} = strrep(VarNames{i},PreFix,'');
                Var = obj.GetColumn(DATASET,VarNames{i});
                DATASET = [DATASET,dataset({Var,NewVarNames{i}})];
            end
            DATASET = obj.ColumnFiltering(DATASET,NewVarNames);
        end
    end
    methods (Hidden = true)
        function [DATASET] = ColumnStrSingle(obj,DATASET2,ColumnName,String)
            [Data] = obj.GetColumn(DATASET2,ColumnName);
            n = strcmpi(Data,String);
            DATASET = DATASET2(n,:);
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
        function writecsv(obj,FileName,DATA)
            fid = fopen(FileName, 'wt');
            [x,y] = size(DATA);
            for i = 1:x
                for j = 1:y
                    Entry = DATA{i,j};
                    switch class(Entry)
                        case 'char'
                            %do nothing
                        case 'double'
                            Entry = num2str(Entry);
                        otherwise
                            error('class not recoginised');
                    end
                    if j == 1
                        Line = [Entry];
                    else
                        Line = [Line,',',Entry];
                    end
                end
                fprintf(fid, [Line,'\n'], y);
            end
            fclose(fid);
        end
    end
end