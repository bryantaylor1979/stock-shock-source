function [buy,sell,tradesignal,changemarker,pP]=tradeguide(varargin)
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

[C,O,H,L,NoiseThreshold,report] = parseinputs(varargin);
l=length(C);

%take the mean of each price. 2 means rows. Hence for each day the average
%is taken of the high, low, open and close price
P=mean([C,O,H,L],2);

if report == true
    disp('Take the average of the open, close, high low price for each day');
    disp('This will remove some noise from the data');
    disp('day_average = (open + close + high + low)/4');
    day_average = P(1:5) 
end

dP=[0;diff(P)];%2 day price difference

if report == true
    disp('Find the day to day difference of the stock price');
    disp('DiffPrice = Price(n) - Price(n-1)');
    disp('where n is a date vector');
    diffPrice = dP(1:5) 
end

pP=dP./P;%percent change

if report == true
    disp('this does tell us about profit therefore we then take the percentage change.')
    disp('PercentageChange = PriceChange/Price')
    PercentageChange = pP(1:5)
end

spP=sign(pP);%sign of day to day % change

if report == true
    disp('find the sign of each price diff')
    signP = spP(1:5)
end

n=find(spP==0);%%find no change days
%find returns all the location where the is no change between days

spP(n)=sign(rand-.5);%%add small noise to no change days

if report == true
    FixedSignChange = spP(1:5)
end

spP=(spP+1)/2;%%convert to binary 0=down 1=up
%%%%filter out flat days with changes less than .5%
%%small noises and spikes are non-profitable neglected
for i=2:l-1
    if abs(pP(i))<NoiseThreshold
        spP(i)=spP(i-1);%same as prior day
    end
end
% two 0.25 changes would result in a signed result

if report == true
    FixedSignChange = spP(1:5)
end

%%%%%%%%Mark signal change%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%find buy  signal%%
n=find(spP(2:end)==1);%shift back by one day 
buy=n;
%%%%%%%%find sell signal%%
n=find(spP(2:end)==0);%shift back by one day 
sell=n;
%%%%%%%%tradesignal
try
changemarker=xor(spP(1:end-1),spP(2:end));%finds changing signals
catch
changemarker = 'failed';
end
%%%%%%%%tradesignal
tradesignal=zeros(length(C),1);
tradesignal(buy)=1;

function [C,O,H,L,NoiseThreshold,Report] = parseinputs(varargin) 
%
varargin = varargin{1};

%Defaults
NoiseThreshold = 0.005;
Report = false;

%Cumpulsory Inputs
try
    C = varargin{1};
    O = varargin{2};
    H = varargin{3};
    L = varargin{4};
catch
    error('compulusory inputs are invalid')  
end

%Optional Inputs
[x] = size(varargin,2);
for i = 5:2:x
    switch lower(varargin{i})
        case 'report'
           Report = varargin{i+1};
        case 'noisethreshold'
           NoiseThreshold = varargin{i+1};
        otherwise
           error('Optional Input not recognised')
    end
end

