classdef WhatBrokersSay <   handle & ...
                            Comms & ...
                            MacroRun & ...
                            DataSetFiltering & ...
                            InvestedSymbols & ...
                            ResultsLog & ...
                            URL_Download
                        
    properties %Visible to the User
        DistributionDir = 'C:\SourceSafe\Stocks & Shares\Programs\WhatBrokersSay\';
        InstallDir = 'C:\SourceSafe\Stocks & Shares\Programs\WhatBrokersSay\'
    end
    properties (Hidden = true) %You should not modify any of these properties.
        handles
        ProgramName = 'WhatBrokersSay';
    end
    methods 
        function LoadInvestedSymbols(obj,Name)
              file = textread([obj.InvestedSymbolDir,Name],'%s','delimiter','\n','whitespace','');
              [x] = size(file,1);
              for i = 1:x
                  eval(file{i});
              end
              obj.InvestedSymbolList = InvestedSymbolList;
        end
        function LoadDistributionList(obj,Name)
              file = textread([obj.DistributionDir,Name],'%s','delimiter','\n','whitespace','');
              [x] = size(file,1);
              for i = 1:x
                  eval(file{i});
              end
              obj.EmailAdd = EmailAdd;
        end
    end
    methods %Filtering
        function [DATA] = GetTodaysEntries(obj,DATA)
            DateNum = double(obj.GetColumn(DATA,'DateNum'));
            n = find(DateNum == floor(now));
            DATA = DATA(n,:);
        end
        function [DATA] = Remove_NoOfDaysOld(obj,DATA,NoOfDays)
            DateNum = double(obj.GetColumn(DATA,'DateNum'));
            n = find(DateNum > floor(now)-NoOfDays);
            DATA = DATA(n,:);
        end
        function [DATA] = FilterOnProfit(obj,DATA,ProfitRange)
            Profit = double(obj.GetColumn(DATA,'Profit'));
            
            n = find(Profit > ProfitRange(1)); % Greater than
            DATA = DATA(n,:);
            Profit = Profit(n);
            
            n = find(Profit < ProfitRange(2)); % Greater than
            DATA = DATA(n,:);
        end
        function [BuildData] = FilterOnInvestmentSymbolsOnly(obj,DATA)
            [x] = size(obj.InvestedSymbolList,1)
            First = true;
            for i = 1:x
                Symbol = strrep(obj.InvestedSymbolList{i},'.L','');
                [Data] = obj.FindTicker(DATA,Symbol);
                if isempty(Data)
                else
                    if First == true
                        First = false;
                        BuildData = Data;
                    else
                        BuildData = [BuildData;Data];
                    end
                end
            end
        end
        function [DATA] = FilterOffOld(obj,DATA)
            %%
            Ticker = obj.GetColumn(DATA,'Ticker');
            BrokerName = obj.GetColumn(DATA,'BrokerName');
            
            ShortListTicker = obj.RemoveMultipleEntries(Ticker);
            
            x = size(ShortListTicker,2);
            N_DATA = [];
            for i = 1:x
                n = find(strcmpi(Ticker,ShortListTicker{i}));
                NewDATA = DATA(n,:);
                NewBrokerName = BrokerName(n);
                BrokerNameShortList = obj.RemoveMultipleEntries(NewBrokerName);
                y = size(BrokerNameShortList,2);
                DataBrokerName = obj.GetColumn(NewDATA,'BrokerName');
                for j = 1:y
                    n = find(strcmpi(BrokerNameShortList{j},DataBrokerName));
                    FDATA = NewDATA(n,:);
                    DateNum = obj.GetColumn(FDATA,'DateNum');
                    MaxDateNum = max(DateNum);
                    n = find(DateNum == MaxDateNum);
                    n = n(1);
                    
                    if isempty(N_DATA)
                        N_DATA = FDATA(n,:);
                    else
                        N_DATA = [N_DATA;FDATA(n,:)];
                    end
                end
            end
            DATA = N_DATA;
        end
        function ShortListTicker = RemoveMultipleEntries(obj,Ticker)
            %% Remove multiple entries
            Ticker = sort(Ticker);
            x = size(Ticker,1);
            ShortListTicker(1) = Ticker(1);
            count = 2;
            for i = 1:x-1
                if not(strcmpi(Ticker{i},Ticker{i+1}));
                    ShortListTicker(count) = Ticker(i+1);
                    count = count + 1;
                end
            end          
        end
    end
    methods %New Column Calcs
        function [DATA] = CalculateProfit(obj,DATA)
            PriceTarget = double(obj.GetColumn(DATA,'CurrentPriceTarget'));
            Price = double(obj.GetColumn(DATA,'Price'));
            [x] = size(PriceTarget,1);
            for i = 1:x
                if not(isnan(Price(i)))
                    Profit(i,1) = PriceTarget(i)/Price(i);
                else
                    Profit(i,1) = NaN;
                end
            end
            DATA = [DATA,dataset(Profit)];
        end
        function [DATA] = GetCurrentTargetPrice(obj,DATA)
            %%
            OldPriceTarget = double(obj.GetColumn(DATA,'OldPriceTarget'));
            NewPriceTarget = double(obj.GetColumn(DATA,'NewPriceTarget'));
            
            [x] = size(OldPriceTarget,1);
            for i = 1:x
                if not(isnan(NewPriceTarget(i)))
                    PriceTarget(i,1) = NewPriceTarget(i);
                elseif not(isnan(OldPriceTarget(i)))
                    PriceTarget(i,1) = OldPriceTarget(i);
                else
                    PriceTarget(i,1) = NaN;
                end
            end
            CurrentPriceTarget = PriceTarget;
            try
            DATA = [DATA,dataset(CurrentPriceTarget)];
            catch
            end
        end
    end
    methods %Data Mangement
        function [DATA] = LoadAllData(obj)
            %%
            path = pwd;
            cd(obj.DataLocation);
            names = struct2cell(dir);
            Name = names(1,3:end);
            cd(path);
            [x] = size(Name,2);
            
            for i = 1:x
               n = findstr(Name{i},'.mat'); % Make sure only .mat file are processed
               if not(isempty(n))
                   load([obj.DataLocation,Name{i}]);
                   if i == 1
                   BuildTable = DATA;
                   else
                   BuildTable = [BuildTable;DATA];
                   end
               end
            end
            clear DATA
            DATA = BuildTable;
            %Sort data
            DATA = sortrows(DATA,'DateNum','descend');
        end
    end
    methods (Hidden = true) %Support function (Should need to use these!)
        function [obj] = WhatBrokersSay(varargin)
            [x] = size(varargin,2);
            for i = 1:2:x
                obj.(varargin{i}) = varargin{i+1};
            end        
                       
            %%
            if obj.RunOnInt == true
                obj.RunMacro(obj.Macro);
            end                
        end
        function [Output] = FormatTable(obj,DATA)
            %%
            [y,x] = size(DATA);
            
            %%
            for i = 1:x %Date
                Type = DATA{1,i};
                switch class(Type)
                    case 'double'
                       Num = double(DATA(:,i));
                       Output(:,i) = num2cell(Num,2);
                    case 'char'
                       TEMP = datasetfun(@cell,DATA(:,i),'UniformOutput',false);
                       Output(:,i) = TEMP{1};
                    otherwise
                end
            end
        end      
        function [Data] = FindTicker(obj,DATA,Ticker)
            Names = GetColumn(DATA,'Ticker');
            Names = datasetfun(@cell,Names,'UniformOutput',false);
            n = find(strcmpi(Names{1},Ticker));
            Data = [DATA(n,:)];
        end
    end
end
