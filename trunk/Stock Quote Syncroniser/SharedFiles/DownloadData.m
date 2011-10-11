function [] = DownloadData(mode)
%Complete download and overwrite all data
%
%Inputs: 
%   Mode  
%       'all'       Download all available data
%       'empty'     Download data for empty tables
%       'update'    Update Full tables.
%
%Written by: Bryan Taylor
%Modified by: Bryan Taylor
%Date Created: 16th April 2007
%Last Modified: 16th April 2007

switch lower(mode)
    case 'all'
        [allsymbols] = GetSymbols('FTSE 100');
    case 'empty'
        [allsymbols] = DatabaseDateRange('empty');
    case 'update'
        [allsymbols] = DatabaseDateRange('full');
    otherwise
        error('mode not recognised')
end

% how far in history do we want to go
years = 50;
weeks = 0;
days = 0;

window = 100*365; %one hundred years worth of data.

[x] = size(allsymbols,2);
h = waitbar(0);

setdbprefs({'DataReturnFormat','ErrorHandling','NullNumberRead','NullNumberWrite','NullStringRead','NullStringWrite','JDBCDataSourceFile'},{'cellarray','store','NaN','NaN','null','null',''});
conn = database('stocks','','');


    
for i = 1:x
    waitbar(i/x,h);
    
    %download data from yahoo
    datapresent = true;
    if strcmp(lower(mode),'update')
        
        %check to see if stock is fully up to date
        if allsymbols{i}.enddate+1 == today
            disp([allsymbols{i}.symbol,' is completely up-to-date'])
            datapresent = false; %don't try to insert data
        else       
            try
                % get date range
                [date, close, open, low, high, volume, closeadj] = sqq(allsymbols{i}.symbol,allsymbols{i}.enddate+1,today,'d');             
            catch
                disp(['No data found for symbol: ',allsymbols{i}.symbol])
                datapresent = false;
            end
        end
    else
        try
            [date, close, open, low, high, volume, closeadj] = sqq(allsymbols{i}.symbol,today-window,today,'d'); 
        catch
            disp(['No data found for symbol: ',allsymbols{i}.symbol])
            datapresent = false;
        end
    end

    % insert into local database
    if datapresent == true; %only insert into database if there is data downloaded.
        
        %START build structure
        [y] = size(date,1);
        
        chunksize = 600;
        for k = 1:chunksize:y
            if k+chunksize<y+1
                max = k+chunksize;
            else
                max = y+1; 
            end
            for j = k:max-1
                exdata(j,:) = {allsymbols{i}.symbol,date(j),open(j),close(j),low(j),high(j),volume(j),closeadj(j)};
            end
            %END build structure
        
            %START insert data into database
            try
                fastinsert(conn,allsymbols{i}.symbol,{'symbol','datenum','open','close','low','high','volume','closeadj'},exdata);
                [z] = size(close,1);
                disp(['SUCCESS: ',num2str(k),' to ',num2str(max-1),' stocks added to TABLE ''',allsymbols{i}.symbol,''''])
            catch
                disp(['NOT SUCCESSFULL:  sunbmitting data to ',allsymbols{i}.symbol,' stock table'])
            end
            %END insert data into database
        end
    end
    %make sure all date is cleared
    clear close
    clear date
    clear open
    clear low
    clear high
    clear volume
    clear closeadj
    clear exdata
end

try
    close(conn)
catch
    warning('Error when closing database') 
end