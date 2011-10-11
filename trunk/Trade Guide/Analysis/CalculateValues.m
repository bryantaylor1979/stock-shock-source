classdef CalculateValues
    properties
        ColumnNames = { 'Symbol'; ...
                        'Status'; ...
                        'Date/Time'; ...
                        };
       Config = false;
       Mode = 'Silent';
       SymbolSourceMode = 'indatabase';
       Location = 'C:\HmSourceSafe\Stocks & Shares\Programs\Trade Guide\SaveData\';
       TradeGuideHandle = [];
    end
    methods
        function [Output] = Process(obj)
            %
            %Written by: Bryan Taylor
            %Date Created: 12th Feb 2008
            %Date Modified: 12th Feb 2008
            DataObj = LocalDatabase;
            DataObj.Location = obj.Location;
            [DataObj,tablelist] = DataObj.GetDownloadedSymbolList();

            [x] = size(tablelist,1);
            start = 1;
            for j = start:x
                  %Update GUI
%                   try
                      obj.TradeGuideHandle.UpdateStatus(j/x);
                      set(obj.TradeGuideHandle.handles.StatusInfo,'String',['Processing... ',num2str(j),' of ',num2str(x),' (',num2str(round(j/x*100)),'%)']);
                      drawnow;

                      DataObj.Symbol = tablelist{j};
                      DataObj = DataObj.LoadData;
                      DataObj = DataObj.CalcChange;
                      DataObj = DataObj.CalcPriceMean;
                      DataObj = DataObj.CalcMovAvg(2);
                      DataObj = DataObj.CalcMovAvg(3);
                      DataObj = DataObj.CalcMovAvg(4);
                      DataObj = DataObj.CalcMovAvg(5);
                      DataObj = DataObj.CalcMovAvg(6);
                      DataObj = DataObj.CalcMovAvg(7);
                      DataObj = DataObj.CalcMovAvg(8);
                      DataObj = DataObj.CalcMovAvg(9);
                      DataObj = DataObj.CalcMovAvg(10);
                      DataObj = DataObj.CalcMovAvg(11);
                      DataObj = DataObj.CalcMovAvg(12);
                      DataObj = DataObj.CalcMovAvg(13);
                      DataObj = DataObj.CalcMovAvg(14);
                      DataObj = DataObj.CalcMovAvg(15);
                      DataObj = DataObj.CalcMovAvg(16);
                      DataObj = DataObj.CalcMovAvg(17);
                      DataObj = DataObj.CalcMovAvg(18);
                      DataObj = DataObj.CalcMovAvg(19);
                      DataObj = DataObj.CalcMovAvg(20);
                      DataObj = DataObj.CalcMovAvg(21);
                      DataObj = DataObj.CalcMovAvg(22);
                      DataObj = DataObj.CalcMovAvg(23);
                      DataObj = DataObj.CalcMovAvg(24);
                      DataObj = DataObj.CalcMovAvg(25);
                      DataObj = DataObj.CalcMovAvg(26);
                      DataObj = DataObj.CalcMovAvg(27);
                      DataObj = DataObj.CalcMovAvg(28);
                      DataObj = DataObj.CalcMovAvg(29);
                      DataObj = DataObj.CalcMovAvg(30);
                      DataObj = DataObj.CalcFiveDayHigh;
                      DataObj = DataObj.CalcDayDiff;
                      DataObj = DataObj.PercentageChange;
                      DataObj = DataObj.VolumeDiff;
                      DataObj = DataObj.PriceMean_DeNoise;
                      DataObj = DataObj.TradeSignal;
                      DataObj.SaveData;
                      Status = 'Updated';
%                   catch
%                       Status = 'Not Updated';
%                   end
                  
                  %Log Information
                  Date_Time = datestr(now);
                  if j == 1
                    Data = {tablelist{j},Status,Date_Time};
                  else
                    Data = [Data;{tablelist{j},Status,Date_Time}];   
                  end
                  
                  %Update GUI
                  if strcmpi(obj.Mode,'Visual')
                    set(obj.TradeGuideHandle.handles.table,'Data',Data)
                  end
            end
            if strcmpi(obj.Mode,'Silent')
                set(obj.TradeGuideHandle.handles.table,'Data',Data)
            end
            set(obj.TradeGuideHandle.handles.StatusInfo,'String',['Ready']);
        end
    end
end

