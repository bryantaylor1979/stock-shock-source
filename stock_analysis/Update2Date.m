function [Status,LastWorkingDay] = Update2Date(Date)
    %Will return if stock is up to date. It understand the last working day.
    switch datestr(floor(now),8)
        case 'Mon'
            LastWorkingDay = floor(now) - 3;
        case 'Sun'
            LastWorkingDay = floor(now) - 2;
        otherwise
            LastWorkingDay = floor(now) - 1;
    end
    if LastWorkingDay == Date
        Status = 'UpToDate';
    else
        Status = 'OutOfDate';
    end
end 