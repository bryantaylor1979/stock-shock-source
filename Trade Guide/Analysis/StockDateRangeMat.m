function [startdate,enddate,errorcode] = StockDateRangeMat(varargin);
%Quick:
%[startdate,enddate] = StockDateRangeMat(symbol,DataStore);
%
%Slow:
%[startdate,enddate] = StockDateRangeMat(symbol);
% written by:   Bryan Taylor 
% Date Created: 25th August 2008

global h
SaveDataPath = h.path.savedata;

x = size(varargin,2);
errorcode = 0;
if x == 2
    DatabaseName = varargin{1};
    symbol = varargin{2};
    path = [SaveDataPath,DatabaseName,'\Download_Mat\Data\']
    load([path,symbol,'.mat']);
else
    DatabaseName = varargin{1};
    symbol = varargin{2};
    DataStore = varargin{3};
end

if not(exist('DataStore')) %Load function didn't return datastore
    enddate = 'No Data';
    startdate = 'No Data';
    errorcode = -2;  
    return
end
if isstruct(DataStore)
    DataStore = DataStore.DataStore;
end
if isempty(DataStore) % Empty Stock in local database
    enddate = 'No Data';
    startdate = 'No Data';
    errorcode = -1;
    return
end
Datenum = DataStore(:,1);
enddate = max(Datenum);
startdate = min(Datenum);