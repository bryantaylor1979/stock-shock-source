classdef PGin_BB_Hist < handle & ...
                        ResultsLog & ...
                        DataSetFiltering & ...
                        HeartBeatMonitor
                    %TODO: Don't seem to using current evvent? Perhaps have
                    %all in one dataset and save. 
    properties
        InstallDir = 'C:\SourceSafe\Stocks & Shares\Programs\BritishBulls\';
    end
    methods
        function URL2Table_ALL(obj,Symbols,Src_Path,Dest_Path)
                %% Load Objects
                %Verfied - The symbols 
                [x] = size(Symbols,1);
                tic
                first = true;
                for j = 1:x
                      disp(['Processing... ',num2str(j),' of ',num2str(x),' (',num2str(round(j/x*100)),'%)'])

                      Symbol = strrep(Symbols{j},'.L','');
                      Symbol = strrep(Symbol,'.','_');
                      
                      [s, Error] = obj.LoadFile(Src_Path,Symbol);
                      try
                        DataSet = obj.URL2Table2(Symbol,s);
                        Error = obj.SaveDat(Dest_Path,Symbol,DataSet);
                        if Error == -1
                           warning(['Unable to save the result: ',Symbol]) 
                        end
                      catch
                        warning(['Unable to decode symbol: ',Symbol])
                      end
                end        
        end
        function CE_DataSet = Hist_URL2Data_Sync(obj,Symbols,Path)
                %Get last URL downloaded
                %
                %
                %Written by: Bryan Taylor
                %Date Created: 3rd January 2008
                %Date Modified: 3rd January 2008
                UpdateRate = 30;
                
                disp(['Executed: ',datestr(now)])

                %% Load Objects
                %Verfied - The symbols 
                [x] = size(Symbols,1);
                tic
                first = true;
                h = waitbar(0);
                for j = 1:x
                      waitbar(j/x,h,['Processing... ',num2str(j),' of ',num2str(x),' (',num2str(round(j/x*100)),'%)'])
                      drawnow;
                      if rem(j,UpdateRate) == 0
                          try
                            obj.HeartBeat('WebPageDecoder',MacroName,Date);
                            disp(['URL Download: Tracker downloaded']) 
                          catch
                            disp('Schedular entry not found') 
                          end
                      end
                      

                      Symbol = strrep(Symbols{j},'.L','');
                      Symbol = strrep(Symbol,'.','_');
                      
                      %[s, Error] = obj.LoadResult_Type(ProgramName,ResultName,Symbol,DateNum,'URL');
                      [s, Error] = obj.LoadFile(Path,Symbol)
                      %
                      if Error == 0
                          try
                              DataSet = obj.URL2Table(Symbol,s);
                              N_CE_DataSet = obj.GetCurrentEvent(Symbol,s);
                              if first == true
                                  CE_DataSet = N_CE_DataSet;
                                  first = false;
                              else
                                  CE_DataSet = [CE_DataSet;N_CE_DataSet];
                              end
                              obj.SyncData('Data',Symbol,DataSet); 
                              disp(['Symbol: ',Symbol,' Success'])
                          catch
                              disp(['Symbol: ',Symbol,' Failed'])
                          end
                      end
                end
                close(h)
        end
        function [Error] = SyncData(obj,Folder,Symbol,DataSet1)
        % Folder:
        %   'Data'          Downloaded Historical Tables
        %   'Expanded'      Downloaded Historical Tables expanded with
        %                   complete signal list
        %
        % Error codes:
        %    0 : Successfull
        %   -1 : Error writing to file. Check permissions
        OverwriteIFuptoDate = true;
        
            %Load previous data
            [DataSet2, Error] = obj.LoadData(Folder,Symbol);
            
            %First time save can't find other
            if Error == -1
                Error = obj.SaveDat(Folder,Symbol,DataSet1);
                return
            end
            
%             %% Data is old type overwrite: This could be removed at a late
%             %% date
%             if iscell(Table)
%                 Table = Array;
%                 try
%                     save(PATH,'Table');
%                     Error = 0;
%                 catch
%                     Error = -1;    
%                 end                
%                 return 
%             end
            [DataSet,Error] = obj.CombineHistTables(DataSet1,DataSet2);
            
            if or(or(Error == -1,Error == -2),Error == -3)
                %The data is the same. No need to save new table. 
                if OverwriteIFuptoDate == true
                   Error = obj.SaveDat(Folder,Symbol,DataSet);
                end
                Error = 0;
            elseif Error == 0
                %Save the new combine array. 
                Error = obj.SaveDat(Folder,Symbol,DataSet);
            else
                error('Error state not recognised') 
            end
        end
        function DataSet = GetCurrentEvent(obj,Symbol,s)
            try
                %% Current Event
                n = findstr(s,'<font size="6" color="RED" valign="top">');
                CE_Signal = 'SELL';
                if isempty(n)
                    n = findstr(s,'<font size="6" color="GREEN" valign="top">');
                    CE_Signal = 'BUY';
                end

                %
                String = s(n:n+100);
                n = findstr(String,[CE_Signal,'-IF']);
                if not(isempty(n))
                    CE_Signal = [CE_Signal,'-IF'];
                end
                Signal = {CE_Signal};

                %% Last Updated
                startstr = '<td width="94" align="right" valign="middle"><strong><font color="white" size="2">';
                n = findstr(s,startstr);
                DateNum = datenum(s((n+size(startstr,2)):(n+size(startstr,2)+30)),'dd/mm/yyyy');


                %% Create Table
                Symbol = {Symbol};
                DataSet = dataset(Symbol,DateNum,Signal);
                Error = 0;     
            catch
                DateNum = NaN;
                CurrentPrice = NaN;
                Signal = {'N/A'};
                ConfSignal = {'N/A'};
                Money = NaN;
                Symbol = {Symbol};
                DataSet = dataset(Symbol,Date,Signal);
            end
        end
        function [Array, Error] = LoadData(obj,Folder,Symbol)
        %Error:
        %   0:  Normal Operation
        %  -1:  Could not find file
            try
                PATH = [obj.InstallDir,Folder,'\',Symbol];
                load(PATH);
                Error = 0;
%                 disp('Data preset');
            catch
                Error = -1;
                Array = [];
%                 disp('No data preset');
                return
            end
            Array = Table; 
        end
        function Error = SaveDat(obj,Folder,Symbol,DataSet)
            Table = DataSet;
            PATH = [Folder,'\',Symbol];
            try
                save(PATH,'Table');
                Error = 0;
            catch
                Error = -1;    
            end
        end
        function [DataSet,Error] = CombineHistTables(obj,DataSet1,DataSet2)
            %Error:
            %    0      The data combined sucessfully
            %   -1      The data is the same
            %   -2      Data loaded is old type cell.
            %   -3      DataSet2 is empty
            Error = 0;
            
            %% Data is up to date
            if isempty(DataSet2)
                Error = -3;
                DataSet = DataSet1;
                return                 
            end
            CS1 = sum(obj.GetColumn(DataSet1,'CurrentPrice'));
            if iscell(DataSet2)
                disp('Saved data up to date')
                Error = -2;
                DataSet = DataSet1;
                return                
            else
                CS2 = sum(obj.GetColumn(DataSet2,'CurrentPrice'));
            end
            
            
            %%
            if CS1 == CS2
                disp('Saved data up to date')
                Error = -1;
                DataSet = DataSet1;
                return
            end
            
            %% Data is not up to date
            Columns = { 'Symbol', ...
                        'Date', ...
                        'CurrentPrice', ...
                        'Signal', ...
                        'ConfSignal', ...
                        'Money'};
            DataSet1 = obj.ColumnFiltering(DataSet1,Columns);
            DataSet2 = obj.ColumnFiltering(DataSet2,Columns);
            
            All = [DataSet1;DataSet2];
            DateNum = datenum(datenum(obj.GetColumn(All,'Date')));
            
            All = [dataset(DateNum),All];
            All = sortrows(All,'DateNum');
            
            %Remove double entries
            DateNum = obj.GetColumn(All,'DateNum');
            x = size(All,1);
            n = 1;
            for i  = 2:x
                if not(DateNum(i) == DateNum(i-1))
                    n = [n,i];
                end
            end
            DataSet = All(n,:);            
        end  
    end
end