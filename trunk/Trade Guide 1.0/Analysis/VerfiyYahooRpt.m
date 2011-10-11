function [Output] = VerfiyYahooRpt(tablehandle)
%Calculate the number of symbols on each day.
%
%InputArray - Output from symbol information.
%Database must be intialised.
%
%Example: 
%IntialiseDatabase;
%[OutPutArray] = SymbolInformation();
%[startdateout,enddateout] = NumberOfSymbolsPerDay(MinimumThreshold,InputArray)
%
%Written by: Bryan Taylor
%Date Created: 3rd January 2008
%Date Modified: 3rd January 2008

Output = 1;

%% Get Data
%TODO: Just read data from table (Not file)
InLocalBase = GetStageData('VerfiyYahoo','InLocalBase');
TableAdded = GetStageData('VerfiyYahoo','TableAdded');
Status = GetStageData('VerfiyYahoo','Status');

%% Total Number of Saxo Instruments
TotalSize = size(InLocalBase,1);

%% Number previously in database
n = find(strcmpi(InLocalBase,'True'));
[NoPreviouslyInDatabase] = size(n,1);

%% Not in database so need to be searched on yahoo
n = find(strcmpi(InLocalBase,'False'));
[NotInLocalDatbase] = size(n,1);

%% concentrate on this subset
InLocalBase = InLocalBase(n);
TableAdded = TableAdded(n);
Status = Status(n);

%% Number searched on yahoo
%The fail symbols would then be search on yahoo.
%How many are successfull.
n = find(strcmpi(Status,'Pass'));
[NoFoundOnYahoo] = size(n,1);
p = find(strcmpi(Status,'Fail'));
NoFailedOnYahoo = size(p,1);

%% Concetrate on found symbols
InLocalBase = InLocalBase(n);
TableAdded = TableAdded(n);
Status = Status(n);

%% Number Failed to be added and added sucessfully
n = find(strcmpi(TableAdded,'True'));
[NoTablesAdded] = size(n,1);
n = find(strcmpi(TableAdded,'False'));
[NoTablesNotAdded] = size(n,1);


TotalNoInBase = NoPreviouslyInDatabase + NoTablesAdded;

%Check sum
conn2 = database('SaxoTrader','','');
[tablelist] = GetAllTableNames(conn2);
NumberCurrentInDatabase = size(tablelist,1);

if NumberCurrentInDatabase == TotalNoInBase
    Checksum = 'Pass';
else
    Checksum = 'Fail';
end
String = {  ['Total Number Of Saxo Symbols: ',num2str(TotalSize)]; ...
            ['Number of symbols previously in database: ',num2str(NoPreviouslyInDatabase),' (',num2str(NoPreviouslyInDatabase/TotalSize*100,3),'%)']; ...
            ['Total Number Of Tables added to local database: ',num2str(NoTablesAdded),' (',num2str(NoTablesAdded/TotalSize*100,3),'% Improvement)']; ...
            ['Total number now in database: ',num2str(TotalNoInBase),' (',num2str(TotalNoInBase/TotalSize*100,3),'%)']; ...
            ['Total searched on yahoo (local database failed): ',num2str(NotInLocalDatbase)]; ...  
            ['   Number Found On Yahoo: ',num2str(NoFoundOnYahoo)]; ...
            ['         Number Tables Added: ',num2str(NoTablesAdded)]; ...
            ['         Number Tables Not Added: ',num2str(NoTablesNotAdded)]; ...
            ['   Number Failed On Yahoo: ',num2str(NoFailedOnYahoo)]; ...
            ['']; ...
            ['Checksum: ',Checksum]; ...
            ['===================']; ...
            ['Number of tables in database: ',num2str(NumberCurrentInDatabase)]; ...
            ['Number this analysis assumes is in database: ',num2str(TotalNoInBase)]; ...
            ['Check sum difference: ',num2str(abs(NumberCurrentInDatabase-TotalNoInBase))]};

uiwait(msgbox(String))