classdef yahoostockviewer < handle
   properties (SetObservable = true)
      Range = '3m'; %1w, 2w, 1m, 3m, 6m, 1y, All
      Symbol = 'BARC.L';
   end
   properties (SetObservable = true, Hidden = true)
       Range_LUT = {'1w'; ...
                    '2w'; ...
                    '1m'; ... 
                    '3m'; ...
                    '6m'; ...
                    '1y'; ...
                    'All'}
       handles
   end
   methods
       function Example(obj)
           %%
           close all
           clear classes
           obj = YahooStockViewer();
           ObjectInspector(obj);
       end
       function RUN(obj)
           [Days, Freq] = obj.Range2DaysFreq(obj.Range);
           obj.UpdatePlot(obj.Symbol,Freq,Days)
       end
   end
   methods (Hidden = true) %plots
       function obj = YahooStockViewer(varargin)
          %% Manage input varaiables
          % variable arg in
          [x] = size(varargin,2);
          for i = 1:2:x
           	obj.(varargin{i}) = varargin{i+1};
          end
          [Days, Freq] = obj.Range2DaysFreq(obj.Range)
          obj.handles = obj.Plot(obj.Symbol,Freq,Days)
       end
       function [DaysPast, Freq] = Range2DaysFreq(obj,Range)
           switch lower(obj.Range)
              case '1w'
                  DaysPast = 7;
                  Freq = 'd';
              case '2w'
                  DaysPast = 14;
                  Freq = 'd';
              case '1m'
                  DaysPast = 30;
                  Freq = 'd';
              case '3m'
                  DaysPast = 90;
                  Freq = 'd';
              case '6m'
                  DaysPast = 6*30;
                  Freq = 'w';
              case '1y'
                  DaysPast = 12*30;
                  Freq = 'w';
              case 'all'
                  DaysPast = 100000000000000000;
                  Freq = 'm';
          end          
       end
       function UpdatePlot(obj,Symbol,Freq,DaysPast)
           %%
           obj.handles.GroupParamaterHold = true;
          [     obj.handles.Date, ...
                obj.handles.High, ...
                obj.handles.Low, ...
                obj.handles.Open, ...
                obj.handles.Close, ...
                obj.handles.Volume, ...
                obj.handles.ResistanceOne, ...
                obj.handles.ResistanceTwo, ...
                obj.handles.SupportOne, ...
                SupportTwo] = obj.GetLiveQuote(Symbol,Freq,DaysPast);
           obj.handles.GroupParamaterHold = false;
           obj.handles.SupportTwo = SupportTwo; 
       end
       function handle = Plot(obj,Symbol,Freq,DaysPast)
          %%
          [Date,High,Low,Open,Close,Volume,ResistanceOne,ResistanceTwo,SupportOne,SupportTwo] = obj.GetLiveQuote(Symbol,Freq,DaysPast);
          handle = candle_volume_plot(Date, High, Low, Open, Close, Volume, ...
                        'title', obj.Symbol, ...
                        'ResistanceOne',ResistanceOne, ...
                        'ResistanceTwo',ResistanceTwo, ...
                        'SupportOne',SupportOne, ...
                        'SupportTwo',SupportTwo);
       end
       function [Date,High,Low,Open,Close,Volume,ResistanceOne,ResistanceTwo,SupportOne,SupportTwo] = GetLiveQuote(obj,Symbol,Freq,DaysPast)
           ARRAY = fetch(yahoo,Symbol,{'high','low','open','close','volume'},today-DaysPast,today+1,Freq);
           Date = ARRAY(:,1);
           High = ARRAY(:,2);
           Low = ARRAY(:,3);
           Open = ARRAY(:,4);
           Close = ARRAY(:,5);
           Volume = ARRAY(:,6);  
           struct = getStox(Symbol);  
           ResistanceOne = struct.Resistances.Resistance1;
           ResistanceTwo = struct.Resistances.Resistance2;
           SupportOne = struct.Supports.Support1;
           SupportTwo = struct.Supports.Support2; 
       end       
   end
end