classdef PERatioAnalysis <  handle 
    properties
    end
    methods
        function DataSet = EPS_All(obj,Symbols,date)
            %%
            x = size(Symbols,1);
            h = waitbar(0);
            first = true;
            for i = 1:x
                waitbar(i/x,h)
                [N_DataSet,Status1] = obj.EPS_Single(Symbols{i},date);
                Status{i,1} = Status1;
                if strcmpi(Status1,'Pass')
                    if first == true
                        DataSet = N_DataSet;
                        first = false;
                    else
                        DataSet = [DataSet;N_DataSet];
                    end
                end
            end
            DATASET = dataset(Symbols,Status);
            close(h)
        end
        function [DATASET] = SuccessRate(obj)
            %% Successfull symbols
            PWD = pwd;
            figsavepath = [obj.InstallDir,'Results\EPS\fig\'];
            cd(figsavepath);
            names = rot90(struct2cell(dir),3);
            names = names(2:end,end);
            
            %
            x = size(names,1);
            count = 1;
            for i = 1:x
                if not(isempty(findstr(names{i},'.fig')))
                    Symbols(count,1) = strrep(names(i),'.fig','');
                    count = count + 1;
                end
            end
            cd(PWD);
            
            %%
            CompleteSymbols = obj.GetSymbols;
            
            %%
            x = size(CompleteSymbols,1)
            for i = 1:x
                n = find(strcmpi(CompleteSymbols{i},Symbols));
                if isempty(n)
                    Status{i,1} = 'Fail';
                else
                    Status{i,1} = 'Pass';
                end
            end
            
            %%
            n = find(strcmpi(Status,'Pass'));
            total = size(Status,1);
            passed = size(n,1);
            passrate = passed/total*100;
            
            
            %% Failed Symbols
            n = find(strcmpi(Status,'Fail'));
            FailedSymbols = CompleteSymbols(n);
            
            DATASET = dataset({CompleteSymbols,'Symbols'},Status);
            
            disp(['Pass Rate: ',num2str(passrate),'%'])
            
            %%
            h = waitbar(0);
            count = 0;
            count1 = 0;
            count2 = 0;
            x = size(FailedSymbols,1);
            for i = 1:x
                waitbar(i/x,h)
                try
                    DataSet = obj.GetEPSDataSet(FailedSymbols{i});
                catch
                    Status{i} = 'Symbol load Error'; %CON Reserved dos device.
                end
                if ischar(DataSet)
                    if strcmpi(DataSet,'No Data')
                        Status{i} = 'Symbol found but no EPS data';
                        count1 = count1 + 1;
                    else
                        Status{i} = 'No Symbol found';
                        count = count + 1;
                    end
                else
                    try
                        figsavepath = [obj.InstallDir,'Results\EPS\fig\'];
                        open([figsavepath,FailedSymbols{i},'.fig']);
                        close(gcf)
                        Status{i} = 'Error Unknown';
                    catch
                        count2 = count2 + 1;
                        Status{i} = 'Yahoo shareprice not found';
                    end
                    
                end
            end
            NoSymbolfound_passrate = count/x*100;
            disp(['NoSymbolfound Fail Rate: ',num2str(NoSymbolfound_passrate),'%'])
            
            Symbolfound_NoEPS_passrate = count1/x*100;
            disp(['Symbolfound_NoEPS Fail Rate: ',num2str(Symbolfound_NoEPS_passrate),'%'])

            Symbolfound_NoSP_passrate = count2/x*100;
            disp(['Symbolfound_NoSP Fail Rate: ',num2str(Symbolfound_NoSP_passrate),'%'])
            
            n = find(strcmpi(Status,'No Symbol found'))
            FailedSymbols(n)
        end
        function [DataSet,Status] = EPS_Single(obj,Symbol,date)
            %%
            PE_Method = 'Interpolated'; %Last or Interpolated.
            EPS_Fig_Visible = 'off';

            % Get Data
            try
                EpsDataSet = obj.GetEPS(Symbol,date); %Get EPS
                save([obj.InstallDir,'Results\EPS\mat\',Symbol,'.mat'])
                
                Date = obj.GetColumn(EpsDataSet,'YearEnd');
                SharePriceDataSet = obj.PriceQuote(Symbol,min(Date));
                
                if not(isempty(SharePriceDataSet))
                    CombinedDataSet = obj.PE_Calc(SharePriceDataSet,EpsDataSet,PE_Method);
                    h = obj.Plot(CombinedDataSet,EPS_Fig_Visible); 

                    figsavepath = [obj.InstallDir,'Results\EPS\fig\'];
                    saveas(h.figure, [figsavepath,Symbol], 'fig');
                    save([obj.InstallDir,'Results\EPS\mat\',Symbol,'.mat']);

                    close(h.figure);
                    Status = 'Pass';
                    
                    PE_Min_1YR = h.OneYr_PE_Range(1);
                    PE_Max_1YR = h.OneYr_PE_Range(2);

                    PE_Min_1YR_M90L10 = h.OneYr_PE_Range9010(1);
                    PE_Max_1YR_M90L10 = h.OneYr_PE_Range9010(2);

                    PE_RT = h.CurrentPE;
                    Potential = PE_Max_1YR_M90L10/PE_RT;
                    
                    
                    Distance = PE_Max_1YR - PE_Min_1YR;
                    Pos = PE_RT - PE_Min_1YR;
                    Percentage = (1 - Pos/Distance) * 100;
                    PE_Star = round(Percentage/20);
                    Symbol = {Symbol};
                    
                    DataSet = dataset(Symbol,PE_Min_1YR,PE_Max_1YR,PE_Min_1YR_M90L10,PE_Max_1YR_M90L10,PE_RT,PE_Star,Potential);
                else
                    Status = 'Fail';
                    DataSet = [];
                end
            catch
                Status = 'Fail';
                DataSet = [];
            end
        end
        function DownloadAllEPS(obj,Symbols)
            x = size(Symbols,1);
            h = waitbar(0);
            for i = 1:x
                waitbar(i/x,h)
                try
                s = obj.SaveURL_Fundamentals(Symbols{i});
                end
            end
            close(h)            
        end
        function DATASET = GetEPS(obj,Symbol,date)
            %%
            s = obj.LoadURL_Fundamentals(Symbol,date);

            n = findstr(s,'anything');
            
            
            if not(isempty(n))
                DATASET = 'No Symbol found';
            else
                try
                    DATASET = [];
                    [N_DATASET2] = obj.URL_GetForecasts(s,Symbol);
                    [DATASET2] = obj.URL_GetFundamentals(s,Symbol);

                    %Combined
                    try
                        DATASET = [N_DATASET2;DATASET2];
                    catch
                        DATASET = [DATASET2];    
                    end
                catch
                    n1 = findstr(s,'Stock EX');
                    if not(isempty(n1))
                        DATASET = 'No Symbol found with match'; 
                    else
                        DATASET = [];
                    end
                end

            end
        end
        function DATASET = PriceQuote(obj,Symbol,StartDate)
            %%
            Mode = 'yahoo';
          
            %%
            time = 1;
            timeout = 5;
            while time < timeout
                try
                    if strcmpi(Mode,'yahoo')
                        c = yahoo;
                        
                        DATA = flipud(fetch(c,[Symbol,'.L'],StartDate,today));
                        
                        %%
                        date = DATA(:,1);
                        close = DATA(:,2);
                        open = DATA(:,3);
                        low = DATA(:,4);
                        high  = DATA(:,5);
                        volume = DATA(:,6);
                        closeadj  = DATA(:,7);
                    else
                        [date, close, open, low, high, volume, closeadj] = ...
                                sqq([Symbol,'.L'],today,StartDate,'d');
                    end
                    break
                catch
                    pause(time)
                    time = time*2; 
                end
            end
            if  time >= timeout
                DATASET = [];
                return
            end
            DATASET = dataset(date, close, open, low, high, volume, closeadj);
        end
        function h = PlotDataSet(obj,DataSet,XLabel,YLabel,plotcolour)
            Y = obj.GetColumn(DataSet,YLabel);
            X = obj.GetColumn(DataSet,XLabel);
            plot(X,Y,plotcolour);
            hold on 
            warning off
            xlabel(XLabel)
            ylabel(YLabel)
            warning on
        end
        function SetDateRange(obj,DataSet1,DataSet2)
            Date = obj.GetColumn(DataSet1,'YearEnd');
            date = obj.GetColumn(DataSet2,'date');
            Start = max([min(date),min(Date)]);
            End = today;
            xlim([Start,End])
        end
        function DataSet = PE_Calc(obj,SharePriceDataSet,EpsDataSet,PE_Method)
            open = obj.GetColumn(SharePriceDataSet,'open');
            date = obj.GetColumn(SharePriceDataSet,'date');
            
            Date = obj.GetColumn(EpsDataSet,'YearEnd');
            EPS = obj.GetColumn(EpsDataSet,'EPS');
            
            Date = obj.GetColumn(EpsDataSet,'YearEnd');
            Start = min(Date);
            Start2 = min(date);
            disp(['EPS Start date: ',datestr(Start)])
            disp(['SP Start date: ',datestr(Start2)])
            Start = max([Start,Start2]);
            
            if strcmpi(PE_Method,'Last')
                count = 1;
                for i = Start:today
                    %Get Share price
                    n = find(i == date);
                    if not(isempty(n))
                        DATE(count) = date(n);
                        Price = open(n);

                        % Last EPS Date
                        n = (Date < i);
                        LastDate = max(Date(n));

                        % Last EPS
                        n = find(LastDate == Date);
                        EPS_(count,1) = EPS(n);

                        %PE
                        PE(count,1) = Price/EPS_(count);
                        count = count + 1;
                    end
                end
            else
                count = 1;
                for i = Start:today
                    %Get Share price
                    n = find(i == date);
                    if not(isempty(n))
                        DATE(count) = date(n);
                        Price = open(n);

                        % Last EPS Date
                        n = (Date <= i);
                        LastDate = max(Date(n));

                        % Last EPS
                        n = find(LastDate == Date);
                        LastEPS = EPS(n);

                        % Next EPS Date
                        n = find(Date >= i);
                        if isempty(n == 1) %If no forecasts use last EPS
                            NextDate = Date(1);
                        else
                            NextDate = min(Date(n));
                        end
                        
                        % Next EPS
                        n = find(NextDate == Date);
                        if isempty(n) %If no forecasts use last EPS
                            NextEPS = EPS(1);
                        else
                            NextEPS = EPS(n);
                        end
                       

                        % Interpolated EPS
                        warning off
                        coeff = polyfit([LastDate,NextDate],[LastEPS,NextEPS],2);
                        warning on
                        
                        EPS_(count,1) = polyval(coeff,i);          

                        %PE
                        PE(count,1) = Price/EPS_(count);
                        count = count + 1;
                    end
                end    
            end
            DataSet = [SharePriceDataSet,dataset(EPS_,PE)];
        end
        function PE_Range = OneYearPeRange(obj,DataSet)
            %
            DATE = obj.GetColumn(DataSet,'date');
            PE = obj.GetColumn(DataSet,'PE');
            
            n = find(DATE > today - 365);
            OneYearPE = PE(n);
            PE_Range = [min(OneYearPE),max(OneYearPE)];
        end
        function PE_Range = OneYearPeRange2(obj,DataSet,Max,Min) 
            %%
            DATE = obj.GetColumn(DataSet,'date');
            PE = obj.GetColumn(DataSet,'PE');
            
            n = find(DATE > today - 365);
            OneYearPE = PE(n);
            
            n = find(isnan(OneYearPE) == 0);
            OneYearPE = OneYearPE(n);
            
            OneYearPE = sort(OneYearPE);
            x = size(OneYearPE,1);

            MinPos = floor(Max/100*x);
            if MinPos == 0
                MinPos = 1;
            end
            Position = [MinPos,ceil(Min/100*x)];
            PE_Range = [OneYearPE(Position(2)),OneYearPE(Position(1))];
        end
        function h = Plot(obj,CombinedDataSet,Visible)
            PE_Range = obj.OneYearPeRange(CombinedDataSet);
            PE = obj.GetColumn(CombinedDataSet,'PE');
            
            n = find(isnan(PE) == 0);
            PE = PE(n);
            
            CurrentPE = PE(end);
            PE_Range2 = obj.OneYearPeRange2(CombinedDataSet,90,10);

            % plot 
            % obj.PlotDataSet(EpsDataSet,'YearEnd','EPS','r');
            h.figure = figure('Visible',Visible);
            
            obj.PlotDataSet(CombinedDataSet,'date','EPS_','r');
            obj.PlotDataSet(CombinedDataSet,'date','open','b');
            obj.PlotDataSet(CombinedDataSet,'date','PE','g');

            legend({'SharePrice'; ...
                    'EPS'; ...
                    'PE'})    
            xlabel('Date')
            ylabel('Val')
            datetick

            String = {['PE ratio range: [',num2str(PE_Range(1)),',',num2str(PE_Range(2)),']']; ...
                      ['PE ratio range: [',num2str(PE_Range2(1)),',',num2str(PE_Range2(2)),']']; ...
                      ['Current PE: ',num2str(CurrentPE)]
                      };
            title(String)
            h.OneYr_PE_Range = PE_Range;
            h.OneYr_PE_Range9010 = PE_Range2;
            h.CurrentPE = CurrentPE;
            
            % obj.SetDateRange(EpsDataSet,SharePriceDataSet);
        end
        function EpsDataSet = GetEPSDataSet(obj,Symbol)
            %%
            matpath = [obj.InstallDir,'Results\EPS\mat\'];
            load([matpath,Symbol])
        end
    end
end