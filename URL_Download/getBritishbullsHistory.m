function DATASET = getBritishbullsHistory(Symbol)
    url = ['https://www.britishbulls.com/SignalPage.aspx?lang=en&Ticker=',Symbol];
    [s,Error] = download(url);
    
    %%
    DATASET = URL2Table2(s);
end
function Example(Symbol)
    %%
    s = getBritishbullsHistory('BARC.L')
    
    %%
    s = getBritishbullsHistory('RBS.L')
    
    %%
    s = getBritishbullsHistory('AA.L')
end
function DATASET = URL2Table(Symbol,s)
    % Extract the history table from the URL
    %

    %% Table Crop
    n = findstr(s,'Signal History');
    nend = findstr(s,'<td><strong><font color="#FFFFFF">Disclaimer</font></strong></td>');
    TableCrop = s(n:nend);

    %% Line Crop
    n = findstr(TableCrop,'<td width=50  height=7 valign="bottom"  cellpadding=0 bgcolor="#FFFFCC"> <font size=1>');
    [x] = size(n,2);
    LineCrop = [];
    for i = 1:1:x-1
        Line = TableCrop(n(i):n(i+1));
        LineCrop = [LineCrop;{Line}];
    end
    Line = TableCrop(n(x):end);
    LineCrop = [LineCrop;{Line}];

    %% Value Crop
    [x] = size(LineCrop,1);
    for i = 1:x
       Line = LineCrop{i};
       Symbols{i,1} = Symbol;

       % Money
       n1 = findstr(Line,'<td  width=50 height=7   align="right" valign="bottom" cellpadding=0 bgcolor="#FFFFCC">  <font size=1>');
       EndLine = Line(n1+102:end);
       n = findstr(EndLine,'</font>');
       Money2 = strrep(EndLine(1:n(1)-1),',','');
       Money(i,1) = str2num(Money2);

       % Signal
       startn = findstr(Line,'<td width=37  height=7  valign="bottom"  cellpadding=0 bgcolor="#FFFFCC">');
       SignalLine = Line(startn:n1);
       n2 = findstr(SignalLine,'<b>');
       n3 = findstr(SignalLine,'</b>  </font>');
       SignalLine = SignalLine(n2+5:n3-13);
       n = findstr(SignalLine,'Buy');
       if isempty(n)
            Signal{i,1} = 'Sell';
       else
            Signal{i,1} = 'Buy';
       end

       % Confimation Signal
       startn = findstr(Line,'<td width=37  height=7  valign="bottom"  cellpadding=0 bgcolor="#FFFFCC">');
       SignalLine = Line(startn:n1);
       n7 = findstr(SignalLine,'<td align="center"  height=7  valign="bottom" cellpadding=0 bgcolor="#FFFFCC" ><img  src="images/');
       if not(isempty(n7)) %Check True
            ConfSignal{i,1} = 'TRUE';
       else
            ConfSignal{i,1} = '';
       end
       n8 = findstr(SignalLine,'Uncheck');
       if not(isempty(n8))
            ConfSignal{i,1} = 'FALSE';
       end

       % Date
       n3 = findstr(Line,'<td width=50  height=7 valign="bottom"  cellpadding=0 bgcolor="#FFFFCC"> <font size=1>');
       n4 = findstr(Line,'</font>');
       Date{i,1} = datestr(datenum(Line(n3+86:n4-1),'dd.mm.yy'));

       %% Current Price
       startstr = '<font size=1> ';
       p = size(startstr,2);

       %%
       n5 = findstr(Line,startstr);
       endstr = '</font> ';          
       n6 = findstr(Line,endstr);

       String = strrep(Line(n5+p:n6-1),',','');
       CurrentPrice(i,1) = str2num(String);            
    end
    Symbol = Symbols;
    DATASET = dataset(Symbol,Date,CurrentPrice,Signal,ConfSignal,Money);            
end
function DATASET = URL2Table2(s)
    % Extract the history table from the URL
    %

    %% Table Crop
    n = findstr(s,'>Signal History<')
    nend = findstr(s(n:end),'</table><script id="')
    TableCrop = s(n:n+nend(3));

    %% 
    n = findstr(TableCrop,'</tr><tr id');
    x = size(n,2);
    %
    LineCrop = [];
    for i = 1:x-1
        Line = TableCrop(n(i):n(i+1));
        LineCrop = [LineCrop;{Line}];
    end
    Line = TableCrop(n(x):end);
    LineCrop = [LineCrop;{Line}];

    %%
    [x] = size(LineCrop,1);
    for i = 1:x
       try
       Line = LineCrop{i};

       % Money
       n1 = findstr(Line,'">');
       EndLine = Line(n1(6)+2:end);
       n = findstr(EndLine,'<');
       Money2 = strrep(EndLine(1:n(1)-1),',','');
       Money(i,1) = str2num(Money2);

       % Signal
       n1 = findstr(Line,'">');
       EndLine = Line(n1(4)+2:end);
       n = findstr(EndLine,'<');
       SignalLine = EndLine(1:n-1);
       Signal{i,1} = SignalLine;
       
       % Confimation Signal
       n7 = findstr(Line,'src="img/Check.gif');
       if not(isempty(n7)) %Check True
            ConfSignal{i,1} = 'TRUE';
       else
            ConfSignal{i,1} = '';
       end
       n8 = findstr(Line,'src="img/Uncheck.gif');
       if not(isempty(n8))
            ConfSignal{i,1} = 'FALSE';
       end

       % Date
       n1 = findstr(Line,'">');
       EndLine = Line(n1(2)+2:end);
       n = findstr(EndLine,'<');
       DateStr = strrep(EndLine(1:n(1)-1),',','');
       try
       Date{i,1} = datestr(datenum(DateStr,'dd/mm/yyyy'));
       catch
       Date{i,1} = 'N/A';    
       end

       %
       % Current Price
       startstr = '">';
       try
       n5 = findstr(Line,startstr);
       EndLine = Line(n5(3)+2:end);
       endstr = '<';          
       n6 = findstr(EndLine,endstr);
       String = EndLine(1:n6(1)-1);
       CurrentPrice(i,1) = str2num(String); 
       catch
       CurrentPrice(i,1) = NaN;    
       end
       end
    end
    DATASET = dataset(  {Date,'Date'}, ...
                        {CurrentPrice,'CurrentPrice'}, ...
                        {Signal,'Signal'}, ...
                        {ConfSignal,'ConfSignal'}, ...
                        {Money,'Money'});            
end