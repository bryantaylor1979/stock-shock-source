function [] = DownloadUpdate();

CurrentDirectory = pwd;

Summary.Updated = 10;

diary log.txt
Count = 1;
MaxThreshold = 7; %days

p = 1;
while 0 == 0
    cd(CurrentDirectory)
    tic;
    AddText(['Attempt: ',num2str(Count)]);
    
    %% only force database analysis once a day.
    %% This is required to pick up any new symbols that have been added.
    load DateLastExecuted DateLastExecuted
    if DateLastExecuted == today
        if Count == 1 %full update the first time
            [SummaryStruct,h] = IntialiseAnalysisOfData(MaxThreshold,false)
        else %Only try update the symbols that are out of date
            UpdateDataAnalysis(h,SummaryStruct)
        end
    else %if the table hasn't been analised today.
        DateLastExecuted = today;
        save DateLastExecuted DateLastExecuted
        [SummaryStruct,h] = IntialiseAnalysisOfData(MaxThreshold,true)
    end
    x = toc;
    Count = Count + 1;
    
    total_minutes = floor(x/60);
    seconds = floor(x - total_minutes*60);
    AddText(['Time taken to update: ',num2str(total_minutes),' mins, ',num2str(seconds),' secs'])
    AddText([' ']);
    Log{p}.SummaryStruct = SummaryStruct;
    [Summary] = GetSummary(SummaryStruct);
    Log{p}.Summary = Summary;
    p = p + 1;
    try
    mkdir(['C:\Log\',num2str(today),'\'])
    end
    cd(['C:\Log\',num2str(today),'\'])
    save Log Log
end
diary off

function [SummaryStruct,h] = IntialiseAnalysisOfData(MaxThreshold,forceupdate)
[SummaryStruct] = DownloadData('update');
NumberOfDaysOutOfSync = Struct2Data(SummaryStruct,'NumberOfDaysOutOfSync');
h = plotgraph(NumberOfDaysOutOfSync);
%Remove All out of date data.
[SummaryStruct] = RemoveAllOutOfDateData(SummaryStruct,MaxThreshold);
[Summary] = GetSummary(SummaryStruct);
h.Parameters = RealTimeParameter(Summary);

function [h] = UpdateDataAnalysis(h,SummaryStruct)
[SummaryStruct] = DownloadData('update');
% [SummaryStruct] = DownloadData('update_custom',SummaryStruct,false); 
NumberOfDaysOutOfSync = Struct2Data(SummaryStruct,'NumberOfDaysOutOfSync');
plotgraph(h,NumberOfDaysOutOfSync);
[Summary] = GetSummary(SummaryStruct);
h.Parameters = RealTimeParameter(h.Parameters,Summary);

