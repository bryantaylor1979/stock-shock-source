function [] = AutoTrade(obj,event,handles)
%
%Written by:    Bryan Taylor
%Date Created:  22nd April 2008
%Date Modified: 22nd April 2008

global h

%% Start Control
str = { 'Wait until midnight'; ...
        'Start Now'};
[s,v] = listdlg('PromptString','Select a file:',...
                'SelectionMode','single',...
                'ListString',str);
if s == 2        
elseif s == 1
    str = ['|/-\'];
    nowdate = today;
    todaydate = today;
    i = 0;
    while nowdate == todaydate
        i = i + 1;
        f = rem(i,4);
        todaydate = today;
        pause(2);
        set(h.Status,'String',['Waiting: ',str(f+1)]);
    end 
    set(h.Status,'String',['Ready']);
else
end

%% Select Number of download interations
prompt = {'Enter No Of Download Interations:'};
dlg_title = 'Input for AutoTrade function';
num_lines = 1;
def = {'2'};
answer = inputdlg(prompt,dlg_title,num_lines,def);
answer = str2num(answer{1});
drawnow;

%% Set Mode to Download
[functions] = StageDeclaration();
Stage = find(strcmpi(functions,'Download_Mat'));
set(h.Stage.pulldown,'Value',Stage);

%% Download
tic
Path = ['C:\SourceSafe\Stocks & Shares\Programs\Trade Guide\SaveData\AutoTrade\',num2str(today),'\'];
try
    mkdir(Path)    
end
State = get(obj,'State');
Names = Download_MatFcn('ColumnNames');
IntialiseTable(Names);
set(h.table,'Data',[]);

DCP = true;
if DCP == false
    Download_MatFcn(h);
    %Table to xls
    Data = get(h.table,'Data');
    NoUpToDate(1) = size(find(strcmpi(Data(:,6),'UpToDate')),1);
    save([Path,'Download_Mat',strrep(num2str(now),'.','_')],'Data');

    for i = 2:answer
            % Analysis
            Symbols = Data(:,1);
            Status = Data(:,6);
            n = find(not(strcmpi(Status,'UpToDate'))); %not up to date index's
            Symbols = Symbols(n);

            set(h.table,'Data',[]);

            Download_MatFcn(h,Symbols);
            %Table to xls
            Data = get(h.table,'Data');
            NoUpToDate(i) = NoUpToDate(i-1) + size(find(strcmpi(Data(:,6),'UpToDate')),1); %accumulate
            save([Path,'Download_Mat',strrep(num2str(now),'.','_')],'Data');
    end
    Data = get(h.table,'Data');
    NoUpToDate(1) = size(find(strcmpi(Data(:,6),'UpToDate')),1); %accumulate
    save([Path,'Download_Mat',strrep(num2str(now),'.','_')],'Data');
    h1 = figure;
    plot(NoUpToDate);
    title('Number Of Symbols UpToDate');
    xlabel('Session');
    ylabel('No Of Symbols');
    set(h1,'NumberTitle','off');
    set(h1,'Name','Number UpToDate');
else
    [Symbols] = GetAllTableNamesMat(); 
    handle = Master;
    Complete = 1;
    [x] = size(Symbols,1);
    slavechunksize = 50;
    i = 1;
    while i<x
        set(h.Status,'String',['Processing... ',num2str(i),' of ',num2str(x),' (',num2str(round(i/x*100)),'%)']);
        drawnow;
        if i>x-10
        Set1 = Symbols(i:x);   
        else
        Set1 = Symbols(i:i+19);
        end
        [Complete] = CheckComplete(handle);
        if Complete == -1 %Not complete - Busy
           Download_MatFcn(1,Symbols(i));
        elseif Complete == 1
           disp('Slave complete send new command')
           if i>x-slavechunksize
           Set1 = Symbols(i:x);   
           else
           Set1 = Symbols(i:i+slavechunksize-1);
           end
           SendCommand(handle,'Download_MatFcn',1,Set1); %
           i = i + slavechunksize;
        else 
        end
        i = i + 1;
    end
    set(h.Status,'String','Processing... 100% Complete');
end
DownloadTime = toc;

%% Calculate Parameters
tic
Names = CalculateParameters_MatFcn('ColumnNames');
IntialiseTable(Names);
set(h.table,'Data',[]);

%% DCP
path = 'C:\SourceSafe\Stocks & Shares\Programs\Trade Guide\SaveData\Download_Mat\Database\';
cd(path);
filenames = dir;
filenames = struct2data(filenames,'name');
filenames = strrep(filenames,'.mat','');
[x] = size(filenames,1);
Symbols = filenames(3:x);

Complete = 1;
[x] = size(Symbols,1);
slavechunksize = 50;
i = 1;
while i<x
    set(h.Status,'String',['Processing... ',num2str(i),' of ',num2str(x),' (',num2str(round(i/x*100)),'%)']);
    drawnow;
    if i>x-10
    Set1 = Symbols(i:x);   
    else
    Set1 = Symbols(i:i+19);
    end
    [Complete] = CheckComplete(handle);
    if Complete == -1 %Not complete - Busy
       CalculateParameters_MatFcn(1,Symbols(i));
    elseif Complete == 1
       disp('Slave complete send new command')
       if i>x-slavechunksize
       Set1 = Symbols(i:x);   
       else
       Set1 = Symbols(i:i+slavechunksize-1);
       end
       SendCommand(handle,'CalculateParameters_MatFcn',1,Set1); %
       i = i + slavechunksize;
    else 
    end
    i = i + 1;
end
set(h.Status,'String','Processing... 100% Complete');
    
CalculateParameters_MatFcn(h);
Data = get(h.table,'Data');
save([Path,'CalculateParameters_MatFcn',strrep(num2str(now),'.','_')],'Data');
CalculateParameters = toc;

%% Date Range 
%(This could be taken from download instead, it now has a date range)
%% range
tic
Names = DateRange_MatFcn('ColumnNames');
IntialiseTable(Names);
set(h.table,'Data',[]);
output = DateRange_MatFcn(h);
Data = get(h.table,'Data');
save([Path,'DateRange_Mat_',strrep(num2str(now),'.','_')],'Data');
DateRange = toc;

%% Day Best Investments
tic
Names = DayBestInvestments_MatFcn('ColumnNames');
IntialiseTable(Names);
set(h.table,'Data',[]);
output = DayBestInvestments_MatFcn(h);
Data = get(h.table,'Data');
save(['DayBestInvestments_',strrep(num2str(now),'.','_')],'Data');
DayBestInvestments = toc;

%% plot
h1 = figure;
pie([DownloadTime,CalculateParameters,DateRange,DayBestInvestments],{'DownloadTime','CalculateParameters','DateRange','DayBestInvestments'});
Total = sum([DownloadTime,CalculateParameters,DateRange,DayBestInvestments]);

Mins = floor(Total/60);
Hours = floor(Mins/60); %complete
Minutes = Mins - Hours*60; %complete
Seconds = Total - Minutes*60 - Hours*60*60;

String = {  ['Total Elapsed Time: ',num2str(Hours,2),'h ',num2str(Minutes,2),'m ',num2str(Seconds,2),'s']; ...
            ['Time Finished: ',datestr(now,13)]; ...
         };
title(String)
saveas(h1,[Path,'ComputationTimePieChart.fig']);

