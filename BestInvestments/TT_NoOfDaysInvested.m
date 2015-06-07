function DATASET = TT_NoOfDaysInvested(DataSet)
    %Input MUST be a trade table format
    BuyDateNum = DataSet.BuyDate;
    SellDateNum = DataSet.SellDate;

    NoOfDaysInvested = SellDateNum - BuyDateNum;

    [x] = size(NoOfDaysInvested,1);
    for i = 1:x
        NoOfWorkingDaysInvested(i,1) = NoOfWorkingDaysBetweenDates(BuyDateNum(i),SellDateNum(i));
    end

    %Build Ouput DATASET
    DATASET = [DataSet,dataset(BuyDateNum,SellDateNum,NoOfDaysInvested,NoOfWorkingDaysInvested)];
end
function [NoOfWorkingDays] = NoOfWorkingDaysBetweenDates(Start,End)
    DayOfTheWeek_Start = datestr(Start,8);
    DayOfTheWeek_End = datestr(End,8);

    %Week Diff
    Start_DateNum = DateOfWeekStart(Start);
    End_DateNum = DateOfWeekStart(End);
    WeekDiff = (End_DateNum - Start_DateNum)/7;

    DayReSync = DayNum(DayOfTheWeek_End) - DayNum(DayOfTheWeek_Start);

    NoOfWorkingDays = 5*WeekDiff + DayReSync;            
end
function Example()
    %% 
    DATASET = getBritishbullsHistory('BARC.L');
    TT_DATASET = TradePlan2TradeTable(DATASET);
    DATASET = TT_NoOfDaysInvested(TT_DATASET);
end
function DateNum = DateOfWeekStart(DateNum)
    DateNum2 = DayNum(DateNum);
    DateNum = DateNum - DateNum2+1;
end
function [DayNum2] = DayNum(DayNum)
    if isnumeric(DayNum)
        DayNum = datestr(DayNum,'ddd');
    end
    [x] = size(DayNum,1);
    for i = 1:x
        switch lower(DayNum(i,:))
            case 'mon'
                DayNum2 = 1;
            case 'tue'
                DayNum2 = 2;
            case 'wed'
                DayNum2 = 3;
            case 'thu'
                DayNum2 = 4;
            case 'fri'
                DayNum2 = 5;
            case 'sat'
                DayNum2 = 6;
            case 'sun'
                DayNum2 = 7;
        end
    end
end