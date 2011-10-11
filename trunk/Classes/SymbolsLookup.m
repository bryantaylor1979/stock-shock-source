classdef SymbolsLookup < handle
    %Example:
    %   Symbols = obj.LoadInvestedSymbols('InvestedSymbolList.txt');
    properties
    end
    properties (Hidden = true)
        SL_Rev = 0.01;
        InvestedSymbolDir2 = 'C:\SourceSafe\Stocks & Shares\Programs\WhatBrokersSay\'
        BritishBullDir = 'C:\SourceSafe\Stocks & Shares\Programs\BritishBulls\';
    end
    methods
        function InvestedSymbolList = LoadInvestedSymbols(obj,Name)
            try
              file = textread([obj.InvestedSymbolDir,Name],'%s','delimiter','\n','whitespace','');
            catch
               error(['Filename not found: ',obj.InvestedSymbolDir,Name])
            end
              [x] = size(file,1);
              for i = 1:x
                  eval(file{i});
              end
              obj.Symbols = InvestedSymbolList;
        end
        function Symbols = III_SymbolsList(obj,Set)
            DataObj = LocalDatabase;
            DataObj.Location = obj.Location;
            SymbolObj = SymbolInfo;
            SymbolObj.InstallDir = obj.InstallDir;
            SymbolObj = SymbolObj.ReadMap('III_IndexMap');      
            switch lower(Set)
                case 'index'
                Symbols = SymbolObj.IndexList;  
                case 'symbol'
                Symbols = SymbolObj.SymbolList;   
                case 'both'
                Symbols = [SymbolObj.IndexList;SymbolObj.SymbolList];     
                otherwise
            end
        end
    end
end