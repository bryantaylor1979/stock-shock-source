function [tablesnames] = DatabaseDateRange(mode)
%Similar to StockDateRange but for the whole database
%
%   'all' - List All database information
%   'empty' - List stocks which have no data
%
%Example:
%[tablesnames] = DatabaseDateRange('empty')

%list all stocks in database
setdbprefs({'DataReturnFormat','ErrorHandling','NullNumberRead','NullNumberWrite','NullStringRead','NullStringWrite','JDBCDataSourceFile'},{'cellarray','store','NaN','NaN','null','null',''});
conn = database('stocks','','');
dbmeta = dmd(conn);
t = tables(dbmeta, 'cata');

%***********************************
%get all tables
[x] = size(t,1);

count = 1;
for i = 1:x
    if strcmp(t(i,2),'TABLE') 
       tablelist(count) = t(i,1);
       count = count + 1; 
    end
end
%***********************************
%end all tables

[x] = size(tablelist,2);
datetype = 1;
count = 1;
for i = 1:x
    switch mode
        case 'all'
            [startdate,enddate] = StockDateRange(tablelist{i});
            if strcmp(startdate,'No Data')
                fprintf('%s: Start Date: N/A End Date: N/A\n',tablelist{i});
            else
                fprintf('%s: Start Date: %s End Date: %s\n',tablelist{i},datestr(startdate,datetype),datestr(enddate,datetype));
            end
        case 'empty'
            try
                [startdate,enddate] = StockDateRange(tablelist{i});
                if strcmp(startdate,'No Data')
                    tablesnames{count}.symbol = tablelist{i};
                    disp(['Table: ',tablelist{i},' Missing'])
                    count = count + 1;
                end
            catch
              disp(['Error when reading: ',tablelist{i},' Table'])  
            end
        case 'full'
            [startdate,enddate] = StockDateRange(tablelist{i});
            if not(strcmp(startdate,'No Data'))
                tablesnames{count}.symbol = tablelist{i};
                tablesnames{count}.startdate = startdate;
                tablesnames{count}.enddate = enddate;
                disp(['Table: ',tablelist{i},' Full'])
                count = count + 1;
            end
        otherwise
            error('mode not recognised')
    end
end

%Summary of information
if exist('tablesnames')
    disp([num2str(size(tablesnames,2)),' empty tables have been found']);
else 
    disp('No empty tables were found');
end
