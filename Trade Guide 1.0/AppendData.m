function [] = AppendData(conn,symbol,data,FieldName,Mode);
%Append Data to databased
%
%Written by: Bryan Taylor
%Date Created: 25th Febuary 2008
%Date Modified: 25th Febuary 2008

%Check the field name is there
[y] = size(data,1);
whereclause = '';
count = 1;
Updated = 'false';

[Date,OldData] = StockQuote(symbol,{'DateNum';FieldName},'all','report',false,'outputs','multiple');
if CompareData(data,OldData)
    drawnow;
else
    for j = 1:y
        if not(data(j) == OldData(j))
            Updated = 'true';
            if strcmpi(Mode,'update')
                try
                whereclause = ['WHERE datenum = ',num2str(Date(j))];
                update(conn, symbol, {FieldName}, data(j), whereclause);
                catch
                disp(['Symbol: ',symbol,' DateNum: ',num2str(OldData(j))])
                error('Update not possible')
                end
            else
            if j == 1
                whereclause = {['WHERE datenum = ',num2str(Date(j))]};
            else
                whereclause = [whereclause;{['WHERE datenum = ',num2str(Date(j))]}];
            end
            AppendDatas(count,1) = data(j);
            count = count + 1;
            end
        end
    end
end
disp(['Updated: ',Updated])
if strcmpi(Mode,'fastupdate')
    try
        if exist('AppendDatas')
        update(conn, symbol, {FieldName}, AppendDatas, whereclause);
        disp('fast update complete');
        else
        disp('symbol up to date')    
        end
    catch
        disp(['Symbol: ',symbol,' DateNum: ',num2str(OldData(j))])
        error('Update not possible')
    end
end