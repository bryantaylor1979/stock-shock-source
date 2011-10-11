classdef VerifyYahoo
    properties
        ColumnNames = { 'Yahoo Symbol'; ...
                        'SymbolUnknown'; ...
                        'InLocalBase'; ...
                        'Status'; ...
                        'TableAdded'; ...
                        };
        Config = false;
    end
    methods 
        function [Output] = Process(varargin)
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

            global h

            %% Functional
            [OutPutArray] = GetStageData('ImportInstruments');
            try
            conn = yahoo;
            catch
            uiwait(msgbox('Can''t connect to yahoo. Please check connection'));
            Output = -1;
            return
            end
            conn2 = database('SaxoTrader','','');
            try
            [tablelist] = GetAllTableNames(conn2);
            catch %table list empty
            tablelist = {''}; 
            end
            profile = '(datenum NUMBER PRIMARY KEY, close NUMBER, open NUMBER, low NUMBER, high NUMBER, volume NUMBER, closeadj NUMBER)';

            [x] = size(OutPutArray,1);
            % StatusBar(h.statusbar,0);
            h1 = waitbar(0);
            for j = 1:x
                  waitbar(j/x,h1,['Processing ',num2str(j),' of ',num2str(x)]);
                  set(h.Status,'String',['Processing... ',num2str(j),' of ',num2str(x),' (',num2str(round(j/x*100)),'%)']);
                  TradeStructure(j).YahooSymbol =  OutPutArray{j,9};
                  if not(strcmpi(OutPutArray{j,9},'N/A')) %if N/A suffix not found in last stage.
                      SymbolUnknown = 'False';
                      n = find(strcmpi(OutPutArray{j,10},tablelist));
                      if not(isempty(n))
                          InLocalBase = 'True';
                          Status = 'N/A'; 
                          Added = 'N/A';
                      else
                          InLocalBase = 'False';
                          try
                          D = fetch(conn,OutPutArray{j,9},'open',today-365,today,'m');
                          clear D
                          Status = 'Pass'; 
                          try
                            CreateTable(conn2,OutPutArray{j,10},profile);
                            Added = 'True';
                            catch
                            Added = 'False';    
                            end
                          catch
                            Status = 'Fail';  
                            Added = 'False'; 
                          end 
                      end
                  else
                      SymbolUnknown = 'True';
                      InLocalBase = 'N/A';
                      Status = 'N/A'; 
                      Added = 'N/A';
                  end
                  TradeStructure(j).SymbolUnknown = SymbolUnknown;
                  TradeStructure(j).InLocalBase = InLocalBase;
                  TradeStructure(j).Status = Status;
                  TradeStructure(j).TableAdded = Added;
            %       AddRow(RowInfo);
                  clear RowInfo   
            end
            close(h1);
            LoadStruct(h,TradeStructure);
            close(conn2);
            set(h.Status,'String',['100% Complete']);
            Output = 1;
        end
        function [Output] = Report(tablehandle)
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
        end
    end
end