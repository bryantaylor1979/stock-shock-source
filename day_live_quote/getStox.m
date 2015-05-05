function struct = getStox(Symbol)
    n = findstr(Symbol,'.');
    if not(isempty(n))
        Symbol = Symbol(1:n-1);
    end
    url = ['http://uk.stoxline.com/q_uk.php?s=',Symbol];
    [s,Error] = download(url);
    struct = DecodeStr(s);
end
function struct = DecodeStr(s)
    TABLE1 = decodeTable(s,'nr_table',4);
    TABLE2 = decodeTable(s,'nr_table',5);
    TABLE3 = decodeTable(s,'nr_table',3);

    % get company name
    string = TABLE1{1,1};
    n = findstr(string,'(');
    string = strtrim(string(1:n-1));
    struct.CompanyName = string;

    % Price
    string = TABLE1{2,1};
    n = findstr(string,' ');
    string = string(1:n-1);
    Num = str2num(string);
    struct.Price = Num;

    % Date-Time
    string = TABLE1{2,2};
    struct.DateNum = datenum(string,'mm/dd/yyyy HH:MM');
    struct.DateStr = datestr(string);

    % Open
    string = TABLE1{3,2};
    Num = str2num(string);
    struct.Open = Num;

    % High
    string = TABLE1{4,2};
    Num = str2num(string);
    struct.High = Num;

    % Volume
    string = TABLE1{5,2};
    Num = str2num(string);
    struct.Volume = Num;

    % 52 Week High
    string = TABLE1{6,2};
    Num = str2num(string);
    struct.n52_Week_High = Num;

    % PrevClose
    string = TABLE1{3,4};
    Num = str2num(string);
    struct.PrevClose = Num;

    % Low
    string = TABLE1{4,4};
    Num = str2num(string);
    struct.PrevClose = Num;

    % Market Cap
    string = TABLE1{5,4};
    struct.MarketCap = string;

    % 52 Week Low
    string = TABLE1{6,4};
    Num = str2num(string);
    struct.n52_Week_Low = Num;

    %
    % Pivot Point
    index = 6;
    Var = TABLE2{index,1};
    string = TABLE2{index,2};
    Var = strrep(Var,' ','');
    struct.(Var) = str2num(string);

    %
    index = 3;
    Var = TABLE2{index,1};
    string = TABLE2{index,2};
    n = findstr(string,':');
    SubVar = string(n(1)+2:n(2)-17);
    struct.(Var).n6months = str2num(SubVar);
    SubVar = string(n(2)+2:end);
    struct.(Var).n1year = str2num(SubVar);

    %
    index = 4;
    Var = TABLE2{index,1};
    string = TABLE2{index,2};
    n = findstr(string,':');
    SubVar = string(n(1)+2:n(2)-17);
    struct.(Var).Support1 = str2num(SubVar);
    SubVar = string(n(2)+2:end);
    struct.(Var).Support2 = str2num(SubVar);

    %

    index = 5;
    Var = TABLE2{index,1};
    string = TABLE2{index,2};
    n = findstr(string,':');
    SubVar = string(n(1)+2:n(2)-17);
    struct.(Var).Resistance1 = str2num(SubVar);
    SubVar = string(n(2)+2:end);
    struct.(Var).Resistance2 = str2num(SubVar);

    %
    index = 7;
    Var = strrep(TABLE2{index,1},' ','');
    string = TABLE2{index,2};
    n = findstr(string,':');
    SubVar = string(n(1)+2:n(2)-17);
    struct.(Var).MA5 = str2num(SubVar);
    SubVar = string(n(2)+2:n(3)-11);
    struct.(Var).MA20 = str2num(SubVar);
    SubVar = string(n(3)+2:n(4)-11);
    struct.(Var).MA100 = str2num(SubVar);
    SubVar = string(n(4)+2:end);
    struct.(Var).MA250 = str2num(SubVar);

    %
    index = 8;
    Var = strrep(TABLE2{index,1},' ','');
    string = TABLE2{index,2};
    n = findstr(string,':');
    SubVar = string(n(1)+2:n(2)-17);
    struct.(Var).MACD_12_26 = str2num(SubVar);
    SubVar = string(n(2)+2:end);
    struct.(Var).MACD_12_26_9 = str2num(SubVar);

    %
    index = 9;
    Var = strrep(TABLE2{index,1},' ','');
    string = TABLE2{index,2};
    n = findstr(string,':');
    SubVar = string(n(1)+2:n(2)-17);
    struct.(Var).PerK_14_3 = str2num(SubVar);
    SubVar = string(n(2)+2:end);
    struct.(Var).PerD_3 = str2num(SubVar);

    %
    index = 10;
    Var = strrep(TABLE2{index,1},' ','');
    string = TABLE2{index,2};
    n = findstr(string,':');
    SubVar = string(n(1)+2:end);
    struct.(Var).RSI_14 = str2num(SubVar);

    index = 11;
    Var = strrep(TABLE2{index,1},'-','_');
    string = TABLE2{index,2};
    n = findstr(string,':');
    SubVar = string(n(1)+2:n(2)-17);
    struct.(['n',Var]).High = str2num(SubVar);
    SubVar = string(n(2)+2:n(3)-11);
    struct.(['n',Var]).Low = str2num(SubVar);
    SubVar = string(n(3)+2:end);
    struct.(['n',Var]).ChangePer = str2num(SubVar);

    %
    index = 12;
    Var = strrep(TABLE2{index,1},' ','');
    Var = strrep(Var(1:end-1),'(','_');
    string = TABLE2{index,2};
    n = findstr(string,':');
    n2 = findstr(string,'10-Days');
    SubVar = string(n(1)+2:n2-1);
    struct.(Var).n3Month = str2num(SubVar);
    SubVar = string(n2+7:end);
    struct.(Var).n10day = str2num(SubVar);

    %
    n = findstr(s,'Overall');
    string = s(n:end);
    n = findstr(string,'What');
    string = string(1:n);
    n = findstr(string,'s.bmp>');
    struct.Star = str2num(string(n-1));

    %
    n = findstr(string,'down_arrow.gif');
    n1 = findstr(string,'up_arrow.gif');
    if not(isempty(n))
        struct.direction = 'down';
    end
    if not(isempty(n1))
        struct.direction = 'up';
    end
end
function Example()
%%
s = getStox('BARC')

%%
close all
clear classes
struct = getStox('HAWK.L')
end