classdef PGin_WBS < handle & ....
                    DataSetFiltering
    properties
        DataLocation = 'C:\SourceSafe\Stocks & Shares\Programs\WhatBrokersSay\Data\'
    end
    methods
        function DATA = DecodeTable(obj,s)
            %% WHAT BROKERS SAY
            updated = true;
            try 
                %% Remove Table
                n = findstr(s,'<table border="0" cellspacing="0" width="100%" class="dl textRegular">');
                y = findstr(s,'</table>');
                table = s(n:y+8);

                %% Each Row
                start = findstr(table,'<tr>');
                endof = findstr(table,'</tr>');
                [x] = size(start,2);
                Headings = table(start(1):endof(1));
                for i = 2:x
                    ROW{i-1,1} = table(start(i):endof(i));
                end

                %% Each Column
                [x] = size(ROW,1);
                for i = 1:x
                    text = ROW{i,1};

                    %Date
                    StartString = '<td class="dataRegularUlOn dataRegularU1DateCell"><div class=''dataRegularU1DateCell''>';
                    DateStart = findstr(text,StartString);
                    DateEnd = findstr(text,'</div></td>');
                    Date = text(DateStart+size(StartString,2):DateEnd-1);
                    if isempty(Date)
                    StartString = '<td class="dataRegularUlOff dataRegularU1DateCell"><div class=''dataRegularU1DateCell''>';
                    DateStart = findstr(text,StartString);
                    DateEnd = findstr(text,'</div></td>');
                    Date = text(DateStart+size(StartString,2):DateEnd-1);           
                    end
                    Dates{i,1} = Date;

                    %CompanyName
                    StartString = '">';
                    Start = findstr(text,StartString);
                    DateEnd = findstr(text,'</td>');

                    [y] = size(DateEnd,2);
                    for j = 1:y
                        Temp{i,j} = strrep(text(Start(j+1)+2:DateEnd(j)-1),'</a>','');
                    end   
                end
                Temp = Temp(:,2:end);
                
                %Format for dataset
                CompanyName = Temp(:,1);
                Ticker = Temp(:,2);
                BrokerName = Temp(:,3);
                Recommendation = Temp(:,4);
                Price = str2double(strrep(Temp(:,5),'p',''));
                OldPriceTarget = str2double(strrep(Temp(:,6),'p',''));
                NewPriceTarget = str2double(strrep(Temp(:,7),'p',''));
                BrokersChange = Temp(:,8);
                DateNum = datenum(Dates);
                
                DATA = dataset(Dates,DateNum,CompanyName,Ticker,BrokerName,Recommendation,Price,OldPriceTarget,NewPriceTarget,BrokersChange);
            catch
                updated = false;
            end            
        end
        function [updated,NEWDATA] = SaveData(obj,DATA)
           NewEntryCount = 0;
           
           %%
           [DateNumber] = double(obj.GetColumn(DATA,'DateNum'));
           [CompanyName] = obj.GetColumn(DATA,'CompanyName');
           [Ticker] = obj.GetColumn(DATA,'Ticker');
           [DateMonth] = datenum(datestr(DateNumber,28));
           
           %%
           Dates = obj.GetDaySet(DateNumber);
           Months = obj.GetMonthSet(Dates);
           
           %%
           [x] = size(Months,2);
           %% 
           for i = 1:x %Loop over months and save data
               %%
               [OLDDATA,Error] = obj.LoadMonth(Months{i});
               
               %% Get all data from that month
               if  Error == true %Must be a new month
                   % Just save the data
                   % Filter all data from this month.
                   %%
                   n = find(DateMonth==datenum(Months{i}));
                   
                   %% Save data
                   obj.SaveMonth(Months{i},DATA(n,:));
               elseif Error == false 
               % Month already exists.
               % Need to add new data to this month.
               
                   %Filter just the months in question from the new data
                   %array.
                   %%
                   n = find(DateMonth == datenum(Months{i}));
                   NEWDATA = DATA(n,:);
                   
                   %% 
                   [x] = size(NEWDATA,1);
                   
                   %% Identify the new data       
                   for j = 1:x %first entry is the header
                       %% look for new entries
                       EntryInQuestion = NEWDATA(j,:);
                       logic(j) = obj.IsNewEntry(EntryInQuestion,OLDDATA);
                   end
                   n = find(logic==1);
                   NEWDATA = NEWDATA(n,:);
                   
                   %% Combine
                   [x] = size(n,2);
                   if isempty(n) %No new data
                       updated = false;              
                       disp([Months{i},': ',num2str(x),' new entries found']) 
                       updated = false;
                       NEWDATA = [];
                   else
                       updated = true;
                       clear DATA                       
                       DATA = [NEWDATA;OLDDATA];
%                        save(Months{i},'SaveTable')
                       disp([Months{i},': ',num2str(x),' new entries found'])
                       drawnow;
                       updated = true;
                       
                       obj.SaveMonth(Months{i},DATA)
                   end
               else
               end
           end
        end
    end
    methods (Hidden = true) %support functions
        function [Dates] = GetDaySet(obj,DateNumber)
           %% Days
           MinVal = min(DateNumber);
           MaxVal = max(DateNumber);
           
           %% Filter
           count = 1;
           for i = MinVal:MaxVal
               n = find(i == DateNumber);
               if isempty(n)
               else
                   Dates(count) = i;
                   count = count +1;
               end
           end %Filter to be left with one of each day - Dates
        end
        function [Months] = GetMonthSet(obj,Dates)
           %%
           DateMonth = datestr(Dates,28);
           
           %% Months
           count = 1;
           [x] = size(DateMonth,1);
           %%
           
           Months{count} = DateMonth(1,:);
           for i = 1:x-1
               logic = strcmpi(DateMonth(i,:),DateMonth(i+1,:));
               if logic == true 
               else
                   Months{count} = DateMonth(i+1,:);
                   count = count +1;
               end
           end %Filter to be left with one of each month.
        end
        function [DATA,Error] = LoadMonth(obj,MonthYear)
        %Example 1: Data Preset
        % [OLDDATA,Error] = obj.LoadMonth('Nov2009')
        %
        %Example 2: Data does not exist.
        % [OLDDATA,Error] = obj.LoadMonth('Oct2012')
           String = [obj.DataLocation,MonthYear,'.mat'];
           try
              load(String)
              Error = false;
           catch
              Error = true; 
              DATA = [];
           end
        end
        function SaveMonth(obj,MonthYear,DATA)
           String = [obj.DataLocation,MonthYear,'.mat'];
           save(String,'DATA');
        end
        function [logic] = IsNewEntry(obj,EntryInQuestion,OLDDATA)
           %TODO: Filter also on brokers name
           %NewEntry = Must be a datset with on row/entry
           %Data = Probaly from loaddata. Also must be a dataset
           
           %% Filter on matching dates
           [DateNumber] = double(obj.GetColumn(OLDDATA,'DateNum'));
           n = find(EntryInQuestion{1,2} == DateNumber); %Matching Dates
%            OLDDATA = OLDDATA(n,:)
                       
           %% 

           if isempty(n)
               logic = true;
               return
           else %filter for company name
               CompanyName = EntryInQuestion{1,3};
               CompanyNames = datasetfun(@cell,OLDDATA(:,3),'UniformOutput',false);
               CompanyNames = CompanyNames{1};
               n = find(strcmpi(CompanyName,CompanyNames));
               if isempty(n)
                   NewEntry = true;
               else
                   NewEntry = false;
               end
           end
           logic = NewEntry;
        end
    end
end