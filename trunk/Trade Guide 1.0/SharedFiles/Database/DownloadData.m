function [status] = DownloadData(conn,allsymbols,mode)
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


% how far in history do we want to go
years = 50;
weeks = 0;
days = 0;

window = 100*365; %one hundred years worth of data.

[x] = size(allsymbols,2);
    
for i = 1:x
    symbol = allsymbols{i};
    symbol = strrep(symbol,'_','.');
    
    if strcmpi('CLF',symbol)
        status.datapresent = 'failed';
        status.NoOfEntriesAdded = 'failed';
    else
        %download data from yahoo
        datapresent = 'true';
        if strcmp(lower(mode),'update')

            %check to see if stock is fully up to date
            [startdate,enddate] = StockDateRange(conn,strrep(symbol,'.','_'));
            if enddate+1 == today
                disp([symbol,' is completely up-to-date'])
                datapresent = 'false'; %don't try to insert data
            else       
                try
                    % get date range    
                    [date, close, open, low, high, volume, closeadj] = sqq(symbol,enddate+1,today,'d');             
                catch
                    disp(['No data found for symbol: ',symbol])
                    datapresent = 'false';
                end
            end
        else
            try
                [date, close, open, low, high, volume, closeadj] = sqq(symbol,today-window,today,'d'); 
            catch
                disp(['No data found for symbol: ',symbol])
                datapresent = 'false';
            end
        end
        status.datapresent = datapresent;
        % insert into local database
        if strcmpi(datapresent,'true') %only insert into database if there is data downloaded.

            %START build structure
            [y] = size(date,1);

            chunksize = 100000;
            for k = 1:chunksize:y
                if k+chunksize<y+1
                    max = k+chunksize;
                else
                    max = y+1; 
                end
                for j = k:max-1
                    exdata(j,:) = {date(j),open(j),close(j),low(j),high(j),volume(j),closeadj(j)};
                end
                %END build structure

                %START insert data into database
                try
                    fastinsert(conn,strrep(symbol,'.','_'),{'datenum','open','close','low','high','volume','closeadj'},exdata);
                    [z] = size(close,1);
                    disp(['SUCCESS: ',num2str(k),' to ',num2str(max-1),' stocks added to TABLE ''',symbol,'''']);
                    status.DataAdded = 'true';
                catch
                    status.DataAdded = 'false';
                    disp(['NOT SUCCESSFULL:  sunbmitting data to ',strrep(symbol,'.','_'),' stock table'])
                end
                %END insert data into database
            end   
        end
        try
        status.NoOfEntriesAdded = y;
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
end