function TRADES2 = DaySummary2TradePlan(BuyQueryName,SellQueryName,NoOfInvestments)
    %%
    args.BuySellPriceMode = 'Spread'; % Spread, OpenPrice
            
    Mode = args.BuySellPriceMode; % Spread, OpenPrice
    ResultsDir = '/home/imagequality/stock-shock-source/BestInvestments/Results';
    [Max,Min] = Query_DateRange(ResultsDir,BuyQueryName);

    %%
    InvestedSymbols = [];
    SymbolSpread = NoOfInvestments;

    %% Work out duration
    End = Max;
    switch obj.Duration
        case 'all'
            Start = Min;
        case '1y'
            Start = Max - 365;
        case '3m'
            Start = Max - (30*4);
        case '2w'
            Start = Max - (2*7);
        otherwise
    end


    First = true;
    for i = Start:End
        waitbar((i-Start)/(End-Start));
        Date = i;
        DayOfTheWeek = datestr(Date,'DDD');
        switch DayOfTheWeek
            case {'Mon','Tue','Wed','Thu','Fri'}
                %Number of new investments required (NewNo)
                [NoIn] = size(InvestedSymbols,1);
                NewNo = SymbolSpread - NoIn;
                disp(['Date: ',datestr(Date)])
                disp('=================')
                disp(['Number Of Currently Invested Symbols: ',num2str(NoIn)])
                disp(['Day of the week: ',DayOfTheWeek])

                %Look at SELL symbols
                if not(isempty(InvestedSymbols))
                     SellSymbols = obj.IsSell(SellQueryName,InvestedSymbols,Date);
                     if not(isempty(SellSymbols))
                        [DATASET] = obj.BuildDataSet(SellSymbols,'SELL',Date);
                        if strcmpi(Mode,'OpenPrice')
                            DATASET = obj.GetSellPrice(DATASET);
                        elseif strcmpi(Mode,'Spread')
                            DATASET = obj.GetPriceWithSpread(DATASET,'Bid');
                        else
                            error('');
                        end
                        if isempty(DATASET)

                        else
                        TRADES2 = [TRADES2;[DATASET]];
                        InvestedSymbols = obj.RemoveSymbols(InvestedSymbols,SellSymbols);
                        end
                     end
                end

                %Look at BUY symbols
                if not(NewNo == 0)
                    [DATASET, Status]  = obj.GetQueryResults(BuyQueryName,Date);
                    if and(Status == 0,isempty(DATASET)==0); %Data is avaliable
                        disp(['BestBuys Executed:  Success'])
                        DATASET = obj.DataSetRemoveSymbols(DATASET,InvestedSymbols);
                        DATASET = obj.RemoveUnSupportedSymbols2(DATASET,Date);
                        DATASET = obj.RemoveUnConfirmed(DATASET,Date);

                        if not(isempty(DATASET))
                            BuySymbols = obj.GetColumn(DATASET,'BB_HIST_Ticker');
                            BuySymbols = obj.RemoveSymbols(BuySymbols,InvestedSymbols);
                            BuySymbols = obj.LimitBuys(BuySymbols,NewNo);

                            if not(isempty(BuySymbols))
                                %Build Table
                                [DATASET] = obj.BuildDataSet(BuySymbols,'BUY',Date);
                                if strcmpi(Mode,'OpenPrice')
                                    DATASET = obj.GetSellPrice(DATASET);
                                elseif strcmpi(Mode,'Spread')
                                    DATASET = obj.GetPriceWithSpread(DATASET,'Ask');
                                else
                                    error('');
                                end

                                if not(isempty(DATASET))
                                    BuySymbols = obj.GetColumn(DATASET,'BB_Ticker');
                                    InvestedSymbols = [InvestedSymbols;BuySymbols];
                                    %Build Trade List
                                    if First == true
                                        TRADES2 = DATASET;
                                        First = false;
                                    else
                                        try
                                        TRADES2 = [TRADES2;[DATASET]];
                                        catch
                                           x = 1; 
                                        end
                                    end
                                end
                            end
                        end
                    else
                        disp(['BestBuys Executed:  Failed'])
                    end
                end

                % Other Info    
                disp(' ')
            case {'Sat','Sun'}
            otherwise
                disp('Day of week not recognised')
        end
    end
end

function [Max,Min] = Query_DateRange(ResultsDir,QueryName)
    CD = pwd;
    Directory = [ResultsDir,'QuoteAbstractionLayer\Results\',QueryName,'\DataSet\'];
    cd(Directory)
    filenames = struct2cell(dir);
    Names = filenames(1,:,:);
    DateNum = datenum(strrep(Names(3:end-1),'.mat',''));
    Max = max(DateNum);
    Min = min(DateNum);
    cd(CD)
end  