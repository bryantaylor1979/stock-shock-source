classdef CalculateParameters_Mat
    properties
        Mode = 'Visual'; %Visual or Silent
        ColumnNames = {  'Symbol'; ...
                         'Status'; ...
                         'Date_Time'; ...
                         };
        Config = true; %Logical
    end
    methods (Hidden = false)
       function [Output] = Process(varargin)
            %Calculate Parameters
            %
            %Written by:    Bryan Taylor
            %Date Created:  21st July 2008
            %Date Modified: 21st July 2008

            global h
            h = get(h.figure,'UserData');
            path = h.path.savedata;

            String = get(h.DatabaseSelection.pulldown,'String');
            Value = get(h.DatabaseSelection.pulldown,'Value');
            DatabaseName = String{Value};

            path = [path,DatabaseName,'\Download_Mat\'];

            %% Get Symbol List
            if size(varargin,2) == 1
                cd(path);
                filenames = dir;
                filenames = struct2data(filenames,'name');
                filenames = strrep(filenames,'.mat','');
                [x] = size(filenames,1);
                symbols = filenames(3:x);
            else
                symbols = varargin{2};
            end

            %% Get Calculations
            x = size(symbols,1);
            start = 1;
            parfor i = start:x%x %loop over symbols
                percentage = num2str(round((1-i/x)*100));
                set(h.Status,'String',['Processing... ',num2str(x-i),' of ',num2str(x),' (',percentage,'%)']);
                drawnow;
                symbol = symbols{i};

                [Status] = obj.LoadAndCalculate(symbol,path);

                %Log information
                Date_Time = datestr(now);
                Data(i,:) = {symbol,Status,Date_Time};

                %Update GUI
                if strcmpi(obj.Mode,'Visual')
                    set(h.table,'Data',Data)
                end
            end
            if strcmpi(obj.Mode,'Silent')
                set(h.table,'Data',Data)
            end
            set(h.Status,'String','Ready');
            Output = 1;     
        end
    end
    methods (Hidden = true)
        function [Status] = LoadAndCalculate(symbol,path)
            try
            load([path,symbol,'.mat']); 
            Close = DataStore(:,2);
            Open = DataStore(:,3);
            Low = DataStore(:,4);
            High = DataStore(:,5);

            DataStore = DataStore(:,1:7);

            %Calculate Parameters
            PriceMean = mean([Close,Open,High,Low],2);
            DayDiff=[0;diff(PriceMean)];    
            [buy,sell,TradeSignal,changemarker,PercentageChange]=tradeguide(Close,Open,High,Low,'Report',false);

            %Store
            DataStore = [DataStore,PriceMean,PercentageChange,TradeSignal];

            save([path,symbol,'.mat'],'DataStore');
            Status = 'Passed';
            catch
            Status = 'Failed';
            end
        end
    end
end