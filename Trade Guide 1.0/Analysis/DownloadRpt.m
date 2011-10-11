function [output] = DownloadRpt(varargin)
%Written by:    Bryan Taylor
%Date Created:  4th May 2008
%Date Modified: 4th May 2008

[x] = size(varargin,2);
if x == 2
    display = varargin{2};
    DataAdded = [];
elseif x == 3
    display = varargin{2}; 
    DataAdded = varargin{2}; 
else
    DataAdded = [];
    display = true;
end
tablehandle = varargin{1};

if isempty(DataAdded)
DataAdded = GetTableData(tablehandle,'DataAdded');
end
[TotalNoOfSymbolsInBase] = size(DataAdded,1);

%Number Updated
n = find(strcmpi(DataAdded,'true'));
NoOfTablesUpdated = size(n,1);

%Number Failed
n = find(strcmpi(DataAdded,'false'));
NoOfTablesFailed = size(n,1);
n = find(strcmpi(DataAdded,'n/a'));
NoOfTablesFailed = size(n,1) + NoOfTablesFailed;

%Fail symbols analysis
DataPreset = GetTableData(tablehandle,'DataPreset');
n = find(strcmpi(DataPreset,'n/a'));
NoNotFoundOnYahoo = size(n,1);

n = find(strcmpi(DataAdded,'false'));
NoOfTablesFailAddToLocalBase = size(n,1);

%Time to download
Time = GetTableData(tablehandle,'Date/Time');
[x] = size(Time,1);
StartTime = datenum(Time(1));
EndTime = datenum(Time(x));
Duration.datenum = EndTime-StartTime;
Duration.hoursnum = 24*Duration.datenum;
Duration.hours = floor(Duration.hoursnum);
Duration.minutesnum = 60*rem(Duration.hoursnum,1);
Duration.min = floor(Duration.minutesnum);
Duration.secsnum = 60*rem(Duration.minutesnum,1);
Duration.secs = floor(Duration.secsnum);

String = {  ...
            'Overall Stats:'; ...
            '========='; ...
            ['Total Number Of Symbols In Local Database: ',num2str(TotalNoOfSymbolsInBase)]; ...
            ['Number of symbols updated: ',num2str(NoOfTablesUpdated),' (',num2str(NoOfTablesUpdated/TotalNoOfSymbolsInBase*100),'%)']; ...
            ['Number of symbols failed to update: ',num2str(NoOfTablesFailed),' (',num2str(NoOfTablesFailed/TotalNoOfSymbolsInBase*100),'%)']; ...
            ''; ...
            'Reason for Failures:'; ...
            '================'; ...
            ['Data Found on yahoo: ',num2str(NoNotFoundOnYahoo),' (',num2str(NoNotFoundOnYahoo/NoOfTablesFailed*100),'%)']; ...
            ['Not Added to Local Base: ',num2str(NoOfTablesFailAddToLocalBase),' (',num2str(NoOfTablesFailAddToLocalBase/NoOfTablesFailed*100),'%)']; ...
            ''; ...
            'Simulation Time:'; ...
            '================'; ...
            ['Download Time: ',num2str(Duration.hours),'h ',num2str(Duration.min),'m ',num2str(Duration.secs),'s']; ...
            };

if display == true
    uiwait(msgbox(String))
end

output.TotalNoOfSymbolsInBase = TotalNoOfSymbolsInBase;
output.NoOfTablesUpdated = NoOfTablesUpdated;
output.NoOfTablesFailed = NoOfTablesFailed;
output.NoNotFoundOnYahoo = NoNotFoundOnYahoo;
output.NoOfTablesFailAddToLocalBase = NoOfTablesFailAddToLocalBase;
output.Duration = Duration;