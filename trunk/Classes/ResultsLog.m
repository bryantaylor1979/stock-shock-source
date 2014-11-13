classdef ResultsLog < handle
    properties
        AddSubPaths = false
        ResultsDir = 'P:\StockData [MEDIAPC]\';
    end
    methods %Save Data
        function SaveDataSet(obj,DataSet,ProgramName,ResultName,Date)
            PWD = pwd;
            Path = fullfile(obj.ResultsDir,ProgramName,'Results',ResultName,'DataSet');
            try
                cd(Path);
            catch
                mkdir(Path);
                cd(Path);
            end
            Filename = fullfile(Path,[datestr(Date),'.mat']);
            save(Filename,'DataSet');
            cd(PWD);            
        end 
        function SaveResult_Type(obj,s,Symbol,ProgramName,ResultName,Type,Date)
            PWD = pwd;
            if obj.AddSubPaths == true
                Path = fullfile(obj.ResultsDir,ProgramName,'Results',ResultName,Type,datestr(Date));
            else
                Path = obj.ResultsDir;
            end
            try
                cd(Path);
            catch
                mkdir(Path);
                cd(Path);
            end
            Filename = fullfile(Path,[Symbol,'.mat']);
            save(Filename,'s');
            cd(PWD);            
        end 
    end
    methods %Load Data
        function [DataSet,DateNum] = LoadLastResult(obj,Program,Macro,DateNum)
            DateNum = obj.GetLastDateOfResult(Program,Macro,DateNum);
            DataSet = obj.LoadResult(Program,Macro,DateNum);
        end 
        function [DataSet, Error] = LoadResult(obj,Program,Macro,DateNum,Type)
            % Example:
            %   [DataSet, Error] = obj.LoadResult(Program,Macro,DateNum,Type)
            
            %Error:
            %   0 - Normal operation
            %  -1 - Could not load file
            Datestr = datestr(DateNum);
            Datestr = strrep(Datestr,':','_');
            FileName = fullfile(obj.ResultsDir,Program,'Results',Macro,Type,[Datestr,'.mat'])
            try
                load(FileName); 
                Error = 0;
            catch
                DataSet = [];
                disp(FileName)
                Error = -1; 
            end
            if exist('DATASET') == 1
                DataSet = DATASET;
            end
            if exist('BB_DATASET') == 1
                DataSet = BB_DATASET;
            end
            if isempty(DataSet)
                disp(FileName)
            end
        end 
        function [s, Error] = LoadResult_Type(obj,Program,Macro,Symbol,DateNum,Type)
            % Example:
            %   [DataSet, Error] = obj.LoadResult(Program,Macro,DateNum,Type)
            
            %Error:
            %   0 - Normal operation
            %  -1 - Could not load file
            Datestr = datestr(DateNum);
            Datestr = strrep(Datestr,':','_');
            FileName = fullfile(obj.ResultsDir,Program,'Results',Macro,Type,Datestr);
            [s, Error] = obj.LoadFile(FileName,Symbol);
        end  
        function [s, Error] = LoadFile(obj,Path,Symbol)
            FileName = fullfile(Path,[Symbol,'.mat']);
            try
                load(FileName); 
                Error = 0;
            catch
                s = [];
                disp(FileName)
                Error = -1; 
            end            
        end
        function [DataSet, DateNum, Error] = LoadLastWorkingDaysResult(obj,Program,Macro)
             %%
             switch datestr(today,8)
                 case {'Tue','Wed','Thu','Fri','Sat'}
                     DateNum = today - 1;
                 case 'Mon'
                     DateNum = today - 3;
                 case 'Sun'
                     Datenum = today - 2;
                 otherwise
             end
             %%
             try
                 DataSet = obj.LoadResult(Program,Macro,DateNum);
                 Error = 0;
             catch
                 DataSet = [];
                 DateNum = [];
                 Error = -1;
             end
        end
    end
    methods %Get Info
        function DateNum = GetLastDateNum(obj,Program,Macro,Type)
            DateNum = max(obj.GetResultDateNums(Program,Macro,Type));
        end
        function DateNums = GetURL_ResultDateNums(obj,Program,Macro)
            FileName = [obj.ResultsDir,Program,'\Results\',Macro,'\URL\'];
            CD = pwd;
            cd(FileName);
            names = struct2cell(dir);
            Name = rot90(strrep(names(1,:,:),'.mat',''));
            DateNums = datenum(Name(1:end-2));
            cd(CD);           
        end
        function [Max,Min] = Results_DateRange(obj,Program,Macro)
            CD = pwd;
            Directory = [obj.ResultsDir,Program,'\Results\',Macro,'\DataSet\'];
            cd(Directory)
            filenames = struct2cell(dir);
            Names = filenames(1,:,:);
            DateNum = datenum(strrep(Names(3:end-1),'.mat',''));
            Max = max(DateNum);
            Min = min(DateNum);
            cd(CD)
        end
        function [Max,Min] = Query_DateRange(obj,QueryName)
            CD = pwd;
            Directory = [obj.ResultsDir,'QuoteAbstractionLayer\Results\',QueryName,'\DataSet\'];
            cd(Directory)
            filenames = struct2cell(dir);
            Names = filenames(1,:,:);
            DateNum = datenum(strrep(Names(3:end-1),'.mat',''));
            Max = max(DateNum);
            Min = min(DateNum);
            cd(CD)
        end        
        function DateNum = GetLastDateOfResult(obj,Program,Macro,DateNum)
            FileName = [obj.ResultsDir,Program,'\Results\',Macro,'\DataSet\'];
            CD = pwd;
            cd(FileName);
            names = struct2cell(dir);
            Name = rot90(strrep(names(1,:,:),'.mat',''));
            
            DateNums = datenum(Name(1:end-2));
            n = find(DateNums <= DateNum);
            DateNums = DateNums(n);
            
            DateNum = max(DateNums);
            cd(CD);
        end 
        function struct = ResultsFolderDurationInfo(obj,ProgramName,MarcoName,Type,Date)
            %%
            Path = [obj.ResultsDir,ProgramName,'\Results\',MarcoName,'\',Type,'\',datestr(Date),'\'];
            PWD = pwd;
            cd(Path)
            
            names = dir;
            names = rot90(struct2cell(names),3);
            dateStr = names(3:end,1);
            dateNum = cell2mat(dateStr);
            
            struct.StartTime = datestr(min(dateNum),'HH:MM:SS');
            struct.EndTime = datestr(max(dateNum),'HH:MM:SS');
            struct.Duration = datestr(max(dateNum)-min(dateNum),'HH:MM:SS');
            struct.NumberOfEntries = max(size(dateNum));
            
            cd(PWD);
        end
        function [DateNum, error] = GetResultDateNums(obj,ProgramName,ResultName,Type)
            %%
            ResultsDir = [obj.ResultsDir,ProgramName,'\Results\',ResultName,'\',Type,'\'];
            [DateNum,error] = obj.GetFileNames(ResultsDir);
            
            %%
            DateNum = strrep(DateNum,'_','-');
            DateNum = strrep(DateNum,'.xls','');
%             DateNum = strrep(DateNum,'-',':');
            
            %%
            DateNum = datenum(DateNum);
        end
        function DATASET = CompareFolders(obj,Program,Macro)
            Types = obj.GetTypes(Program,Macro);
            x = size(Types,1);
            for i = 1:x
                Dates.(Types{i}) = obj.GetDates(Program,Macro,Types{i});
            end
            DatesNum = obj.combinedates(Dates);
            
            y = size(DatesNum,1);
            for i = 1:y
                Date = DatesNum(i);
                for j = 1:x
                     Type = Types{j};
                     DatesT = Dates.(Type);
                     if isempty(find(DatesT == Date))
                         ARRAY{i,j} = 'false';
                     else
                         ARRAY{i,j} = 'true';
                     end
                end
            end
            string = [];
            for j = 1:x
                Type = Types{j};
                param = ARRAY(:,j);
                eval([Type,' = param;'])
                string = [',',Type,string];
            end 
            DateStr = datestr(DatesNum);
            eval(['DATASET = dataset(DateStr,DatesNum',string,');']);
        end
        function Types = GetTypes(obj,Program,Macro)
             PWD =pwd;
             
             Path = [obj.ResultsDir,Program,'\Results\',Macro,'\']; 
             cd(Path);
             names = dir;
             names = rot90(struct2cell(names));
             Types = names(1:end-2,1);
             n = find(cell2mat(names(1:end-2,4)) == 1);
             Types = Types(n);
             
             cd(PWD);
        end
        function Dates = GetDates(obj,Program,Macro,Type)
             PWD =pwd;        
             Path = [obj.ResultsDir,Program,'\Results\',Macro,'\',Type];
             cd(Path)
             names = dir;
             names = rot90(struct2cell(names));
             warning off
             Dates = datenum(names(1:end-2,1));    
             warning on
             cd(PWD);
        end
        function Symbols = GetSavedSymbolsFromPath(obj,Path)
            PWD = pwd;
            cd(Path);
            cells = rot90(struct2cell(dir),3);
            Symbols = strrep(cells(3:end,end),'.mat','');
            cd(PWD)  
        end
        function Symbols = GetSaveURL_Symbols(obj,ProgramName,MacroName,date)
            %%
            error('This function is now obselete. please use GetSaveType_Symbols')
            if obj.AddSubPaths == true
                Path = [obj.ResultsDir,ProgramName,'\Results\',MacroName,'\URL\',datestr(date),'\'];
            else
                Path = obj.ResultsDir;
            end
            Symbols = obj.GetSavedSymbolsFromPath(Path);
        end
        function Symbols = GetSaveType_Symbols(obj,Type,ProgramName,MacroName,date)
            %%
            PWD = pwd;
            if obj.AddSubPaths == true
                Path = [obj.ResultsDir,ProgramName,'\Results\',MacroName,'\',Type,'\',datestr(date),'\'];
            else
                Path = obj.ResultsDir;
            end
            cd(Path);
            cells = rot90(struct2cell(dir),3);
            Symbols = strrep(cells(3:end,end),'.mat','');
            cd(PWD)            
        end
    end
    methods %display result
        function DisplayHTML(obj,s,HTML_PATH)
            fid = fopen(HTML_PATH,'wt');
            fprintf(fid,'%c',s)
            web(HTML_PATH)
        end
    end
    methods (Hidden = true)
        function DATES2 = combinedates(obj,struct)
            Types = fieldnames(struct);
            x = size(Types,1);
            for i = 1:x
                N_DATES = struct.(Types{i});
                if i == 1
                    DATES = N_DATES;
                else
                    DATES = [N_DATES;DATES];
                end
                if isempty(DATES)
                else
                    DATES = sort(DATES);
                    x = size(DATES,1);
                    DATES2 = DATES(1);
                    for i = 2:x
                       if DATES(i-1) == DATES(i);
                       else
                          DATES2 = [DATES2;DATES(i)];
                       end
                    end
                end
            end
        end
        function [FileNames,error] = GetFileNames(obj,ResultsDir)
            PWD = pwd;
            
            try
                cd(ResultsDir);
                error = 0;
            catch
                error = -1; %Directory not found
                FileNames = []; 
                return
            end
            
            
            %% Get DateNums
            filenames = dir;
            x = size(filenames,1);
            filenames = rot90(reshape(struct2cell(filenames),5,x));
            FileNames = filenames(1:end-2,1);
            cd(PWD) ;         
        end
    end
end