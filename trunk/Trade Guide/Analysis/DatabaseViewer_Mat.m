classdef DatabaseViewer_Mat
    properties
        ColumnNames = { 'datenum'; ...
                        'close'; ...
                        'open'; ...
                        'low'; ...
                        'high'; ...
                        'volume'; ...
                        'closeadj'; ...
                        'PriceMean'; ...
                        'PercentageChange'; ...
                        'TradeSignal'; ...
                        };
         Config = false;
         DataPath = 'C:\SourceSafe\Stocks & Shares\Programs\Trade Guide\SaveData\Download_Mat\Database\';
         DataObj = [];
         TradeGuideHandle = [];
    end
    methods 
        function [obj] = DatabaseViewer_Mat(obj)
            obj.DataObj = LocalDatabase();
        end
        function [] = Process(varargin)
            %Calculate Parameters
            %
            %Written by:    Bryan Taylor
            %Date Created:  12th August 2008
            %Date Modified: 12th August 2008
            obj = varargin{1};

            Value = get(obj.TradeGuideHandle.handles.DatabaseViewer.pulldown,'Value');
            String = get(obj.TradeGuideHandle.handles.DatabaseViewer.pulldown,'String');
            symbol = String{Value};
            
            obj.DataObj.Symbol = symbol;
            obj.DataObj.LoadData;
                
            set(obj.TradeGuideHandle.handles.table,'ColumnName',obj.DataObj.DataStoreColumnNames );
            set(obj.TradeGuideHandle.handles.table,'Data',obj.DataObj.DataStore);
        end
    end
end
