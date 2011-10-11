classdef SymbolInfo
%Example
%obj = SymbolInfo;
%obj.ReadMap('III_IndexMap');
%
    properties
        Data = [];
        FieldNames = [];
        SectorList = [];
        InstallDir = ['C:\HmSourceSafe\Stocks & Shares\Programs\Trade Guide\'];
        MapFiles = {'III_IndexMap'};
    end
    methods
        function [obj] = ReadMap(obj,filename)
            CurrentDir = pwd;
            cd([obj.InstallDir,'Maps']);
            [obj.Data,obj.FieldNames,obj.SectorList] = feval(filename);
            cd(CurrentDir);
        end
        function [Number] = NumberInSector(obj,Sector)
            if isempty(obj.Data)
               uiwait(msgbox('No Map Loaded: Please Use the ReadMap function'));
               return 
            end
            SectorData = obj.Data(:,1);
            n = find(strcmpi(SectorData,Sector));
            Number = size(n,1);
        end
        function [Data] = NumberInSectors(obj)
            SectorList = obj.SectorList;
            [x] = size(SectorList,1);
            for i = 1:x
                disp([SectorList{i},', ',num2str(obj.NumberInSector(SectorList{i}))])
                Data{i,1} = SectorList{i};
                Data{i,2} = obj.NumberInSector(SectorList{i});
            end
        end
        function [Symbols] = SymbolList(obj)
           Symbols = obj.Data(:,2); 
        end
        function [Symbols] = GetIndexSymbols(obj,Index)
            [Description] = obj.GetIndexDescription(Index);
            n = find(strcmpi(obj.Data(:,1),Description));
            Symbols = obj.Data(n,2);
        end
        function [Indexs] = IndexList(obj)
           Indexs = obj.SectorList(:,2); 
        end
        function [Description] = GetIndexDescription(obj,Index)
            Indexs = obj.SectorList(:,2);
            n = find(strcmpi(Indexs,Index));
            Description = obj.SectorList{n,1};
        end
        function [Description] = GetSymbolDescription(obj,Symbol)
            n = find(strcmpi(obj.Data(:,2),Symbol));
            Description = obj.Data{n,3};
        end
    end
end