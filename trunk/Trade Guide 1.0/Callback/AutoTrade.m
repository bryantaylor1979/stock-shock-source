function [] = AutoTrade(obj,event,handles)
%
%Written by:    Bryan Taylor
%Date Created:  22nd April 2008
%Date Modified: 22nd April 2008

global h savecriteria

%% Set Mode to Download
[functions] = StageDeclaration();
Stage = find(strcmpi(functions,'Download'));
set(h.Stage.pulldown,'Value',Stage);

%% Download
State = get(obj,'State');
for i = 1:3
%     while or(strcmpi(State,['o';'n']),strcmpi(State,'on')) 
        % Analysis
        Names = DownloadFcn('ColumnNames');
        IntialiseTable(Names);
        DownloadFcn(handles);

        %Table to xls
        Data = get(h.table,'Data');
        save(['Download_',strrep(num2str(now),'.','_')],'Data');

        State = get(obj,'State');
%     end
end

%% Date Range
Names = DateRangeFcn('ColumnNames');
IntialiseTable(Names);
DateRange(handles);

%Table to xls
Data = get(h.table,'Data');
save(['DateRange_',strrep(num2str(now),'.','_')],'Data');

%% No Of Symbols Per Day
Names = NoOfSymbolsPerDayFcn('ColumnNames');
IntialiseTable(Names);
output = NoOfSymbolsPerDay(handles);

%Table to xls
Data = get(h.table,'Data');
save(['NoOfSymbolsPerDay_',strrep(num2str(now),'.','_')],'Data');

StockCalculator


%% Save Information
GuiStruct(Stage).tabledata = get(h.table,'Data');
GuiStruct(Stage).stagename = functions{Stage};
GuiStruct(Stage).output = output;
savecriteria.GuiStruct = GuiStruct;
savecriteria.stage = Stage;
savecriteria.currentstagename = functions{Stage}; 