classdef Yahoo <    handle & ...
                    InvestedSymbols & ...
                    DataSetFiltering & ...
                    Comms & ...
                    ResultsLog & ...
                    MacroRun
    methods %Main functions
        function DATASET3 = CombineDataSets(obj,BUY_DATASET,SELL_DATASET)
            %% Combine Events
            if and(isempty(BUY_DATASET),not(isempty(SELL_DATASET)))
                DATASET3 = SELL_DATASET;
            elseif and(isempty(SELL_DATASET),not(isempty(BUY_DATASET)))
                DATASET3 = BUY_DATASET;
            else
                DATASET3 = [BUY_DATASET;SELL_DATASET];
            end
        end
        function DATASET = GetSharePriceQuery(obj,Symbols,Fields)
            objSP = SharePrice;
            DATASET = objSP.WEB_Query(Symbols);
            DATASET = obj.ColumnFiltering(DATASET,Fields);
        end
        function Symbols = GetAllSymbols(obj)
            sobj = SymbolInfo;
            sobj.InstallDir = obj.InstallDir;
            sobj.ReadMap('III_IndexMap');
            Symbols = sobj.Data(:,2);
        end
        function Symbols = GetBBSymbols(obj,Date)
            FileName = [obj.RootDir,'BritishBulls\Results\SystemConfirmed\DataSet\',datestr(Date),'.mat'];
            load(FileName);
            Symbols = obj.GetColumn(DataSet,'Ticker');
            [x] = size(Symbols,1);
            for i = 1:x
                Symbols{i,1} = [Symbols{i,1},'.L'];
            end
        end
        function Date = Today(obj)
            FileName = [obj.RootDir,'BritishBulls\Results\SystemConfirmed\DataSet\'];
            CD = pwd;
            cd(FileName);
            names = struct2cell(dir);
            Name = rot90(strrep(names(1,:,:),'.mat',''));
            DateNum = max(datenum(Name(1:end-2)));
            
            if DateNum == today
                Date = today;
            else
                Date = DateNum;
            end
            cd(CD);
        end
        function [DATASET] = Yahoo_BuyCalcConfirmed(obj,DATASET)
            %% Identify Unconfirmed - Price open below yesterdays close.
            Open = obj.GetColumn(DATASET,'o');
            PreviousClose = obj.GetColumn(DATASET,'p');
            PriceChangeSincePreviousClose = obj.GetColumn(DATASET,'c1');
            Price = PreviousClose + PriceChangeSincePreviousClose;
            Change1 = (Price./PreviousClose - 1).*100;
            %%
            OC_Ratio = Open./PreviousClose;
            [x] = size(OC_Ratio,1);
            for i = 1:x
                % Case 1:
                % =======
                % The market opens with an upward gap, signaling a bullish sentiment in the first case. 
                % Your benchmark will be the opening price. If the prices stay over the benchmark, go long. 
                % Any white candlestick with an upward gap is a valid confirmation criterion. 
                if 1 > OC_Ratio(i)
                    
                    Bench(i,1) = Open(i);

                else
                % Case 2:
                % ======
                % In the second case, the market opens at a level, equal to or below the previous day�s close. 
                % The benchmark is that closing price. If prices during the session stay over the benchmark, 
                % go long. Any white candlestick closing above the previous day�s close is the second confirmation 
                % criterion. 
                    Bench(i,1) = PreviousClose(i);
                end
                Ratio(i,1) = Price(i,1)/Bench(i,1);
                if Ratio(i,1) > 1
                    Conf{i,1} = 'TRUE';
                else
                    Conf{i,1} = 'FALSE';
                end
            end
            DATASET = dataset(PreviousClose,Open,Bench,Conf,Change1);
        end
        function [DATASET] = SP_BuyCalcConfirmed(obj,DATASET)
            %% Identify Unconfirmed - Price open below yesterdays close.
            Open = obj.GetColumn(DATASET,'Open');
            PreviousClose = obj.GetColumn(DATASET,'PrevClose');
            PriceChangeSincePreviousClose = obj.GetColumn(DATASET,'PriceChange');
            Price = obj.GetColumn(DATASET,'Price');
            Change1 = (Price./PreviousClose - 1).*100;
            %%
            OC_Ratio = Open./PreviousClose;
            [x] = size(OC_Ratio,1);
            for i = 1:x
                % Case 1:
                % =======
                % The market opens with an upward gap, signaling a bullish sentiment in the first case. 
                % Your benchmark will be the opening price. If the prices stay over the benchmark, go long. 
                % Any white candlestick with an upward gap is a valid confirmation criterion. 
                if 1 > OC_Ratio(i)
                    
                    Bench(i,1) = Open(i);

                else
                % Case 2:
                % ======
                % In the second case, the market opens at a level, equal to or below the previous day�s close. 
                % The benchmark is that closing price. If prices during the session stay over the benchmark, 
                % go long. Any white candlestick closing above the previous day�s close is the second confirmation 
                % criterion. 
                    Bench(i,1) = PreviousClose(i);
                end
                Ratio(i,1) = Price(i,1)/Bench(i,1);
                if Ratio(i,1) > 1
                    Conf{i,1} = 'TRUE';
                else
                    Conf{i,1} = 'FALSE';
                end
            end
            DATASET = dataset(PreviousClose,Open,Bench,Conf,Change1);
        end
        function [DATASET] = Yahoo_SellCalcConfirmed(obj,DATASET)
            %% Identify Unconfirmed - Price open below yesterdays close.
            Open = obj.GetColumn(DATASET,'o');
            PreviousClose = obj.GetColumn(DATASET,'p');
            High = obj.GetColumn(DATASET,'h');
            PriceChangeSincePreviousClose = obj.GetColumn(DATASET,'c1');
            Price = PreviousClose + PriceChangeSincePreviousClose;

            %%
            OC_Ratio = Open./PreviousClose;
            [x] = size(OC_Ratio,1);
            for i = 1:x
                if 1 < OC_Ratio(i)  %Criteria 1:    Opens with a downward gap. 
                                    %               The opening price is use as a benchmark. 
                    Bench(i,1) = Open(i);
                else
                    Bench(i,1) = PreviousClose(i);
                end
                if Price(i) < Bench(i);
                    Conf{i,1} = 'TRUE';
                else
                    Conf{i,1} = 'FALSE';
                end
            end
            
            %Change
            Change1 = (Price./PreviousClose - 1).*100;
            
            DATASET = dataset(PreviousClose,Open,Bench,Conf,Change1);
        end
        function [DATASET] = SP_SellCalcConfirmed(obj,DATASET)
            %% Identify Unconfirmed - Price open below yesterdays close.
            Open = obj.GetColumn(DATASET,'Open');
            PreviousClose = obj.GetColumn(DATASET,'PrevClose');
            PriceChangeSincePreviousClose = obj.GetColumn(DATASET,'PriceChange');
            Price = obj.GetColumn(DATASET,'Price');

            %%
            OC_Ratio = Open./PreviousClose;
            [x] = size(OC_Ratio,1);
            for i = 1:x
                if 1 < OC_Ratio(i)  %Criteria 1:    Opens with a downward gap. 
                                    %               The opening price is use as a benchmark. 
                    Bench(i,1) = Open(i);
                else
                    Bench(i,1) = PreviousClose(i);
                end
                if Price(i) < Bench(i);
                    Conf{i,1} = 'TRUE';
                else
                    Conf{i,1} = 'FALSE';
                end
            end
            
            %Change
            Change1 = (Price./PreviousClose - 1).*100;
            
            DATASET = dataset(PreviousClose,Open,Bench,Conf,Change1);
        end
        function SendSMS_Alert(obj,DATASET3)
            %%
            NoOfAlerts = size(DATASET3,1);
            for i = 1:NoOfAlerts
                DATASET = DATASET3(i,:);
                Ticker = obj.GetColumn(DATASET,'Ticker');
                Signal = strrep(obj.GetColumn(DATASET,'Signal'),'-IF','');
                Bench = obj.GetColumn(DATASET,'Bench');
                Conf = obj.GetColumn(DATASET,'Conf');
                Change = obj.GetColumn(DATASET,'Change1');
                Change = round(Change*100)/100;
                String1 = [Ticker{1},'   ',Signal{1},' :   ',num2str(Change),'% __'];
                if i == 1
                    String = String1;
                else
                    String = [String;{String1}];
                end
            end
            if NoOfAlerts > 0
                String
            obj.SendSMS('07841689090',String); 
            end
        end
    end
    methods %Filtering
        function DataSet = RemoveSpread(obj,DataSet,Threshold)
            Spread = obj.GetColumn(DataSet,'Spread');
            n = find(Spread < Threshold);
            DataSet = DataSet(n,:);
        end
    end
    methods (Hidden = true) %Support functions - Field Name Manage.
    end
    methods (Hidden = true) %Support functions
        function [obj] = Yahoo(varargin)
            [x] = size(varargin,2);
            for i = 1:2:x
               obj.(varargin{i}) = varargin{i+1};  
            end
            
            load([obj.InstallDir,'Tags.mat'])
            obj.TagsArray = DATASET;
            if strcmpi(obj.RunOnInt,'on')
                obj.RunMacro(obj.MacroName);
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
    end
end