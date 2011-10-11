classdef NumberOfSymbolsPerDay
    properties
        ColumnNames = { 'Date'; ...
                        'DateNum'; ...
                        'NoOfSymbols'; ...
                        };
        Config = false;
        Mode = 'Mat'; %or 
        UpdateMode = 'Silent'; %or Visual
        MinimumThreshold = 100;
    end
    methods
        function [Output] = Process(varargin)
            %Calculate the number of symbols on each day.
            %
            %InputArray - Output from symbol information.
            %Database must be intialised.
            %
            %Example: 
            %IntialiseDatabase;
            %[OutPutArray] = SymbolInformation();
            %[startdateout,enddateout]=NumberOfSymbolsPerDay(MinimumThreshold,InputArray)
            %
            %Written by: Bryan Taylor
            %Date Created: 3rd January 2008
            %Date Modified: 3rd January 2008

            global h

            %% Functional
            global savecriteria

            set(h.table,'Data',{});

            if strcmpi(Mode,'Mat')
                [OutPutArray] = GetStageData('DateRange');
            else
                [OutPutArray] = GetStageData('DateRange_Mat');
            end

            display = false;
            [x] = size(OutPutArray,1);
            count = 1;
            for i = 1:x
                try
                    StartDate(count) = datenum(OutPutArray(i,3));
                    EndDate(count) = datenum(OutPutArray(i,4));
                    count = count + 1;
                end
            end
            enddate = max(EndDate);
            startdate = min(StartDate);

            % StatusBar(h.statusbar,0);
            count2 = 1;
            for j = startdate:enddate
            %     StatusBar(h.statusbar,(j-startdate)/(enddate-startdate));
                waitfor(h.toolbars.Stop,'State','off');
                set(h.Status,'String',[num2str((j-startdate)/(enddate-startdate)*100,3),'% Complete']);

                n = find(j>=StartDate);
                NewStartDate = StartDate(n);
                NewEndDate = EndDate(n);

                n = find(j<=NewEndDate);
                count = size(n,2);

                Symbols(count2).date = datestr(j);
                Symbols(count2).datenum = j;
                Symbols(count2).NumberOfSymbols = count;
                count2 = count2 + 1;
            %     DispStruct(Symbols(j),'all');

                if strcmpi( UpdateMode , 'Visual')
                    RowInfo{1,1} = datestr(j);
                    RowInfo{1,2} = num2str(j);
                    RowInfo{1,3} = num2str(count);
                    AddRow(RowInfo);
                else
                    RowInfo{count2,1} = datestr(j);
                    RowInfo{count2,2} = num2str(j);
                    RowInfo{count2,3} = num2str(count);
                end
            end

            if strcmpi( UpdateMode , 'Visual')
            else
                set(h.table,'Data',RowInfo);
            end
            set(h.Status,'String',['100% Complete']);
            Output = 1;
        end
        function [output] = Report(tablehandle);
                %MinimumThreshold (Default: 100, Class: Double/Int)
                %This is the minimum number of ticker symbols available on the day of investments. 
                %This is usefull to remove the older stats which only have 2-3 stocks avaiable for
                %investment. 
                %
                %Example 1: No Inputs
                %NoOfSymbolsPlot();
                %
                %Example 2: Report information in matlab comman space.
                %NoOfSymbolsPlot(true);
                %
                %Written by:    Bryan Taylor
                %Date Created:  6th January 2008
                %Date Modified: 6th January 2008

                global settings
                if settings.descion.MinThresholdEnable == true
                    MinimumThreshold = settings.descion.MinThreshold;
                else 
                    MinimumThreshold = 0;
                end
                MinimumThreshold = 100;

                % plot 
                Data = GetStageData('NoOfSymbolsPerDay','NoOfSymbols');
                Data = str2double(Data);
                Date = datenum(GetStageData('NoOfSymbolsPerDay','Date'));

                % Find approved date range
                n = find(Data>MinimumThreshold);
                LargerThanOneHundred = Date(n);
                LargerThanOnHundredData = Data(n);
                [x] = size(LargerThanOneHundred,1);

                string = { ['Recommended Analysis Window:'];...
                           ['Minimum Threshold: ',num2str(MinimumThreshold)];...
                           ['Start Date: ',datestr(LargerThanOneHundred(x))];...
                           ['End Date: ',datestr(LargerThanOneHundred(1))]};
                % grid off

                startdateout = LargerThanOneHundred(x);
                enddateout = LargerThanOneHundred(1);
                settings.startdate = startdateout;
                settings.enddate = enddateout;

                %% Plot Data
                h.figure = figure;
                h.arealine = area(LargerThanOneHundred,LargerThanOnHundredData);
                hold on
                h.line = plot(Date,Data,'r-');
                datetick;
                hold on
                h.areadottenlinemin = plot([LargerThanOneHundred(1),LargerThanOneHundred(1)],[0,LargerThanOnHundredData(1)],'k:');
                hold on
                [x] = size(LargerThanOnHundredData,1);
                h.areadottenlinemax = plot([LargerThanOneHundred(x),LargerThanOneHundred(x)],[0,LargerThanOnHundredData(x)],'k:');
                xlabel('Date');
                ylabel('Number Of Symbols');
                title('Number Of Symbols Vs Date')
                set(h.figure,'Name','Number Of Symbols');
                set(h.figure,'NumberTitle','off');
                set(h.arealine,'FaceColor',[0.9,0.9,0.9])
                set(h.arealine,'EdgeColor',[0,0,0]);
                set(h.arealine,'LineStyle','none');
                text(Date(1),100,string);
                h.axes = gca;
                YLim = get(h.axes,'YLim');
                YLim(1) = 0;
                set(h.axes,'YLim',YLim);

                output.StartDate = startdateout;
                output.EndDate   = enddateout;
                output.MinThreshold = MinimumThreshold;
        end
        function [startdateout,enddateout] = NumberOfSymbolsPerDay(h,MinimumThreshold,OutPutArray)
            %Calculate the number of symbols on each day.
            %
            %InputArray - Output from symbol information.
            %Database must be intialised.
            %
            %Example: 
            %IntialiseDatabase;
            %[OutPutArray] = SymbolInformation();
            %[startdateout,enddateout]=NumberOfSymbolsPerDay(MinimumThreshold,InputArray)
            %
            %Written by: Bryan Taylor
            %Date Created: 3rd January 2008
            %Date Modified: 3rd January 2008
            global h savecriteria

            display = false;
            [x] = size(OutPutArray,1);
            count = 1;
            for i = 1:x
                try
                    StartDate(count) = datenum(OutPutArray(i,3));
                    EndDate(count) = datenum(OutPutArray(i,4));
                    count = count + 1;
                end
            end
            enddate = max(EndDate);
            startdate = min(StartDate);

            % StatusBar(h.statusbar,0);
            count2 = 1;
            for j = startdate:enddate
            %     StatusBar(h.statusbar,(j-startdate)/(enddate-startdate));
                waitfor(h.toolbars.Stop,'State','off');
                set(h.Status,'String',[num2str((j-startdate)/(enddate-startdate)*100,2),'% Complete'])

                n = find(j>=StartDate);
                NewStartDate = StartDate(n);
                NewEndDate = EndDate(n);

                n = find(j<=NewEndDate);
                count = size(n,2);


                Symbols(count2).date = datestr(j);
                Symbols(count2).datenum = j;
                Symbols(count2).NumberOfSymbols = count;
                count2 = count2 + 1;
            %     DispStruct(Symbols(j),'all');

                RowInfo{1,1} = datestr(j);
                RowInfo{1,2} = num2str(j);
                RowInfo{1,3} = num2str(count);
                AddRow(RowInfo);
            end

            savecriteria.NoOfSymbolsPerDay = Symbols;
            savecriteria.NoOfSymbolsPerDayjavaobject = get(h.table,'Data');

            if display == true
               % plot data
               Data = cell2mat(Struct2Data(Symbols,'NumberOfSymbols'));
               Date = cell2mat(Struct2Data(Symbols,'datenum'));
               h.figure = figure;
               h.line = plot(Date,Data,'r-');
               datetick;
               xlabel('Date');
               ylabel('Number Of Symbols');
               title('Number Of Symbols Vs Date')
               set(h.figure,'Name','Number Of Symbols');
               set(h.figure,'NumberTitle','off');

               % Find approved date range
               n = find(Data>100);
               LargerThanOneHundred = Date(n);
               [x] = size(LargerThanOneHundred,1);
               string = {['Recommended Analysis Window:'];...
                         ['Minimum Threshold: ',num2str(MinimumThreshold)];...
                         ['Start Date: ',datestr(LargerThanOneHundred(1))];...
                         ['End Date: ',datestr(LargerThanOneHundred(x))]};
               text(Date(1),100,string);
               grid off
            end
            startdateout = LargerThanOneHundred(1);
            enddateout = LargerThanOneHundred(x);

            set(h.Status,'String',[num2str((j-startdate)/(enddate-startdate)),'% Complete']);
        end
        function [startdateout,enddateout] = NoOfSymbolsPlot(varargin);
            %MinimumThreshold (Default: 100, Class: Double/Int)
            %This is the minimum number of ticker symbols available on the day of investments. 
            %This is usefull to remove the older stats which only have 2-3 stocks avaiable for
            %investment. 
            %
            %Written by: Bryan Taylor
            %Date Created: 6th January 2008
            %Date Modified: 6th January 2008

            report = true;
            if isempty(varargin)  
            else
                report = varargin{1};
            end

            global savecriteria settings
            if settings.descion.MinThresholdEnable == true
                MinimumThreshold = settings.descion.MinThreshold;
            else 
                MinimumThreshold = 0;
            end
            Symbols = savecriteria.NoOfSymbolsPerDay;

            % plot data
            Data = cell2mat(Struct2Data(Symbols,'NumberOfSymbols'));
            Date = cell2mat(Struct2Data(Symbols,'datenum'));

            % Find approved date range
            n = find(Data>MinimumThreshold);
            LargerThanOneHundred = Date(n);
            LargerThanOnHundredData = Data(n);
            [x] = size(LargerThanOneHundred,1);

            string = {['Recommended Analysis Window:'];...
                     ['Minimum Threshold: ',num2str(MinimumThreshold)];...
                     ['Start Date: ',datestr(LargerThanOneHundred(1))];...
                     ['End Date: ',datestr(LargerThanOneHundred(x))]};
            grid off

            startdateout = LargerThanOneHundred(1);
            enddateout = LargerThanOneHundred(x);

            if report == true
            h.figure = figure;
            h.arealine = area(LargerThanOneHundred,LargerThanOnHundredData);
            hold on
            h.line = plot(Date,Data,'r-');
            datetick;
            hold on
            h.areadottenlinemin = plot([LargerThanOneHundred(1),LargerThanOneHundred(1)],[0,LargerThanOnHundredData(1)],'k:')
            hold on
            [x] = size(LargerThanOnHundredData,1);
            h.areadottenlinemax = plot([LargerThanOneHundred(x),LargerThanOneHundred(x)],[0,LargerThanOnHundredData(x)],'k:')
            xlabel('Date');
            ylabel('Number Of Symbols');
            title('Number Of Symbols Vs Date')
            set(h.figure,'Name','Number Of Symbols');
            set(h.figure,'NumberTitle','off');
            set(h.arealine,'FaceColor',[0.9,0.9,0.9])
            set(h.arealine,'EdgeColor',[0,0,0]);
            set(h.arealine,'LineStyle','none');
            text(Date(1),100,string);
            h.axes = gca;
            YLim = get(h.axes,'YLim');
            YLim(1) = 0;
            set(h.axes,'YLim',YLim);
            end
        end
    end
end