classdef WebPageDecoder < handle & ...
                          Common & ...
                          WQ_Decoder & ...
                          MacroRun
    properties
        WaitbarEnable = false
        InstallDir = [];
        RunOnInt = 'on'
        ProgramName = 'WebDecoder'
        
        % plug-ins
        Stox
        FT_Perf
        BB_ALLSTATUS
        BB_Hist
        WBS
        DL_Sym2Num
        
        ResultsLog_OBJ = []; %This doesn't seem to be used.
    end
    methods
        function Example(obj)
            %%
            close all
            clear classes
            obj = WebPageDecoder('Macro','Stox_ProcessDay','WaitbarEnable',true)
            
            %%
            close all
            clear classes
            obj = WebPageDecoder('Macro','BB_HIST_Decode','RunOnInt',false)
        end
        function obj = WebPageDecoder(varargin)
            % set-up defaults
            [path,~,~] = fileparts(which('WebPageDecoder'));
            obj.InstallDir = path;         
            obj.ResultsDir = fullfile(path,'Results');
            obj.SettingsDir = obj.InstallDir;
            
            %%
            for i = 1:2:max(size(varargin))
                obj.(varargin{i}) = varargin{i+1};
            end
            
            %%
            obj.ResultsLog_OBJ = ResultsLog('ResultsDir',   fullfile(path,'Results'));
            
            obj.Stox = PGin_Stox;
            obj.FT_Perf = PGin_FT_Perf;
            obj.BB_ALLSTATUS = PGin_BB_ALLSTATUS;
            obj.BB_Hist = PGin_BB_Hist;
            obj.WBS = PGin_WBS;
            obj.DL_Sym2Num = PGin_DL_Symbol2Num;
            
            disp(['ResultsDir: ',obj.ResultsLog_OBJ.ResultsDir])
            
            if isempty(obj.Macro)
                PWD = pwd;
                cd([obj.InstallDir,'Macros\'])
                d = dir;
                str = {d.name};
                [s,v] = listdlg('PromptString','Select a file:',...
                                'SelectionMode','single',...
                                'ListString',str);
                obj.Macro = str{s};
                cd(PWD)
            end
            
            if strcmpi(obj.RunOnInt,'on')
                obj.RunMacro(obj.Macro)
            end
        end
        function ProcessALL(obj,ProgramName,ResultName,MacroName)
            %%
            DateNums = obj.GetDates(ProgramName,ResultName,'URL');
            h = waitbar(0);
            set(h,'position',[249 296.875 270 56.25]);
            x = size(DateNums,1);
            for i = 1:x
                waitbar(i/x,h)
                Date = DateNums(i);
                obj.RunMacro(MacroName)
            end
        end
        function DATASET = ProcessDay_Macro(obj,Symbols,ProgramName,ResultName,MacroName,Date)
            %%
            h = waitbar(0);
            x = max(size(Symbols));
            first = true;
            for i = 1:x
                waitbar(i/x,h)
                Symbol = Symbols{i};
                [N_DATASET] = obj.RunMacro(MacroName,'Symbol',Symbol,'Date',Date)
                if not(isempty(N_DATASET))
                    if first == false
                        DATASET = [DATASET;N_DATASET]; 
                    else
                        first = false;
                        DATASET = N_DATASET;
                    end
                end
            end 
            close(h)
        end
        function ProcessSingle(obj,struct,ProgramName,ResultName,Date)
            %%
            try
                Symbols = obj.GetURL_Symbols(ProgramName,ResultName,Date);
            catch
                disp('Date does not exist. Please ensure that it has been processed')
                error('') 
            end
            [DATASET, N_ErrorSymbols] = obj.DecodeALL(struct,'URL',Symbols,ProgramName,ResultName,Date);
            Symbol = Symbols;
            DATASET = [dataset(Symbol),DATASET];
            obj.SaveDataSet(DATASET,ProgramName,ResultName,Date);
        end
        function ProcessTable_Single(obj,struct,Symbols,ProgramName,ResultName,Date)  
            h = waitbar(0);
            [x] = size(Symbols,1);
            for i = 1:x
                waitbar(i/x,h)
                [s, Error] = obj.LoadResult_Type(ProgramName,ResultName,Symbols{i},Date,'URL');
                try
                Table = obj.DecodeTable(s,struct);
                obj.SaveResult_Type(Table,Symbols{i},ProgramName,ResultName,'TABLE',Date);
                end
            end
            close(h)
        end
        function DecodeAll_Tables(obj,struct,Symbols,ProgramName,MacroName,Date)
            %%
            h = waitbar(0);
            x = max(size(Symbols));
            for i = 1:x
                waitbar(i/x,h)
                [s, Error] = obj.LoadResult_Type(ProgramName,MacroName,Symbols{i},Date,'URL');
                try
                Array = obj.DecodeTable(s,struct); 
                Array = obj.RemoveALL_Formating(Array);
                obj.Save(Array, Symbols{i}, ProgramName,    MacroName, 'TABLE',    Date)
                end
            end
            close(h)
        end
        function [DATASET2, ErrorSymbols] = DecodeALL(obj,struct,Method,Symbols,ProgramName,ResultName,Date)
            %%
            h = waitbar(0);
            
            x = max(size(Symbols));
            
            ErrorSymbols = [];
            count = 1;
            for i = 1:x
                waitbar(i/x,h,[num2str(i),' of ',num2str(x)])
                Symbol = Symbols{i};
                Symbol = strrep(Symbol,'.L','');
                
                [s, Error] = obj.LoadResult_Type(ProgramName,ResultName,Symbol,Date,Method);
                
%                 try
                    outStruct = obj.DecodeURL(s,struct); 
                    N_DATASET = obj.Struct2DataSet(outStruct);

                    if exist('DATASET2') == 0
                        DATASET2 = N_DATASET;
                    else
                        DATASET2 = [DATASET2;N_DATASET];
                    end
%                 catch
%                     ErrorSymbols{count} = Symbol;
%                     count = count + 1;
%                 end
            end
            close(h)
        end
        function [DATASET2, ErrorSymbols] = DecodeALL_Jenkins(obj,struct,Path,Symbols)
            %%
            if obj.WaitbarEnable == true
                h = waitbar(0);
            end
            x = max(size(Symbols));
            ErrorSymbols = [];
            count = 1;
            for i = 1:x
                if obj.WaitbarEnable == true
                    waitbar(i/x,h,[num2str(i),' of ',num2str(x)])
                else
                    disp([num2str(i),' of ',num2str(x)])
                end
                Symbol = Symbols{i};
                Symbol = strrep(Symbol,'.L','');
                [s, Error] = obj.LoadFile(Path,Symbol);
                if not(Error == -1)
                    outStruct = obj.DecodeURL(s,struct);
                    y = size(outStruct,2);
                    for j = 1:y
                        Name = strrep(outStruct(j).Name,' ','');
                        Val = outStruct(j).Val;
                        if strcmpi(outStruct(j).Class,'Char')
                            struct2.(Name){count} = outStruct(j).Val;
                        else
                            Val = outStruct(j).Val;
                            if isempty(Val)
                                struct2.(Name){count}= NaN;
                            else
                                struct2.(Name){count}= Val;
                            end
                        end
                        %disp([outStruct(i).Name,' - ',outStruct(i).Val])
                    end
                    struct2.Symbols{count} = Symbol;
                    count = count + 1;
                end
            end
            %%
            x = size(outStruct,2)
            for i = 1:x
                Name = strrep(outStruct(i).Name,' ','');
                ARRAY = struct2.(Name);
                if not(strcmpi(outStruct(i).Class,'char'))
                    ARRAY = cell2mat(ARRAY);
                end
                DATASET2.(Name) = ARRAY;
            end   
            DATASET2.Symbols = struct2.Symbols;
            %%
            if obj.WaitbarEnable == true
                close(h)
            end
        end
        function DATASET = Struct2DataSet(obj,outStruct)
            %%
            x = max(size(outStruct));
            for i  = 1:x
                Name = outStruct(i).Name;
                Val = outStruct(i).Val;
                Class = outStruct(i).Class;
                
                warning off
                if strcmpi(Class,'char')
                    N_DATA = dataset({{Val},Name});
                else
                    if not(isempty(Val))
                        N_DATA = dataset({Val,Name});
                    else
                        N_DATA = dataset({NaN,Name});
                    end
                end
                warning on
                
                if i == 1
                    DATASET = N_DATA;
                else
                    try
                    DATASET = [DATASET,N_DATA];
                    catch
                    error('Parameter is specified twice')
                    end
                end
            end
        end
        function outStruct = DecodeURL(obj,s,struct)
            CR_String = '<&CR&>';
            load('CarrageReturn');
            for i = 1:max(size(struct))
                try
                    %Values to keep
                    outStruct(i).Name = struct(i).Name;
                    outStruct(i).Class = struct(i).Class;

                    StartString = struct(i).StartString;
                    EndString = struct(i).EndString;
                    
                    StartString = strrep(StartString,CR_String,CarrageReturn);
                    EndString = strrep(EndString,CR_String,CarrageReturn);
                    
                    StartLoc = findstr(s,StartString);

                    StartStringSize = max(size(StartString));
                    s1 = s(StartLoc+StartStringSize:end);
                    
                    EndLoc = findstr(s1,EndString);
                    if EndLoc(1) > 500
                        disp('error')
                        EndLoc = findstr(s1,' ');   
                    end
                    
                    EndLoc = EndLoc(1);

                    Val = s1(1:EndLoc-1);
                    Val = obj.DecodeVal(Val,struct(i).Class);
                    outStruct(i).Val = Val;
                catch
%                     warning(['Error with: ',struct(i).Name])
                    if strcmpi(struct(i).Class,'char')
                        outStruct(i).Val = 'Error';
                    else
                        outStruct(i).Val = NaN;
                    end
                end
            end
        end 
        function Table = DecodeTable(obj,s,struct)
            %%           
            [table] = obj.CropTable(s,struct.TableStart,struct.TableEnd);
            [rows] = obj.CropRows(table,struct.RowStart,struct.RowEnd);
            Table = obj.GetAllCells(rows,struct.CellStart,struct.CellEnd,struct.CellEndT);   
        end
        function URL_2_WQ(obj,ProgramName,MacroName,Date)
            %%
            Pages = obj.GetSaveType_Symbols('URL',ProgramName,MacroName,Date)
            
            %%
            h = waitbar(0);
            for i = 1:max(size(Pages))
                waitbar(i/max(size(Pages)),h)
                raw = Single_URL_2_WQ(obj,ProgramName,MacroName,Date,Pages{i});
                obj.SaveResult_Type(raw,Pages{i},ProgramName,MacroName,'WQ',Date);
            end
            close(h)
        end  
        function Table2= RemoveALL_Formating(obj,Table)
            for j = 1:size(Table,2)
                Column = j;
                for i = 1:size(Table,1)
                     try
                    val = Table{i,Column};
                    val = obj.RemoveFormating(val);     
                    Table2{i,Column} = val;
                     end
                end    
            end
        end
        function val = RemoveFormating(obj,val)
            %Examples: 
            %<font size=1>   <b> AZEM </b>  </font>
                n = findstr(val,'>');
                p = findstr(val,'</');
                s = find(n<p(1));
                n = n(s);
                val = val(n(end)+1:end);
                n = findstr(val,'<');
                val = val(1:n(1)-1);  
                
                %Remove spaces at start and end
                n = findstr(val,' ');
                x = max(size(val));
                if n == 1
                    val = val(2:end);
                end
                
                load('cr.mat');
                val = strrep(val,cr,'');
                
                load('CarrageReturn.mat');
                val = strrep(val,CarrageReturn,'');
                
                load('CR2.mat');
                val = strrep(val,CR2,'');
                
                load('CR3.mat')
                val = strrep(val,CR3,'');
                
                load('CR4.mat')
                val = strrep(val,CR4,'');
                
                %% remove from end
                x = size(val,2);
                n =  findstr(val,' ');
                if not(isempty(n))
                    LastSpace = n(end);
                    while LastSpace == x
                        val = val(1:end-1);
                        x = size(val,2);
                        n =  findstr(val,' ');
                        if isempty(n)
                           break 
                        end
                        LastSpace = n(end);
                    end
                end 
                
                %% remove from start
                n =  findstr(val,' ');
                if not(isempty(n))
                    LastSpace = n(1);
                    while LastSpace == 1
                        val = val(2:end);
                        n =  findstr(val,' ');
                        if isempty(n)
                           break 
                        end
                        LastSpace = n(1);
                    end
                end 
        end
    end
    methods (Hidden = true) %Web Query support
        function raw = Single_URL_2_WQ(obj,ProgramName,MacroName,Date,Page)
            %%
            obj.WriteWebQuery(ProgramName,MacroName,Date,Page)
            raw = obj.ReadWebQuery;
        end
        function WriteWebQuery(obj,ProgramName,MacroName,date,Page)
            %% BasicMaterials
            file = [obj.ResultsDir,ProgramName,'\Results\',MacroName,'\URL\',datestr(date),'\',Page,'.mat']
            load(file)
            %%
            fid = fopen([obj.InstallDir,'temp.html'],'wt');
            fprintf(fid,'%c',s)
            %%
            fid = fopen([obj.InstallDir,'temp.iqy'], 'w');
            fprintf(fid, [ ...
                'WEB\n',...
                '1\n', ...
                [strrep(obj.InstallDir,'\','\\'),'temp.html\n'], ...
                '\n', ...
                'Selection=EntirePage\n', ...
                'Formatting=None\n', ...
                'PreFormattedTextToColumns=True\n', ...
                'ConsecutiveDelimitersAsOne=True\n', ...
                'SingleBlockTextImport=False\n', ...
                'DisableDateRecognition=False\n', ...
                'DisableRedirections=False']);
            fclose(fid);
            raw = obj.ReadWebQuery();
        end
        function raw = ReadWebQuery(obj)
            timeout = 2000;
            time = 1;
            while time < timeout
                try
                    [num,data,raw] = xlsread([obj.InstallDir,'temp.iqy']);
                    break
                catch
                    time = time*2;
                    disp(['pause for ',num2str(time),' secs']);
                    pause(time);
                end
            end
        end
    end
    methods (Hidden = true) %DecodeURL - Support
        function struct = GetConfig2(obj,ProgramName)
            file = fullfile(obj.InstallDir,'DecodeConfigs',[ProgramName,'.m']);
            struct = obj.GetConfigFullPath(file);  
            try
            struct = obj.ReplaceIllegalChars(struct);
            end
        end
        function Val = DecodeVal(obj,Val,Class)
            switch lower(Class)
                case 'num'
                    Val = obj.String2num(Val);
                case 'char'
                    %do nothing
                otherwise
                    Class
                    error(['Class not recognised: ',Class])
            end
        end 
        function Num = String2num(obj,String)
            if isnan(String)
                Num = NaN;
                return
            end
            String = strrep(String,',','');
            Num = str2num(String);
        end   
    end
    methods (Hidden = true) %DecodeTable - Support
        function cells = GetAllCells(obj,rows,cellstart,cellend,cellend2)
            %%
            x = max(size(rows));
            cells = [];
            for i = 1:x
                rowstr = rows{i};
                cell = obj.GetCell(rowstr,cellstart,cellend,cellend2);
                y = size(cells,2);
                try
                cells = [cells;cell];
                catch
                cells = [cells;cell(1:y)];    
                end
            end
        end
        function cell = GetCell(obj,rowstr,cellstart,cellend,cellend2)
%             rowstr
            n1 = findstr(rowstr,cellstart);
            n2 = findstr(rowstr,cellend);
            x = max(size(n1));
            for i = 1:x
                startloc = n1(i);
                n = min(find(startloc < n2));
                endloc = n2(n);
                
                string = rowstr(startloc:endloc);
                n = findstr(string,'">');
                if isempty(n)
                   n = findstr(string,'>') - 1;
                end
                string2 = string(n+2:end-1);
                cell{i} = string2;
            end
            
            try
                En = findstr(rowstr,'/>');
                n = max(find(n1 < En));

                for i = 1:max(size(n))
                    cell{n(i)} = '';
                end
            end
        end
        function [rows] = CropRows(obj,table,rowstart,rowend)
            n3 = findstr(table,rowstart);
            n4 = findstr(table,rowend);
            disp([num2str(max(size(n3))),' rows detected'])
            
            for i = 1:max(size(n3))
                try
                temp = table(n3(i):end);
                n4 = findstr(temp,rowend);
                rows{i} = temp(1:n4(1));
                end
            end            
        end
        function [table] = CropTable(obj,s,tablestart,tableend)
            n1 = findstr(s,tablestart);
            n2 = findstr(s,tableend);
            table = s(n1:n2);
            
            if isempty(table)
                startindex = 1;
                size(n1,2);
                size(n2,2);
                n1 = n1(startindex);
                n = find(n1 < n2);
                n2 = n2(n);
                n2 = n2(1);
                table = s(n1:n2);
            end
        end
    end
end