classdef readsymbolslist < handle
    properties
        % Set Defaults
        struct = [];
        FieldNames = [];
        SectorList = [];  
    end
    methods
        function obj = readsymbolslist(varargin)
            filename = varargin{1};
            varargin = varargin(2:end);
            x = size(varargin,2);
            for i = 1:2:x
               obj.(varargin{i}) = varargin{i+1};
            end
            obj.struct = obj.ReadMap(filename);
        end
        function Example(obj)
            %%
            close all
            clear classes
            obj = readsymbolslist('iii_map_v2.m')
            Number = obj.NumberInSector('AerospaceAndDefence')
            List = obj.GetSectorList()
            Data = obj.NumberInSectors()
            Symbols = obj.SymbolList()
            Symbols = obj.GetIndexSymbols('AerospaceAndDefence')
            Description = obj.GetIndexDescription('^NMX2710')
            info = obj.GetSymbolsInfo('TRT.L')
        end
        function [Number] = NumberInSector(obj,Sector)
            SectorData = obj.struct.(Sector).Symbols;
            Number = size(SectorData,2);
        end
        function [Data] = NumberInSectors(obj)
            SectorList = obj.GetSectorList();
            [x] = size(SectorList,1)
            for i = 1:x
                try
                disp([SectorList{i},', ',num2str(obj.NumberInSector(SectorList{i}))])
                Data{i,1} = SectorList{i};
                Data{i,2} = obj.NumberInSector(SectorList{i});
                catch
                    warning('sector has no symbols')
                end
            end
        end
        function [Symbols] = SymbolList(obj)
            [Indexs] = obj.GetSectorList();
            x = size(Indexs,1);
            Symbols = [];
            for i = 1:x
                try
                    if i == 1
                    Symbols = obj.GetIndexSymbols(Indexs{i});  
                    else
                    N_Symbols = obj.GetIndexSymbols(Indexs{i});
                    Symbols = [Symbols;N_Symbols];
                    end
                catch
                    warning('sector does not have symbols')
                end
            end
        end
        function [Symbols] = GetIndexSymbols(obj,Index)
            SymbolsStruct = obj.struct.(Index).Symbols;
            Array = struct2cell(SymbolsStruct);
            [x,y,z] = size(Array);
            Symbols = reshape(Array(1,:,:),z,1);
        end
        function [Indexs] = GetSectorList(obj)
            Indexs = fieldnames(obj.struct);
        end
        function [Description] = GetIndexDescription(obj,Index)
            Indexs = obj.GetSectorList();
            x = size(Indexs,2);
            for i = 1:x
                Description = obj.struct.(Indexs{i}).Name;
                Symbol = obj.struct.(Indexs{i}).Symbol;
                if strcmpi(Index,Symbol)
                    break
                end
            end
        end
        function [info] = GetSymbolsInfo(obj,Symbol)
            Indexs = obj.GetSectorList();
            x = size(Indexs,2);
            for i = 1:x
                Description = obj.struct.(Indexs{i}).Name;
                Symbols = obj.struct.(Indexs{i}).Symbols;
                y = size(Symbols,2);
                for j = 1:y
                    Index = obj.struct.(Indexs{i}).Symbols(j).TickerSymbol;
                    if strcmpi(Index,Symbol)
                        info.SectorDescription = Description;
                        info.Sector = Indexs{i};
                        info.Name = obj.struct.(Indexs{i}).Symbols(j).CompanyName;
                        break
                    end
                end
            end
        end
    end
    methods (Hidden = true)
        function struct = ReadMap(obj,filename)
            fid = fopen(filename);

            tline = fgets(fid);
            while ischar(tline)
                try
                eval(tline);
                catch
                disp(tline);    
                end
                tline = fgets(fid);
            end

            fclose(fid);
        end
    end
end
