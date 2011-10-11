classdef WebDecodeTrainer <     handle & ...
                                Common & ...
                                URL_Download & ...
                                Test & ...
                                WebPageDecoder
    %TODO: Auto select the Index number.
    %
    properties
        Rev_WebDecodeTrainer = 0.01;
    end
    methods (Hidden = false)
        function outStruct = Removed_IncompleteNumbers(obj,outStruct)
            %% Start
            x = size(outStruct.StartString,1);
            count = 0;
            for i = 1:x
                StartString = outStruct.StartString{i};
                EndString = outStruct.EndString{i};
                Str = StartString(end);
                Num = str2num(Str);
                if or(isempty(Num),strcmpi(Str,'.'))  %Check if string is a number
                    % If number we want to remove from possiblities
                    count = count + 1;
                    NewStartString{count,1} = StartString;
                    NewEndString{count,1} = EndString; 
                end
            end
            outStruct.EndString = NewEndString;
            outStruct.StartString = NewStartString;
            
            %% log data
%             outStruct.Removed_IncompleteNumbers.StartString.NumberRemoved = x - count;
%             outStruct.Removed_IncompleteNumbers.StartString.OrignalNumber = x;
%             outStruct.Removed_IncompleteNumbers.StartString.NewNumber = count;
            
            %% End
            x = size(outStruct.EndString,1);
            count = 0;
            for i = 1:x
                StartString = outStruct.StartString{i};                 
                EndString = outStruct.EndString{i};
                Num = str2num(EndString(1));               
                if or(isempty(Num),strcmpi(Str,'.')) %Check if string is a number
                    % If number we want to remove from possiblities
                    count = count + 1;
                    NewStartString{count,1} = StartString;
                    NewEndString{count,1} = EndString;  
                end
            end
            outStruct.EndString = NewEndString;
            outStruct.StartString = NewStartString;
%             outStruct.EndString

            %% log data
%             outStruct.Removed_IncompleteNumbers.EndString.NumberRemoved = x - count;
%             outStruct.Removed_IncompleteNumbers.EndString.OrignalNumber = x;
%             outStruct.Removed_IncompleteNumbers.EndString.NewNumber = count;
        end
        function StartString = GetStartString(obj,s,ExpectedValue)
            % Get the minmial unique start string to locate the expected
            % value. 
            % Example: 
            %   ExpectedValue = 1,223.10 %This is the string your training the program to find.
            %   Index = 2 %Thier maybe more than one instance of this string. Index = 2 means the second instance.
            %   StartString = obj.GetStartString(s,ExpectedValue,Index)
            p = findstr(ExpectedValue,s);
            if isempty(p)
                urlwrite(s,'temp.html')
                web('temp.html')
                error(['Expected String Not Found: ',ExpectedValue])
            end
            
            %
            for i = 1:max(size(p))
                firstval = p(i);
                startindex = obj.FindUniqueString(firstval,s);
                startindex = obj.CropAtCarrageReturn(startindex);
                StartString{i,1} = startindex;
            end
        end
        function EndString = GetEndString(obj,s,ExpectedValue)
            % Get the minmial unique start string to locate the expected
            % value. 
            % Example: 
            %   ExpectedValue = 1,223.10 %This is the string your training the program to find.
            %   Index = 2 %Thier maybe more than one instance of this string. Index = 2 means the second instance.
            %   EndString = obj.GetEndString(s,ExpectedValue,Index)
            p = findstr(ExpectedValue,s);
                    
            x = max(size(ExpectedValue));  
            %%
            for i = 1:max(size(p))
                firstval = p(i);
                Unique = false;
                val = 1;
                while and(Unique == false, val < 5) 
                    startindex = s(firstval+x:firstval+x+val);

                    % Is unique? 
                    n = findstr(startindex,s);
                    if max(size(n)) == 1
                       Unique = true;
                    else
                       Unique = false;  
                    end
                    val = val + 1;
                end
                startindex = obj.CropAtCarrageReturn(startindex);
                EndString{i,1} = startindex;
            end
        end
        function EndString = CropAtCarrageReturn(obj,EndString)
           %%
           CR_String = '<&CR&>';
           load('CarrageReturn');
           n = findstr(EndString,CarrageReturn);
           x = max(size(n));
           if not(isempty(n))
                EndString = strrep(EndString,CarrageReturn,CR_String);
           end
        end
        function Names = GetURLnames(obj,ProgramName)
            %%
            PWD = pwd;
            directory = [obj.InstallDir,'DecodeTrainers\',ProgramName,'\'];
            cd(directory)
            names = struct2cell(dir);
            names = names(1,:);
            
            count = 1;
            for i = 3:max(size(names))
                if isempty(findstr(names{i},'.mat'))
                else
                    Names{count,1} = strrep(names{i},'.mat','');
                    count = count + 1;
                end
            end
            
            cd(PWD)
        end
        function outStruct = CreateCommonTrainStruct(obj,inStruct)                                   
            h = waitbar(0);
            for i = 1:size(inStruct,1); %Loop over parameters
                try
                  waitbar(i/size(inStruct,1),h)
                  drawnow;
                  
                  %%
                  ParamStruct = inStruct(i,:);
                      
                  %%
                  try
                  ParamStruct2 = obj.RemoveNaN_ExpectedValues(ParamStruct);
                  catch
                      error(['No entries for : ',ParamStruct(1).Name])
                  end
                  [StartString, EndString] = obj.FindMatchingStrings(ParamStruct2);

                  %%
                  outStruct(i,1).NumberOfStringMatches = max(size(StartString));
                  if max(size(StartString)) > 1
                      warning([ParamStruct(1).Name,' has ',num2str(max(size(StartString))),' possible entries. First Enrty has been selected'])
                      
                      StartString2 = StartString{1};
                      clear StartString
                      StartString = StartString2;
                      
                      EndString2 = EndString{1};
                      clear EndString
                      EndString = EndString2;
                  end
                  
                  if iscell(StartString) == true
                      if max(size(StartString)) == 1
                          StartString = StartString{1};
                          try
                          EndString = EndString{1};
                          end
                      end
                  end 
                  
                  outStruct(i,1).Name = ParamStruct(1).Name;  
                  outStruct(i,1).Class = ParamStruct(1).Class;   
                  outStruct(i,1).StartString = StartString;
                  outStruct(i,1).EndString = EndString;
                  clear matchmatrix
                catch
                    disp(['Error combining param: ',ParamStruct(1).Name])
                end
            end          
        end
        function logic = CheckForFieldsMatch(obj,ParamStruct,FieldNames)
           y = max(size(FieldNames));
           for j = 1:y
               FieldName = FieldNames{j};
               logic = obj.CheckForFieldMatch(ParamStruct,FieldName);
               if logic == false
                    error(['No common start string was found: ',ParamStruct(1).Name])
               end
           end  
           logic = true;
        end
        function logic = CheckForFieldMatch(obj,outStruct,FieldName)
            %% 
            CELL = struct2cell(outStruct);
            y = size(outStruct,2); %Number of parameters
            
            FieldNames = fieldnames(outStruct);
            FieldNumber = find(strcmpi(FieldName,FieldNames));
            
            StartStringFirst = outStruct.(FieldName);
            %StartString is the 3rd field
            StartString = squeeze(CELL(FieldNumber,:));
            n = max(size(find(strcmpi(StartStringFirst,StartString))));
            if not(y == n)
               logic = false; 
            else
               logic = true; 
            end
        end
        function outStruct = Train_Multi(obj,ProgramName,TrainerName)
            Names = obj.GetURLnames(ProgramName);
            %%
            struct = obj.GetConfig(ProgramName,TrainerName);
            
            for i = 1:max(size(Names)) %Loop over URLs
                drawnow
                URL_Name = Names{i};  
                s = obj.GetURL(ProgramName,URL_Name);           
                outStruct(:,i) = obj.Train_Single(s,struct,URL_Name);
            end            
        end
        function outStruct = Train_Single(obj,s,struct,URLName)
            h = waitbar(0);
            for i = 1:max(size(struct))
                waitbar(i/max(size(struct)),h,struct(i).Name)
                outStruct(i).Name = struct(i).Name;
                outStruct(i).Class = struct(i).Class;
                
                try
                ExpectedValue = struct(i).(URLName).ExpectedValue;
                catch
                    URLName
                    x = 1 
                end
                if isnan(ExpectedValue) %No string available.
                    outStruct(i).StartString = NaN;
                    outStruct(i).EndString = NaN;
                else
                    try
                        outStruct(i).StartString = obj.GetStartString(s,ExpectedValue); 
                    catch
                        ExpectedValue
                        error(['Expected Value (',ExpectedValue,')not found in ',URLName])
                    end
                    outStruct(i).EndString = obj.GetEndString(s,ExpectedValue); 

                    outstructp = outStruct(i);
                    outstructp = obj.Removed_IncompleteNumbers(outstructp);
                    outStruct(i) = outstructp;
                end
            end
        end
        function LogStruct(obj,outStruct,filename)
            %%       
            Perc = '<&Per&>';
            fid = fopen(filename,'wt');
            
            Names = fieldnames(outStruct);
            
            Names = {   'Name'; ...
                        'Class'; ...
                        'StartString'; ...
                        'EndString'};
                    
            for i = 1:size(outStruct,1)
                for j = 1:max(size(Names))
                    Val = outStruct(i).(Names{j});
                    Val = strrep(Val,'''','''''');
                    string = ['struct(',num2str(i),').',Names{j},' = ''',Val,''';'];
                    
                    string = strrep(string,'%',Perc);
                    fprintf(fid,[string,'\n']);
                end
                fprintf(fid,[' ','\n']);
            end
            fprintf(fid,[' ','\n']);
        end
        function WriteTrainingLog(obj,outStruct2,filename)
            %%
            fid = fopen(filename,'wt');
            
            %%
            x = max(size(outStruct2));
            for i = 1:x
                Name = outStruct2(i).Name;
                NumberOfStringMatches = outStruct2(i).NumberOfStringMatches;
                string = [Name,': ',num2str(NumberOfStringMatches)];
                fprintf(fid,[string,'\n']);
            end
        end
        function DisplayTrainerHTML(obj,ProgramName,WEB)
            %%
            
            WEB_PATH = [obj.InstallDir,'DecodeTrainers\',ProgramName,'\',WEB];
            HTML_PATH = strrep(WEB_PATH,'.mat','.html');
            load(WEB_PATH)
            obj.DisplayHTML(s,HTML_PATH)
        end
    end
    methods (Hidden = true) 
        function obj = WebDecoderTrainer()
            obj.InstallDir = pwd;
        end
        
        %Method1 un-used
        function GetTable_Method1(obj)
            %%
            TableHeadings = ...
                    {'Name',                            'Ticker',   'Stock EX', 'Currency'};
            Table = ...
                    {'Hawk Exploration Ltd. Class A',   'HWK.A',    'TSXV',     '$C Canadian Dollars'; ...    
                     'Hawk Exploration Ltd. Class B',   'HWK.B',    'TSXV',     '$C Canadian Dollars'; ...
                     'Hawkeye Gold & Diamond Inc.',     'HGO',      'TSXV',     '$C Canadian Dollars'; ...    
                     'Hawkins Inc.',                    'HWKN',     'NASDAQ',   '$ US Dollars'; ...       
                     'Nighthawk Energy',                'HAWK',     'LSE',      'UK Pounds'};        
            
            Symbol = 'HAWK';
            Date = 734647;
            s = obj.Load(Symbol,'DigitalLook','Symbol2Num','URL',Date); 
            
            %% Find key cells
            Combined2 = [TableHeadings;Table];
            [Loc,SizeN] = obj.GetPotentialLocations(s,Combined2);
            
            %% Get Key string            
            KeyString = obj.GetKeyString(SizeN,Combined2);
            LOGIC = obj.BeforeOrAfter(Combined2,KeyString);
            
            %%
            Loc2 = obj.GetLocations(Combined2,KeyString,LOGIC,Loc)
            Strings = obj.FindMultipleEntries(Combined2)
            
            %% Get string between
            [x,y] = size(Loc2);
            
            Row = [1,2];
            
            for j = 1:y-1
                Row = [j,j+1];
                for i = 1:x
                    nstring{i,j} = obj.GetSeparatorRow(s,Combined2,Loc2,i,Row)
                end
            end
            startindex = obj.FindUniqueString(Loc2{1,1},s)
            
            %%
            s(Loc2{1,1}-200:Loc2{1,1}+90)
        end
        function Strings = FindMultipleEntries(obj,Combined2)
            %%   
            [x,y] = size(Combined2);
            Strings = [];
            for i = 1:x
                for j = 1:y
                    val = Combined2{i,j};
                    n = find(strcmpi(Combined2,val));
                    if max(size(n)) > 1
                        n = find(strcmpi(Strings,val))
                        if max(size(n)) == 0
                        Strings = [Strings;{val}];
                        end
                    end
                end
            end
        end
        function string = GetSeparatorRow(obj,s,Combined2,Loc2,LineNum,Row)
            n1 = Loc2{LineNum,Row(1)};
            n2 = Loc2{LineNum,Row(2)};
            string = s(n1:n2-1);
            cell = Combined2{LineNum,Row(1)};
            string = strrep(string,cell,'');            
        end
        function Loc2 = GetLocations(obj,Combined,KeyString,LOGIC,Loc)
            
            [i,j] = find(strcmpi(Combined,KeyString));
            Location = Loc{i,j}; 
            [x,y] = size(LOGIC);
            for i = 1:x
                for j = 1:y
                    Locations = Loc{i,j};
                    switch lower(LOGIC{i,j})
                        case 'before'
                            n = find(Locations < Location);
                            Locations = Locations(n);
                            Loc2{i,j} = Locations(end);
                        case 'after'
                            n = find(Locations > Location);
                            Locations = Locations(n);
                            Loc2{i,j} = Locations(1);
                        case 'n/a'
                            Loc2{i,j} = Location;
                        otherwise
                    end
                end
            end        
        end
        function LOGIC = BeforeOrAfter(obj,Combined,KeyString)
            [i,j] = find(strcmpi(Combined,KeyString));
            [x,y] = size(Combined);
            for p = 1:x
                for n = 1:y
                    if p < i
                        LOGIC{p,n} = 'Before';
                    elseif p == i
                        if n < j
                            LOGIC{p,n} = 'Before';
                        elseif n == j
                            LOGIC{p,n} = 'N/A';
                        else
                            LOGIC{p,n} = 'After';
                        end
                    else
                        LOGIC{p,n} = 'After';
                    end
                end
            end            
        end
        function KeyString = GetKeyString(obj,SizeN,Combined)
            [i,j] = find(SizeN == 1);
            val = 1;
            KeyString = Combined{i(val),j(val)};          
        end
        function [Loc,SizeN] = GetPotentialLocations(obj,s,Combined)
            %%
            [x,y] = size(Combined);
            count = 0;
            for i = 1:x
                for j = 1:y
                    n1 = findstr(s,Combined{i,j});
                    Loc{i,j} = n1;
                    SizeN(i,j) = max(size(n1));
                    if SizeN(i,j) == 1
                       count = count + 1; 
                    end
                    n{i,j} = n1;
                end
            end
            disp([num2str(count),' occurences of individual strings found'])            
        end
        %Method end
        
        function outParamStruct = RemoveNaN_ExpectedValues(obj,ParamStruct)
            x = max(size(ParamStruct));
            count = 1;
            for i = 1:x
                if not(iscell(ParamStruct(i).StartString)) %not a cell
                    if isnan(ParamStruct(i).StartString) %is nan
                        % do nothing
                    else
                        outParamStruct(count) = ParamStruct(i);
                        count = count + 1;                        
                    end
                else %iscell
                    outParamStruct(count) = ParamStruct(i);
                    count = count + 1;
                end
            end
        end
        function startindex = FindUniqueString(obj,firstval,s)
                Unique = false;
                val = 1;
                while Unique == false
                    startindex = s(firstval - 1 - val:firstval-1);

                    % Is unique? 
                    n = findstr(startindex,s);
                    if max(size(n)) == 1
                       Unique = true;
                    else
                       Unique = false;  
                    end
                    val = val + 1;
                end
        end        
        function [StartString, EndString] = FindMatchingStrings(obj,ParamStruct)
              %% Find matching start strings and end strings
              Starts = ParamStruct(1).StartString; 
              
              x = size(Starts,1);
              y = max(size(ParamStruct));
              if y == 1 %Single valid term.
                  StartString = ParamStruct(1).StartString; 
                  EndString = ParamStruct(1).EndString;  
                  return
              end
              for j = 1:x
                  for p = 2:y
                      StartString = ParamStruct(p).StartString;  
                      n = find(strcmpi(Starts{j},StartString));
                      if isempty(n)
                          matchmatrix(j,p-1) = NaN;
                      else
                          matchmatrix(j,p-1) = n(1);
                      end
                  end
              end

              %
              matchmatrixsum = sum(matchmatrix,2);
              n = find(isnan(matchmatrixsum)==0);
              if isempty(n)
                  StartString = 'N/A';
                  EndString = 'N/A';                         
              else
                  StartString = ParamStruct(1).StartString(n); 
                  EndString = ParamStruct(1).EndString(n);
              end      
              
              %% Get End Strings Array
              try
                  for i = 1:max(size(ParamStruct))
                      EndString(i) = ParamStruct(i).EndString;
                  end
                  if max(size(EndString)) == max(size(find(strcmpi(EndString{1},EndString))))
                      disp('All strings match')
                      EndString = EndString{1};
                      return
                  else
                      NoOfStrings = max(size(EndString{1}))
                      Same = false
                      while Same == false
                          for i = 1:max(size(EndString))
                              temp = EndString{i};
                              EndString{i} = temp(1:NoOfStrings-1);
                          end
                          if max(size(EndString)) == max(size(find(strcmpi(EndString{1},EndString))))
                              Same = true;
                          else
                              NoOfStrings = NoOfStrings - 1;
                          end  
                      end
                      EndString = EndString{1};
                  end
              end
        end
    end
end