function WeekNumber = WeekNum(DateNum)
    datestr(DateNum,'ddd dd.mm.yyyy');

    % First Day Of The Year
    FirstDayOfYear = datenum(datestr(DateNum,'yyyy'),'yyyy');

    % Start Of Week One
    Day = datestr(FirstDayOfYear,'ddd');
    if obj.DayNum(Day) == 1
        Num = 0;
    else
        Num = 8 - obj.DayNum(Day);
    end  
    StartOfWeekOne = FirstDayOfYear + Num;
    datestr(StartOfWeekOne,'ddd dd.mm.yyyy');

    %Week Number
    WeekNumber = floor((DateNum - StartOfWeekOne)/7);
end %Not used any more
function Example()
    %%
    WeekNumber = WeekNum(today)
end