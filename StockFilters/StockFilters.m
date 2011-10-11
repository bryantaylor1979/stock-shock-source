classdef StockFilters
    properties
        URL = 'http://www.iii.co.uk/markets/index.epl?type=stockfilter&peratiomin=10&buys_1min=1&';
    end
    methods
        function [obj] = StockFilters()
            S = urlread(obj.URL)
        end
    end
end
