classdef SymbolInfo < handle
%Example
%obj = SymbolInfo;
%obj.ReadMap('III_IndexMap');
%
%Rev 0.01   Add Rev number, program name property
%Rev 0.02   Read map from non compiled map.
%Rev 0.03   Descriptions added for each function
%           Symbol2Sector function added
%           SectorName2Symbol function added.
%
%TODO: Make map read from txt files.
    properties
        Data = [];
        FieldNames = [];
        SectorList = [];
        InstallDir = 'C/home/imagequality/stock-shock-source/download_url/';
        MapFiles = {'III_IndexMap'};
        Rev = 0.05;
        ProgramName = 'Symbol Information';
    end
    methods
        function ReadMap(obj,filename)
            drawnow;
            Filename = fullfile(obj.InstallDir,'Maps',[filename,'.map'])
            s = textread(Filename,'%s','delimiter','\n');
            [x] = size(s,1);
            String = [];
            for i = 1:x
               count = 1;
               NewString = s{i};
               if isempty(NewString)
               else
                   n = findstr(NewString,'...');
                   if isempty(n)
                       EvalString = [String,NewString];
                       eval(EvalString);
                       String = [];
                   else
                       NewString = strrep(NewString,'...','');
                       String = [String,NewString];
                   end
               end
            end
            obj.Data = Map;
            obj.FieldNames = FieldNames;
            obj.SectorList = SectorList;
%             [obj.Data,obj.FieldNames,obj.SectorList] = feval();
        end
        % Read map file
        function [Number] = NumberInSector(obj,Sector)
            if isempty(obj.Data)
               uiwait(msgbox('No Map Loaded: Please Use the ReadMap function'));
               return 
            end
            SectorData = obj.Data(:,1);
            n = find(strcmpi(SectorData,Sector));
            Number = size(n,1);
        end
        % Returns the number of symbol in that sector
        function [Data] = NumberInSectors(obj)
            SectorList = obj.SectorList;
            [x] = size(SectorList,1);
            for i = 1:x
                disp([SectorList{i},', ',num2str(obj.NumberInSector(SectorList{i}))])
                Data{i,1} = SectorList{i};
                Data{i,2} = obj.NumberInSector(SectorList{i});
            end
        end
        % Batch process every sector and display number of symbols in that
        % sector.
        function [Symbols] = SymbolList(obj)
           Symbols = obj.Data(:,2); 
        end
        % Complete list of all symbols
        function [Symbols] = GetIndexSymbols(obj,Index)
            [Description] = obj.GetIndexDescription(Index);
            n = find(strcmpi(obj.Data(:,1),Description));
            Symbols = obj.Data(n,2);
        end
        % Return symbol list for that sector
        function [Indexs] = IndexList(obj)
           Indexs = obj.SectorList(:,2); 
        end
        % Return a list of index symbols.
        function [Description] = GetIndexDescription(obj,Index)
            Indexs = obj.SectorList(:,2);
            n = find(strcmpi(Indexs,Index));
            Description = obj.SectorList{n,1};
        end
        % Retruns the index description
        function [Description] = GetSymbolDescription(obj,Symbol)
            obj.Data(:,2);
            n = find(strcmpi(obj.Data(:,2),Symbol));
            Description = obj.Data{n,3};
        end
        % Returns the Symbol description
        function [Sector] = Symbol2Sector(obj,Symbol)
        % Returns Sector from symbol
            obj.Data(:,2);
            n = find(strcmpi(obj.Data(:,2),Symbol));
            Sector = obj.Data(n,1);
        end
        function [Symbol] = SectorName2Symbol(obj,SectorName)
            n = find(strcmpi(obj.SectorList(:,1),SectorName));
            Symbol = obj.SectorList(n,2);
        end
    end
end