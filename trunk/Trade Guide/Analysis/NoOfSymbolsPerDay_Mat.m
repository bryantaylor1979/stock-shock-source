classdef NumberOfSymbolsPerDay_Mat
    properties
        ColumnNames = { 'Date'; ...
                        'DateNum'; ...
                        'NoOfSymbols'; ...
                        };
        Config = false;
        UpdateMode = 'Silent'; %or Visual
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
            MinimumThreshold = 100;
            global savecriteria
            Names = {   'Date'; ...
                        'DateNum'; ...
                        'NoOfSymbols'; ...
                    };
            IntialiseTable(Names);

            set(h.table,'Data',{});

            display = false;

            %% Get Date Range
            uiwait(msgbox('This function assumes DataRange_Mat is uptodate'));
            [OutPutArray] = GetStageData('DateRange_Mat');

            StartDate = OutPutArray(:,3);
            n = find(not(strcmpi(StartDate,'N/A')));
            LargeOutPutArray  = OutPutArray(n,:);

            StartDate = datenum(LargeOutPutArray(:,3));
            EndDate = datenum(LargeOutPutArray(:,4));
            enddate = max(EndDate);
            startdate = min(StartDate);

            count2 = 1;
            for j = startdate:enddate
                waitfor(h.toolbars.Stop,'State','off');
                set(h.Status,'String',[num2str((j-startdate)/(enddate-startdate)*100,3),'% Complete']);
                drawnow;

                [OutPutArray] = DaySymbolSetMat(j,LargeOutPutArray);
                count = size(OutPutArray,1);

                Symbols(count2).date = datestr(j);
                Symbols(count2).datenum = j;
                Symbols(count2).NumberOfSymbols = count;

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
                count2 = count2 + 1;
            end

            if strcmpi( UpdateMode , 'Visual')
            else
                set(h.table,'Data',RowInfo);
            end
            set(h.Status,'String',['Ready']);
            Output = 1;
        end
        function [output] = Report(varargin);
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
            Data = GetStageData('NoOfSymbolsPerDay_Mat','NoOfSymbols');
            Data = str2double(Data);
            Date = datenum(GetStageData('NoOfSymbolsPerDay_Mat','Date'));

            % Find approved date range
            n = find(Data>MinimumThreshold);
            LargerThanOneHundred = Date(n);
            LargerThanOnHundredData = Data(n);

            startdateout = min(LargerThanOneHundred);
            enddateout = max(LargerThanOneHundred);

            string = { ['Recommended Analysis Window:'];...
                       ['Minimum Threshold: ',num2str(MinimumThreshold)];...
                       ['Start Date: ',datestr(startdateout)];...
                       ['End Date: ',datestr(enddateout)]};
            % grid off
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
            text(Date(1),max(Data)*0.8,string);
            h.axes = gca;
            YLim = get(h.axes,'YLim');
            YLim(1) = 0;
            set(h.axes,'YLim',YLim);

            output.StartDate = startdateout;
            output.EndDate   = enddateout;
            output.MinThreshold = MinimumThreshold;
        end
    end
end