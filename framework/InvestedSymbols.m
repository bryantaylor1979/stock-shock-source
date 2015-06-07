classdef InvestedSymbols < handle
    properties
        Symbols
        InvestedSymbolDir = 'A:\Stocks & Shares\Programs\WhatBrokersSay\'
        BritishBullDir = 'A:\Stocks & Shares\Programs\BritishBulls\';
    end
    properties (Hidden = true)
        IS_Rev = 0.01;
    end
    methods
        function InvestedSymbolList = LoadInvestedSymbols(obj,Name)
              file = textread([obj.InvestedSymbolDir,Name],'%s','delimiter','\n','whitespace','');
              [x] = size(file,1);
              for i = 1:x
                  eval(file{i});
              end
              obj.Symbols = InvestedSymbolList;
        end
        function Ticker = LoadBB_AllStatusList(obj,DateNum)
            DATASET = obj.LoadLastResult('BritishBulls','ALL_STATUS',DateNum);
            Ticker = obj.GetColumn(DATASET,'Ticker');
        end
        function Symbols = GetDownloadSymbols(obj,Folder)
            PWD = pwd;
            PATH = [obj.BritishBullDir,Folder,'\'];
            cd(PATH)
            names = dir;
            Names = rot90(struct2cell(names));
            Names = Names(1:end-2,1);
            [x] = size(Names,1);
            Names2 = [];
            for i = 1:x
                if  isempty(findstr(Names{i},'.mat'))
                else
                    Names2 = [Names2;Names(i)];
                end
            end
            Symbols = strrep(Names2,'.mat','');
            cd(PWD)
        end 
    end
end