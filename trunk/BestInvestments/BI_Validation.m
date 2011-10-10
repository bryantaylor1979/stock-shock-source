classdef BI_Validation < handle
    properties
    end
    methods % High Level
        function PassRate = Check_TradeTable(obj,TT_DataSet)
            %%
            x = size(TT_DataSet,1);
            count = 0;
            PassNo = 0;
            for i = 1:x
                Trade = TT_DataSet(i,:);
                StatusBuy{i} = obj.CheckTradeForBuyConf(Trade);
                StatusSell{i} = obj.CheckTradeForSellConf(Trade);
                StatusBuyPrice{i} = obj.CheckTradeForBuyPrice(Trade)
            end
            
            %
            PassNo = size(find(strcmpi(StatusBuy,'PASS')),2);
            FailNo = size(find(strcmpi(StatusBuy,'FAIL')),2);
            BuyPassRate = PassNo/(PassNo+FailNo)
            %
            PassNo = size(find(strcmpi(StatusSell,'PASS')),2);
            FailNo = size(find(strcmpi(StatusSell,'FAIL')),2);
            SellPassRate = PassNo/(PassNo+FailNo)
            %
            PassNo = size(find(strcmpi(StatusBuyPrice,'PASS')),2);
            FailNo = size(find(strcmpi(StatusBuyPrice,'FAIL')),2);
            BuyPricePassRate = PassNo/(PassNo+FailNo)
        end
    end
    methods %Low Level
        function Status = CheckTradeForBuyConf(obj,Trade)
            %Check by confirm on ALL_STATUS
            Symbol = obj.GetColumn(Trade,'Symbol');
            BuyDate = obj.GetColumn(Trade,'BuyDate');
            DataSet = obj.LoadResult('BritishBulls','ALL_STATUS',datenum(BuyDate)-1);
            if isempty(DataSet)
                disp('Unable to cross check this trade')
                Status = 'UNKNOWN';
            else
                try
                    TradeConf = obj.ColumnStr(DataSet,'Ticker',{Symbol});
                    Signal = obj.GetColumn(TradeConf,'Signal');
                    if strcmpi(Signal,'BUY CONF')
                        Status = 'PASS';
                    else
                        Status = 'FAIL';
                    end
                catch %Symbol not found in ALL_STATUS
                    Status = 'UNKNOWN';
                end
            end           
        end
        function Status = CheckTradeForSellConf(obj,Trade)
            %Check by confirm on ALL_STATUS
            Symbol = obj.GetColumn(Trade,'Symbol');
            BuyDate = obj.GetColumn(Trade,'SellDate');
            DataSet = obj.LoadResult('BritishBulls','ALL_STATUS',datenum(BuyDate)-1);
            if isempty(DataSet)
                disp('Unable to cross check this trade')
                Status = 'UNKNOWN';
            else
                try
                    TradeConf = obj.ColumnStr(DataSet,'Ticker',{Symbol});
                    Signal = obj.GetColumn(TradeConf,'Signal');
                    if strcmpi(Signal,'SELL CONF')
                        Status = 'PASS';
                    else
                        Status = 'FAIL';
                    end
                catch %Symbol not found in ALL_STATUS
                    Status = 'UNKNOWN';
                end
            end           
        end
        function Status = CheckTradeForBuyPrice(obj,Trade)
             Symbol = obj.GetColumn(Trade,'Symbol')
             BuyDate = obj.GetColumn(Trade,'BuyDate')
             BuyPrice = obj.GetColumn(Trade,'BuyPrice')
             [Open,PreClose] = obj.GetSymbolQuote(Symbol{1},datenum(BuyDate{1}))
             if BuyPrice >= Open
                 Status = 'PASS';
             else
                 Status = 'FAIL';
             end
        end
    end
    methods
        function ErrorAnalysis(obj) %Check Trade Plan 1 vs 3
            %%
            ErrorTrades = obj.CompareSymbolsSetFrom_TradeTable;
            
            %%
            Trade = ErrorTrades(1,:)
            
            %% Get Buy Query
            BuyDateNum = datenum(obj.GetColumn(Trade,'BuyDate'))
            obj.LoadResult('QuoteAbstractionLayer','BB_BuyConf',BuyDateNum)
            
            obj.LoadResult('QuoteAbstractionLayer','BB_MoneyInvested',BuyDateNum)
        end
        function ErrorTrades = CompareSymbolsSetFrom_TradeTable(obj)
            %%
            StratName1 = 'BB_Basic';
            StratName2 = 'BB_MoneyInvested';
            
            % Load TT One
            file = [obj.InstallDir,'Results\',StratName1,'\DATASET\Per_TT_DataSet.mat']
            load(file);
            Per_TT_DataSet1 = Per_TT_DataSet;
            
            % Load TT Two
            file = [obj.InstallDir,'Results\',StratName2,'\DATASET\Per_TT_DataSet.mat']
            load(file);
            Per_TT_DataSet2 = Per_TT_DataSet;
            
            %
            Symbols = obj.GetColumn(Per_TT_DataSet2,'Symbol');
            BuyDateNums = obj.GetColumn(Per_TT_DataSet2,'BuyDateNum');
            
            %Get Symbol Sets
            x = size(Per_TT_DataSet1,1);
            first = true;
            
            for i = 1:x
                Trade = Per_TT_DataSet1(i,:);
                Symbol = obj.GetColumn(Trade,'Symbol');
                BuyDateNum = obj.GetColumn(Trade,'BuyDateNum');
                
                n = find(strcmpi(Symbol,Symbols));
                Temp = Per_TT_DataSet2(n,:);
                TempBuyDateNums = BuyDateNums(n);
                n = find(BuyDateNum == TempBuyDateNums);
                
                if isempty(n) % Error trade
                    if first == true
                        ErrorTrades = Trade;
                        first = false;
                    else
                        ErrorTrades = [ErrorTrades;Trade];
                    end
                end
            end
        end
    end
end