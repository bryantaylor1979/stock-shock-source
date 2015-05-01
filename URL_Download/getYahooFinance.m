function struct = getYahooFinance(Symbol)
    % Download URL
    url = ['http://finance.yahoo.com/q/ks?s=',Symbol];
    nr_table   = 7;
    [s,Error] = download(url);
    subHeading = [];
    % Decode URL
    Headings = {    'Valuation Measures'; ...
                    'Financial Highlights'; ...
                    'Trading Information'};
                
    TableNames = {  'Fiscal Year'; ...
                    'Profitability'; ...
                    'Management Effectiveness'; ...
                    'Income Statement'; ...
                    'Balance Sheet'; ...
                    'Cash Flow Statement'; ...
                    'Stock Price History'; ...
                    'Share Statistics'; ...
                    'Dividends & Splits'};
    i = 0;
    while true
        i = i + 1;
        out_table = decodeTable(s,'nr_table',i);
        tableName = out_table{1,1};
        tableName = strrep(tableName,'amp; ',' ');
        n = find(strcmpi(tableName,Headings));
        if not(isempty(n))
            Heading = strrep(tableName,' ','');
        end
        if strcmpi(tableName,'Valuation Measures')
            out_table = decodeTable(s,'nr_table',i+1);
            subHeading = 'fake';
            start_index = 1;
            n = NaN;
        else
            start_index = 2;
            n = find(strcmpi(tableName,TableNames));
        end
        if not(isempty(n))
            if not(isnan(n))
                subHeading  = strrep(tableName,' ','');
                subHeading  = strrep(subHeading,'&','And');
            end
            y = size(out_table,1);
            for j = start_index:y
                VarName = strrep(out_table{j,1},'3:','');
                VarName = strrep(out_table{j,1},'5:','');
                VarName = strrep(VarName,'4:','');
                VarName = strrep(VarName,'2:','');
                VarName = strrep(VarName,':','');
                VarName = strrep(VarName,' ','_');
                VarName = strrep(VarName,'(','');
                VarName = strrep(VarName,')','');
                VarName = strrep(VarName,'-','_');
                VarName = strrep(VarName,'/','__Div__');
                VarName = strrep(VarName,'&amp;','And');
                VarName = strrep(VarName,'%','Per');
                VarName = strrep(VarName,',','_');
                Value = out_table{j,2};

                % check if number
                Value1 = strrep(Value,',','');
                Num = str2num(Value1);
                if not (isempty(Num))
                   Value = Num;
                end
                n1 = strfind(VarName,'52_Week_High');
                n2 = strfind(VarName,'52_Week_Change');
                n3 = strfind(VarName,'52_Week_Low');
                n4 = strfind(VarName,'Enterprise_Value');
                if and(not(isempty(n1)),n1 == 1)
                    Date = strrep(VarName,'52_Week_High','');
                    struct.(Heading).(subHeading).('n52_Week_High') = Value;
                    struct.(Heading).(subHeading).('n52_Week_High_Date') = Date;
                elseif not(isempty(n2))
                    struct.(Heading).(subHeading).('n52_Week_Change') = Value;
                elseif and(not(isempty(n3)),n3 == 1)
                    Date = strrep(VarName,'52_Week_Low','');
                    struct.(Heading).(subHeading).('n52_Week_Low') = Value;
                    struct.(Heading).(subHeading).('n52_Week_Low_Date') = Date;
                elseif and(not(isempty(n4)),n4 == 1)
                    Date = strrep(VarName,'Enterprise_Value','');
                    struct.(Heading).(subHeading).('Enterprise_Value') = Value;
                    struct.(Heading).(subHeading).('Enterprise_Value_Date') = Date;
                else
                    try
                        if strcmpi(subHeading,'fake')
                            struct.(Heading).(VarName) = Value;
                        else
                            struct.(Heading).(subHeading).(VarName) = Value;
                        end
                    catch
                        if strcmpi(subHeading,'fake')
                            struct.(Heading).(['n',VarName]) = Value;
                        else
                            struct.(Heading).(subHeading).(['n',VarName]) = Value; 
                        end
                    end
                end
            end
        end
        if strcmpi(subHeading,'DividendsAndSplits')
            break
        end
    end
end
function Example()
    %%
    struct = getYahooFinance('BARC.L')
    %%
    struct = getYahooFinance('GOOG')
end