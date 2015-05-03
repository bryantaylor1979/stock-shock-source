function [buy,sell,tradesignal,changemarker,pP,P]=tradeguides(C,O,L,H)
        %Gives Buy and Sell signals for maximum practical profit.
        %Ignores small trend changes or flat days and follow biggest local trends.Profitable spikes are included.
        %Tradeguide signal offers practical trading benchmark training set for Neural Networks and other learning algorithms or TA.
        %
        %There are no hold signals generated.
        %buy=index for buy days
        %sell=index for sell days
        %Tradesignal is the composite buy and sell signal vector with 1= buy and 0=sell
        %Changemarker is a zero vector of the length of the time serie with 1
        %marking a change in trend.
        %
        %INPUTS:
        %   C:- Stock Closing Price (Column-wise Data)
        %   O:- Stock Opening Price (Column-wise Data)
        %   L:- Stock Low Price (Column-wise Data)
        %   H:- Stock High Price (Column-wise Data)
        %
        %OPTIONAL
        %   'Report':-  logical. The report flag defaults to false.
        %   'NoiseThreshold':- This threshold is expressed as a percentage change.
        %   The default is set to 0.005. This means that any daily change of less than
        %   0.5% will be ignored, and persumed as noise.
        %
        %Example:
        %Get a small amount of data from the local database
        % numberofreadings = 365;
        % [startdate,enddate] = StockDateRange('AAA');
        % 
        % [DateNum] = GetData('AAA','datenum',[startdate,startdate+numberofreadings]);
        % [C] = GetData('AAA','close',[startdate,startdate+numberofreadings]);
        % [O] = GetData('AAA','open',[startdate,startdate+numberofreadings]);
        % [H] = GetData('AAA','high',[startdate,startdate+numberofreadings]);
        % [L] = GetData('AAA','low',[startdate,startdate+numberofreadings]);
        %
        %Get trade signals:
        % [buy,sell,tradesignal,changemarker]=tradeguide(C,O,H,L,'Report',true)
        %
        %Written by:    Bryan Taylor
        %Date Created:  17th Feb 2007
        %Date Modified: 17th Feb 2007
        %
        % Copyright 2007, CoLogic, Inc
        args.NoiseThreshold = 0.01;
        args.SoftSwitch = 0;
        args.Report = true;
        args.Plot = false;
       
        %take the mean of each price. 2 means rows. Hence for each day the average
        %is taken of the high, low, open and close price

        
        
        P = mean([O,C,H,L]')'
        l=length(P);
        if args.Report == true
            if l>5
            disp('Take the average of the open, close, high low price for each day');
            disp('This will remove some noise from the data');
            disp('day_average = (open + close + high + low)/4');
            day_average = P(1:5) 
            end
        end

        dP=[0;diff(P)];%2 day price difference

        if args.Report == true
            if l>5
            disp('Find the day to day difference of the stock price');
            disp('DiffPrice = Price(n) - Price(n-1)');
            disp('where n is a date vector');
            diffPrice = dP(1:5) 
            end
        end

        pP=dP./P;%percent change

        if args.Report == true
            if l>5
            disp('this does tell us about profit therefore we then take the percentage change.')
            disp('PercentageChange = PriceChange/Price')
            PercentageChange = pP(1:5)
            end
        end

        spP=sign(pP);%sign of day to day % change

        if args.Report == true
            if l>5
            disp('find the sign of each price diff')
            signP = spP(1:5)
            end
        end

        n=find(spP==0);%%find no change days
        %find returns all the location where the is no change between days
        spP(n)=sign(rand-.5);%%add small noise to no change days

        if args.Report == true
            if l>5
            FixedSignChange = spP(1:5);
            end
        end

        spP=(spP+1)/2;%%convert to binary 0=down 1=up
        %%%%filter out flat days with changes less than .5%
        %%small noises and spikes are non-profitable neglected
        for i=2:l-1
            if abs(pP(i))<args.NoiseThreshold
                spP(i)=spP(i-1);%same as prior day
            end
        end
        % two 0.25 changes would result in a signed result
        if args.Report == true
            if l>5
            disp('convert to binary 0=down 1=up, based on noise threshold')
            FixedSignChange = spP(1:5)
            end
        end

        %%%%%%%%Mark signal change%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%find buy  signal%%
        n=find(spP(2:end)==1);%shift back by one day 
        buy=n;
        %%%%%%%%find sell signal%%
        n=find(spP(2:end)==0);%shift back by one day 
        sell=n;
        %%%%%%%%tradesignal
        n = find(isnan(spP)==1);   
        x = size(spP,1);
        spP = spP(n);           
        changemarker = zeros(x-1,1);

        cm =xor(spP(1:end-1),spP(2:end));%finds changing signals
        changemarker(n) = cm;
        
        %%%%%%%%tradesignal
        tradesignal=zeros(l,1);
        tradesignal(buy)=1;
        changemarker = [NaN;changemarker];
end
function Example()
%%
data = fetch(yahoo,'ibm',{'Close','Open','Low','High'},today-30*2,today)
Close = data(:,2);
Open = data(:,3);
Low = data(:,4);
High = data(:,5);
[buy,sell,tradesignal,changemarker,pP,P]=tradeguides(Close,Open,Low,High);


end