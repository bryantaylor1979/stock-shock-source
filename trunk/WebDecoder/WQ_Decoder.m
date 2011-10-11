classdef WQ_Decoder <   handle & ...
                        ResultsLog & ...
                        DataSetFiltering2
	properties
	end
    methods
        function [Headings,Data] = GetTableArray(obj,raw,struct)
            %%
            
            [y,x] = size(raw);
            
            %%
            if strcmpi(struct.xstartMode,'Start');
                xstart = struct.xstart;
            else
                xstart = x + struct.xstart;
            end
            if strcmpi(struct.xendMode,'Start');
                xend = struct.xend;
            else
                xend = x + struct.xend;
            end
            if strcmpi(struct.ystartMode,'Start');
                ystart = struct.ystart;
            else
                ystart = y + struct.xstart;
            end            
            if strcmpi(struct.yendMode,'Start');
                yend = struct.yend;
            else
                yend = y + struct.yend;
            end
            
            %%
            MainTable = raw(ystart:yend,xstart:xend);
            
            %Remove headings
            Headings = MainTable(1,:);
            Data = MainTable(2:end,:);            
        end
        function DataSet = Process(obj,raw)
            %           
            
            %Remove headings
            [Headings,Data] = obj.GetTableArray(raw,struct)
            
            %Tag with Sector
            Open = cell2mat(Data(1:end,5));
            n = find(isnan(Open)==1);    
            [x] = size(Open,1);
            for i = 1:x
                %Format Symbol
                Symbol = Data{i,1};
                if isnumeric(Symbol)
                    Symbol = num2str(Symbol);
                end
                Data{i,1} = strrep(Symbol,' ','');
                
                present = find(n == i);
                if isempty(present)
                    Sector{i,1} = SectorName;
                else
                    SectorName = Data{i,1};
                end
            end
            Data = [Data,Sector];
            
            %Remove Sector headings
            n = find(isnan(Open)==0);
            Data = Data(n,:);
            
            %Format for dataset
            [x] = size(Headings,2);
            for i = 1:x
                DATA = Data(:,i);
                if ischar(DATA{1})
                    
                else
                    DATA = cell2mat(DATA);
                end
                NewRow = dataset({DATA,Headings{i}});
                if i == 1
                    DataSet = NewRow;
                else
                    DataSet = [DataSet,NewRow];
                end
            end
            NewRow = dataset({Data(:,x+1),'Sector'});
            DataSet = [DataSet,NewRow];
        end
        function DATASET = Table2DataSet(obj,Table,ColumnNames)
            %%            
            %% Detect Fomat
            DetectRow = Table(end,:);
            x = size(DetectRow,2);
            for i = 1:x
                val = DetectRow{i};
                class(val)
                switch class(val)
                    case 'char'
                       N_DATASET = dataset({Table(:,i),ColumnNames{i}}) 
                    case 'double'
                       cellarray = Table(:,i);
                       doublearray = cell2mat(cellarray);
                       N_DATASET = dataset({doublearray,ColumnNames{i}});
                    otherwise
                end
                if i == 1
                    DATASET = N_DATASET;
                else
                    DATASET = [DATASET,N_DATASET];
                end
            end
        end
        function [Table,ColumnNames] = TableCrop(obj,Table,struct)
            %%
            ColumnNames = Table(struct.ColumnName_Row,struct.ColumnName_Range);
            Table = Table(5:end-struct.End_Row,struct.ColumnName_Range);            
        end
    end
end
