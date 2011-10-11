function [P] = NoiseRemoval(varargin)
%This function removes daily noise. This function needs to be optimised but
%when set up correctly will remove daily noise.
%
%Optional Inputs:
%   Noise Threshold:-   If the daily variation is less than this value the
%   stock price will be assumed to be the same. This is expressed as a
%   factor. e.g 0.005 would be result in any change less than 0.5 % would
%   be ignore therefore would be overwritten by the previous value.
%
%   SoftSwitch:-    (Dampen Correction) This allows you to fade from completely corrected to
%   completely un-corrected. When set to one there is no correct, and when
%   it is set to 0, full correction will be observed.
%   This could be changed to the reverse sign. 
%
%   Report:-    Will output a report to help with debug. This can also
%   help to understand the function.
%
%   Plot:-  This will plot the orginal data and the noise reduced data on
%   the same graph.
%
%Defaults:  Noise Threshold    0.005
%           Softswitch         0; (Full correction)
%
%Example:
%IntialiseDatabase;
% [date,close,open,high,low,closeadj] ...
%     = StockQuote('AA',{'datenum';'close';'open';'high';'low';'closeadj'},[today-90,today]);
% P=mean([close,open,high,low],2);
% [price] = NoiseRemoval(P,'softswitch',0,'noisethreshold',0.01);
% [AX,H1,H2] = plotyy(date,P,date,price,'plot');
%
%Please ensure axis are the same scale.
% axes(AX(1))
% axis([date(1),date(x),min(P),max(P)]);
% axes(AX(2))
% axis([date(1),date(x),min(P),max(P)]);
%
% Copyright 2007, CoLogic, Inc

% TODO:   Subsitute noise threshold for an adpative moving noise figure.

[P,NoiseThreshold,SoftSwitch,report,Plot] = parseinputs(varargin);

l=length(P);

%take the mean of each price. 2 means rows. Hence for each day the average
%is taken of the high, low, open and close price
if report == true
   Orginal_Data = P(1:5)
end
dP=[0;diff(P)];%2 day price difference
if report == true
   Difference_Data = dP(1:5) 
end
pP=dP./P;%percent change
if report == true
   Percentage_Change = pP(1:5)
end

%%%%filter out flat days with changes less than .5%
%%small noises and spikes are non-profitable neglected
oldP = P;
for i=2:l
    if abs(pP(i))<NoiseThreshold
        pricediff(i) = P(i)-P(i-1);
        P(i)= P(i-1)+pricediff(i)*SoftSwitch;
    else
        P(i)=P(i);%no correction
    end
end
if report == true
    temp = [oldP,P];
    summary = temp(1:5,:)
end

if Plot == true
    %generate date data
    [x] = size(P,1);
    date = [1:x];
    [AX,H1,H2] = plotyy(date,oldP,date,P,'plot');

    % Please ensure axis are the same scale.
    axes(AX(1))
    axis([date(1),date(x),min(oldP),max(oldP)]);
        datetick
    axes(AX(2))
    axis([date(1),date(x),min(oldP),max(oldP)]);
        datetick
end

function [P,NoiseThreshold,SoftSwitch,Report,Plot] = parseinputs(varargin) 
%
varargin = varargin{1};

%Defaults
NoiseThreshold = 0.005;
Report = false;
SoftSwitch = 0;
Plot = false;

%Cumpulsory Inputs
try
    P = varargin{1};
catch
    error('compulusory inputs are invalid')  
end

%Optional Inputs
[x] = size(varargin,2);
for i = 2:2:x
    switch lower(varargin{i})
        case 'report'
           Report = varargin{i+1};
        case 'noisethreshold'
           NoiseThreshold = varargin{i+1};
        case 'softswitch'
           SoftSwitch = varargin{i+1};
        case 'plot'
           Plot = varargin{i+1};
        otherwise
           error('Optional Input not recognised')
    end
end