classdef PGin_FT_Perf < handle & ...
                        DataSetFiltering
    properties
    end
    methods
        function [DATASET2] = Add_CurrencyAndMarketCapAmount(obj,DATASET)
            %%
            MarketCap = obj.GetColumn(DATASET,'MarketCap');
            for i = 1:size(MarketCap)
                string = MarketCap{i};
                
                % Currency
                n = findstr(string,'<span class="currencyCode">');
                Currency{i,1} =  string(n+27:end);
                
                % Amount
                AmountStr = string(1:n-1);
                Amount{i,1} = AmountStr;
                
                % AmountNumUnit
                n = findstr(AmountStr,'.');
                AmountNumUnit{i,1} = AmountStr(n+3:end);
                
                % AmountNum
                AmountNumS = AmountStr(1:n+2);
                AmountNum(i,1) = str2double(AmountNumS);
            end
            DATASET2 = [DATASET,dataset(Currency,Amount,AmountNumUnit,AmountNum)];
        end
        function [DATASET3] = Add_MarketCapNum(obj,DATASET2)
            %%
            Exps= { 't',    1000000000000; ...
                    'bn',   1000000000; ...
                    'm',    1000000; ...
                    'k',    1000; ...
                     };
                 
            AmountNumUnit = obj.GetColumn(DATASET2,'AmountNumUnit');
            AmountNum = obj.GetColumn(DATASET2,'AmountNum');
            
            x = max(size(AmountNumUnit))
            for i = 1:x
                AmountNumUnitStr = AmountNumUnit{i};
                n = find( strcmpi(Exps(:,1), AmountNumUnitStr));
                if not(isempty(n))
                    Exp = Exps{n,2};
                    MarketCapNum(i,1) = AmountNum(i)*Exp;
                else
                    MarketCapNum(i,1) = NaN;
                end
            end
            DATASET3 = [DATASET2,dataset(MarketCapNum)];
        end
        function [DATASET4] = Add_MarketCapInDollars(obj,DATASET3)
            %%
            ExchangeRate = {    'GBP',  1.61026; ...
                                'PLN',  0.345450; ...
                                'USD',  1; ...
                                'EGP',  0.183655; ...
                                'AUD',  0.904134; ...
                                'THB',  0.0302673; ...
                                'NOK',  0.172516; ...
                                'RUB',  0.0334952; ...
                                'CAD',  0.947254; ...
                                'EUR',  1.41576; ...
                                'INR',  0.0217226; ...
                                'TWD',  0.0313050; ...
                                'SEK',  0.138437; ...
                                'CHF',  0.961056; ...
                                'JPY',  0.0110999; ...
                                'KZT',  0.00676361; ...
                                'NGN',  0.00664452; ...
                                'ARS',  0.262605; ...
                                'ZAR',  0.131586; ...
                                'DKK',  0.190139; ...
                                'KRW',  0.000555894; ...
                                'ILS',  0.180492; ...
                                'IDR',  0.0000742348; ...
                                'HKD',  0.0889134; ...
                                'ISK',  0.00533947};  
                            
            Currency = obj.GetColumn(DATASET3,'Currency');
            MarketCapNum = obj.GetColumn(DATASET3,'MarketCapNum');
            
            [x] = size(Currency,1);
            for i = 1:x
                n = find(strcmpi(Currency{i},ExchangeRate(:,1)));
                if not(isempty(n))
                    Rate = ExchangeRate{n,2};
                    MarketCapInDollars(i,1) = MarketCapNum(i)*Rate;
                else
                    MarketCapInDollars(i,1) = NaN;
                end
            end
            DATASET4 = [DATASET3,dataset(MarketCapInDollars)];             
        end
        function [DATASET5] = Add_MarketCapCategory(obj,DATASET4)
            %%
            t  = 1000000000000;
            bn = 1000000000; 
            m  = 1000000;
            k  = 1000; 
                    
            %$       Cat           Low      High
            Cat = { 'Big Cap',    10*bn,    inf; ... 
                    'Mid Cap',    2*bn,     10*bn; ...
                    'Small Cap',  300*m,    2*bn; ... 
                    'Micro Cap',  50*m,     300*m; ... 
                    'Nano Cap',   0,        50*m};
                
            MarketCapInDollars = obj.GetColumn(DATASET4,'MarketCapInDollars');
            x = size(MarketCapInDollars,1);
            for i = 1:x
                MarketCapCategory{i,1} = 'N/A';
                if MarketCapInDollars(i) == 0
                    MarketCapCategory{i,1} = 'N/A';
                end
                % Nano Cap
                if MarketCapInDollars(i) > Cat{5,2};
                    MarketCapCategory{i,1} = Cat{5,1};
                end
                % Micro Cap
                if MarketCapInDollars(i) > Cat{4,2};
                    MarketCapCategory{i,1} = Cat{4,1};
                end
                % Small Cap
                if MarketCapInDollars(i) > Cat{3,2};
                    MarketCapCategory{i,1} = Cat{3,1};
                end
                % Mid Cap
                if MarketCapInDollars(i) > Cat{2,2};
                    MarketCapCategory{i,1} = Cat{2,1};
                end
                % Big Cap
                if MarketCapInDollars(i) > Cat{1,2};
                    MarketCapCategory{i,1} = Cat{1,1};
                end
            end
            DATASET5 = [DATASET4,dataset(MarketCapCategory)];
        end
    end
end