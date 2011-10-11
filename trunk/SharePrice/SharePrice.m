classdef SharePrice
    %Example: obj = SharePrice;
    %         DATASET = obj.WEB_Query({'HAWK','CSLT'})  
    properties
        url = 'http://www.shareprice.co.uk/'
        loglevel = 0;
        InstallDir = 'C:\SourceSafe\Stocks & Shares\Programs\SharePrice\';
    end
    methods
    end
    methods (Hidden = true)
        function DATASET = GetTradeTable(obj,raw)
            n = find(strcmpi(raw(:,1),'Bid / Ask'));
            try
               DATA = raw(n-1:n+6,1:2);
            catch
               Price = NaN;
               PriceChange = NaN;
               PercentageChange = NaN;
               Bid = NaN;
               Ask = NaN;
               Open = NaN;
               PrevClose = NaN;
               Volume = NaN;
               DayLow = NaN;
               DayHigh = NaN;
               YearLow = NaN;
               YearHigh = NaN;
               Time = NaN;
               TimeStr = NaN;
               DATASET = dataset(   Price, ...
                                    PriceChange, ...
                                    PercentageChange, ...
                                    Bid, ...
                                    Ask, ...
                                    Open, ...
                                    PrevClose, ...
                                    Volume, ...
                                    DayLow, ...
                                    DayHigh, ...
                                    YearLow, ...
                                    YearHigh, ...
                                    Time, ...
                                    TimeStr);
               return
            end
            
            %PercentageChange
            PriceChange = DATA{1,1};
            n1 = strfind(PriceChange,'(');
            PercentageChange = str2num(PriceChange(n1+1:end-2));
            
            %Bid/Ask
            BidAsk = DATA{2,2};
            n2 = strfind(BidAsk,'-');
            Bid = str2num(BidAsk(1:n2-1));
            Ask = str2num(BidAsk(n2+1:end));
            
            %Open, PrevClose, Volume
            Open =      DATA{3,2};
            PrevClose = DATA{4,2};
            Volume =    DATA{5,2};
            
            %Day range
            DayRange = DATA{6,2};
            n2 = strfind(DayRange,'-');
            DayLow = str2num(DayRange(1:n2-1));
            DayHigh = str2num(DayRange(n2+1:end));
            
            %52w range
            YearRange = DATA{7,2};
            n2 = strfind(YearRange,'-');
            YearLow = str2num(YearRange(1:n2-1));
            YearHigh = str2num(YearRange(n2+1:end)); 
            
            %Time
            Time = datenum(strrep(DATA{8,2},'as of ',''));
            TimeStr = {datestr(Time,13)};
            
            %Price
            Price = PrevClose*(1+PercentageChange/100);
            
            %PriceChange
            PriceChange = PrevClose*(PercentageChange/100);
            
            DATASET = dataset(Price,PriceChange,PercentageChange,Bid,Ask,Open,PrevClose,Volume,DayLow,DayHigh,YearLow,YearHigh,Time,TimeStr);            
        end
    end
end