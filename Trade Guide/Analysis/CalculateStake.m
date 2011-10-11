classdef CalculateStake
    properties
        ColumnNames = { 'Symbol'; ...
                        'Action'; ...
                        'DateNum'; 
                        'Stakes'; ...
                        'NoOfStakes'; ...
                        'MoneyPot'; ...
                        'TotalMoney'; ...
                        'PriceMean'; ...
            };
        Config = true;
    end
    methods (Hidden = false)
        function [Output] = Process(varargin)
        %This function works out what stake to put on each investment
        %Example: [TradeStructure] = CalculateStake(TradeStructure)
        %
        %Added Fields:
        %   stake:  When it is a buy action, this ammount is equal to the amount of
        %   money invested.
        %
        %   NoOfStakes: This number is equal to the number of stakes not in use on
        %   the day of the investment.
        %
        %   MoneyPot: Amount of money not invested on that day.

            %% Functional
            global h
            investment = 100;
            number_of_investments = 10;

            intial_investement = investment/number_of_investments;

            symbolsinvested = [];
            MoneyPot = investment; %money not currently invested
            NoOfStakes = number_of_investments; %number of stakes not invested
            TotalMoney = investment; % total current assets

            [OutPutArray] = GetStageData('Descion');
            OutPutArray = flipdim(OutPutArray,1);
            [x] = size(OutPutArray,1);

            for i = 2:x
                Status.PercentageComplete = i/x*100;
                set(h.Status,'String',[num2str(Status.PercentageComplete,3),'% Complete'])
            %     StatusBar(h.statusbar,i/x);
                symbol = OutPutArray(i,1);
                datenum = OutPutArray(i,3);
                PriceMean = OutPutArray(i,4);
                action = OutPutArray(i,2);
                if strcmp(action,'Buy')

                    %firstly we need to check the stakes avaliable
                    if NoOfStakes<1
                        error('Not enough stakes to buy stock')
                    end
                    %Calculate what the new stake should be
                    stake = MoneyPot/NoOfStakes;

                    %update the MoneyPot and number of stakes
                    MoneyPot = MoneyPot - stake;
                    NoOfStakes = NoOfStakes - 1; 

                elseif strcmp(action,'Sell')

                    % find price the stock was bought for
                    ResultsSoFar = get(h.table,'Data');
                    symbols = ResultsSoFar(:,1);
                    [symbols] = Java2Cell(symbols);
                    n = find(strcmp(symbols,symbol));
                    n = n(1);
                    boughtpricemean = str2num(ResultsSoFar(n,8));
                    boughtstake = str2num(ResultsSoFar(n,4));

                    % Calculate new stake price
                    ratio = (str2num(PriceMean)/boughtpricemean);
                    NewStake = boughtstake*ratio;
                    stake = NewStake;

                    %Update pot of money
                    MoneyPot = MoneyPot + NewStake;
                    NoOfStakes = NoOfStakes + 1;
                    TotalMoney = TotalMoney - boughtstake + NewStake;
                else
                    error('action is not recognised') 
                end
                %Summary of Event
                RowInfo{1,1} = symbol;
                RowInfo{1,2} = action;
                RowInfo{1,3} = datenum;
                RowInfo{1,4} = stake;
                RowInfo{1,5} = NoOfStakes;
                RowInfo{1,6} = MoneyPot;
                RowInfo{1,7} = TotalMoney;
                RowInfo{1,8} = PriceMean;
                AddRow(RowInfo);
            end

            Output.dummy = 1;
        end
        function [Output] = Cfg(tablehandle)
            CalculationSelection;
        end
        function [Output] = Report(tablehandle)
            global savecriteria

            % Stage = savecriteria.stage;
            % GuiStruct = savecriteria.GuiStruct;
            % GuiStruct = GuiStruct{1};
            % TradeStructureStake = GuiStruct(Stage).struct;

            % TotalMoney = cell2mat(Struct2Data(TradeStructureStake,'TotalMoney'));
            % datenum = cell2mat(Struct2Data(TradeStructureStake,'datenum'));
            meanTotalMoney = str2double(GetTableData(tablehandle,'TotalMoney'));
            datenum = str2double(GetTableData(tablehandle,'DateNum'));


            h.figure = figure;

            %Increase Size Of Figure
            Position = get(h.figure,'Position');
            Position(4) = Position(4)+50;
            set(h.figure,'Position',Position);


            h.line = plot(datenum,meanTotalMoney);
            h.axes = gca;
            Position = get(h.axes,'Position');
            Position(4) = 0.7;
            Position(2) = 0.2;
            set(h.axes,'Position',Position);

            datetick;
            xlabel('Date')
            ylabel('Profit(£)')
            title('Profit Curve')

            [x] = size(meanTotalMoney,2);
            PercentageGrowth = round(meanTotalMoney(1)/meanTotalMoney(x)*10000)/100;
            TotalNumberOfDays = datenum(1) - datenum(x);
            NumberOfYears = TotalNumberOfDays/365;
            APR = round(PercentageGrowth/NumberOfYears*100)/100;

            set(h.figure,'Name','Profit Plot');
            set(h.figure,'NumberTitle','off');   
            % set(h.figure,'MenuBar','none');

            String = {['PercentageGrowth: ',num2str(PercentageGrowth),'%'];...
                      ['TotalNumberOfDays: ',num2str(TotalNumberOfDays)];...
                      ['NumberOfYears: ',num2str(NumberOfYears)];...
                      ['APR: ',num2str(APR),'%']};

            Output.PercentageGrowth = PercentageGrowth;
            Output.TotalNumberOfDays = TotalNumberOfDays;
            Output.NumberOfYears = NumberOfYears;
            Output.APR = APR;

            h.text = uicontrol( 'Style','text', ...
                                'String',String, ...
                                'HorizontalAlignment','left');
            set(h.text,'Position',[40,10,200,60]);
        end
        function [TradeStructure] = Process2(TradeStructure)
            %This function works out what stake to put on each investment
            %Example: [TradeStructure] = CalculateStake(TradeStructure)
            %
            %Added Fields:
            %   stake:  When it is a buy action, this ammount is equal to the amount of
            %   money invested.
            %
            %   NoOfStakes: This number is equal to the number of stakes not in use on
            %   the day of the investment.
            %
            %   MoneyPot: Amount of money not invested on that day.
            global h
            [x] = size(TradeStructure,2);
            investment = 100;
            number_of_investments = 10;

            intial_investement = investment/number_of_investments;
            StatusBar(h.statusbar,0);

            symbolsinvested = [];
            MoneyPot = investment; %money not currently invested
            Stakes = number_of_investments; %number of stakes not invested
            TotalMoney = investment; % total current assets

            for i = 1:x
                StatusBar(h.statusbar,i/x);
                profit(i).symbol = TradeStructure(i).symbol;
                profit(i).datenum = TradeStructure(i).datenum;
                profit(i).pricemean = TradeStructure(i).PriceMean;
                if strcmp(TradeStructure(i).action,'Buy')
                    %firstly we need to check the stakes avaliable
                    profit(i).action = 'Buy';
                    if Stakes<1
                        error('Not enough stakes to buy stock')
                    end
                    %Calculate what the new stake should be
                    profit(i).stake = MoneyPot/Stakes;
                    TradeStructure(i).stake = MoneyPot/Stakes;

                    %update the MoneyPot and number of stakes
                    MoneyPot = MoneyPot - profit(i).stake;
                    Stakes = Stakes - 1;
                    TradeStructure(i).NoOfStakes = Stakes;
                    TradeStructure(i).MoneyPot = MoneyPot;
                    TradeStructure(i).TotalMoney = TotalMoney;  
                    %Calculate totalprofit
                    %not required nothing has changed

                elseif strcmp(TradeStructure(i).action,'Sell')
            %        symbolsinvested = removesymbol(symbolsinvested,TradeStructure(i).symbol)

                    % find price the stock was bought for
                    symbols = struct2cell(profit);
                    symbols = symbols(1,:,:);
                    n = find(strcmp(symbols,TradeStructure(i).symbol));
                    %last one is this Sell signal, so last minus 1
                    [y] = size(n,1);
                    loc = n(y-1);
                    bought = profit(loc);

                    % Calculate new stake price
                    ratio = (TradeStructure(i).PriceMean/bought.pricemean);
                    NewStake = bought.stake*ratio;
                    TradeStructure(i).stake = NewStake;

                    %Update pot of money
                    MoneyPot = MoneyPot + NewStake;
                    Stakes = Stakes + 1;
                    TotalMoney = TotalMoney - bought.stake + NewStake;

                    TradeStructure(i).NoOfStakes = Stakes;
                    TradeStructure(i).MoneyPot = MoneyPot;
                    TradeStructure(i).TotalMoney = TotalMoney;        
            %         disp(['Action: Sell  Symbol:',TradeStructure(i).symbol,' Stake:',num2str(TradeStructure(i).stake),' TotalMoney: ',num2str(TotalMoney),' MoneyPot: ',num2str(MoneyPot),' Stakes: ',num2str(Stakes)])
                else
                    error('action is not recognised') 
                end
                %Summary of Event
                RowInfo{1,1} = TradeStructure(i).symbol;
                RowInfo{1,2} = TradeStructure(i).action;
                RowInfo{1,3} = TradeStructure(i).datenum;
                RowInfo{1,4} = TradeStructure(i).stake;
                RowInfo{1,5} = TradeStructure(i).NoOfStakes;
                RowInfo{1,6} = TradeStructure(i).MoneyPot;
                RowInfo{1,7} = TradeStructure(i).TotalMoney;
                AddRow(RowInfo);
            end
        end
    end
end