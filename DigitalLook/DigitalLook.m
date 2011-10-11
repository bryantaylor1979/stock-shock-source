classdef DigitalLook <  handle & ...
                        DataSetFiltering & ...
                        InvestedSymbols & ...
                        MacroRun & ...
                        Comms & ...
                        PERatioAnalysis & ...
                        ResultsLog
    properties
        InstallDir = 'C:\SourceSafe\Stocks & Shares\Programs\DigitalLook\';
        Symbol2NumURL = 'http://www.digitallook.com/companysearch.cgi?select=dl&primary=y&keyword_begins=y&username=&ac=&advanced=&name=%s&stock_exchange=All+Markets'
        QueryURL = 'http://www.digitallook.com/cgi-bin/dlmedia/security.cgi?username=&ac=&csi=';
        Mode = 'web'; %web or url
        Mode2 = 'url';
        RunOnInt = 'off';
        Symbol2Remove = {   'PHC'; ...
                            'RUG'; ...
                            'GWP'; ...
                            'RMM'}
        loglevel = 0;  
        Rev = 0.01;
        ProgramName = 'DigitalLook';
    end
    methods
        function Symbols = RemoveSymbols(obj,Symbols)
            %%
            x = size(obj.Symbol2Remove,1);
            for i = 1:x
                n = find(not(strcmpi(obj.Symbol2Remove{i},Symbols)));
                Symbols = Symbols(n);
            end
        end
        function Forecasts = DownloadAll(obj,Symbols)
            %%
            x = size(Symbols,1);        
            %%
            h = waitbar(0);
            Sucess = 0;
            UnSucessfull = 0;
            for i = 1:x
                string = ['Sucessfull: ',num2str(Sucess/i*100),'% '];
                waitbar(i/x,h,[string,num2str(i),' of ',num2str(x)]);
                try
                    N_DATASET = obj.GetNextForecast(Symbols{i});
                    Sucess = Sucess + 1;
                    if exist('DATASET') == 1
                        DATASET = [DATASET;N_DATASET];
                    else
                        DATASET = N_DATASET;
                    end
                catch
                    UnSucessfull = UnSucessfull + 1;
                end
            end
            close(h);
            Forecasts = DATASET;
        end
        function DATASET = Process_ALL_Fundamentals(obj,Symbols,date)
            x = size(Symbols,1);        
            %
            h = waitbar(0);
            Sucess = 0;
            UnSucessfull = 0;
            for i = 1:x
                Symbol = Symbols{i};
                string = ['Sucessfull: ',num2str(Sucess/i*100),'% '];
                waitbar(i/x,h,[string,num2str(i),' of ',num2str(x)]);
                try
                    s = obj.LoadURL_Fundamentals(Symbol,date);
                    [N_DATASET2] = obj.URL_GetForecasts(s,Symbol);
                    
                    N_DATASET2 = obj.AddDateStr('YearEnd',N_DATASET2);
                    DateNum = obj.GetColumn(N_DATASET2,'YearEnd');
                    n = find(min(DateNum) == DateNum);
                    N_DATASET = [dataset({{Symbol},'Symbol'}),N_DATASET2(n,:)];
                    
                    if exist('DATASET') == 1
                        DATASET = [DATASET;N_DATASET];
                    else
                        DATASET = N_DATASET;
                    end
                    
                    Sucess = Sucess + 1;
                catch
                    UnSucessfull = UnSucessfull + 1;
                end
            end
            close(h);
        end
        function SaveURL_ALL_Fundamentals(obj,Symbols)
            %%
            x = size(Symbols,1);        
            %
            h = waitbar(0);
            Sucess = 0;
            UnSucessfull = 0;
            for i = 1:x
                string = ['Sucessfull: ',num2str(Sucess/i*100),'% '];
                waitbar(i/x,h,[string,num2str(i),' of ',num2str(x)]);
                try
                    obj.SaveURL_Fundamentals(Symbols{i});
                    Sucess = Sucess + 1;
                catch
                    UnSucessfull = UnSucessfull + 1;
                end
            end
            close(h);
        end
        function Symbols = GetSymbols(obj)
            sObj = SymbolInfo;
            sObj.InstallDir = [obj.InstallDir,'\'];
            sObj.ReadMap('III_IndexMap');
            Symbols = strrep(sObj.SymbolList,'.L','');
        end
        function DATASET = WEB_Query(obj,Symbol,Cat)
            %%          
            url = obj.BuildURL(Symbol);
            raw = obj.ReadWebQuery(url);
            
            switch Cat
                case 'Fundamentals'
                    [DATASET] = obj.GetFundamentals(raw,Symbol);
                case 'Forecasts'
                    [DATASET] = obj.GetForecasts(raw,Symbol);
                otherwise
            end   
        end
        function DATASET = URL_Query(obj,Symbol,Cat)
            url = obj.BuildURL(Symbol);
            raw = urlread(url);
            switch Cat
            	case 'Forecasts'
                    [DATASET] = obj.URL_GetForecasts(raw,Symbol);
            end
        end
        function s = SaveURL_Fundamentals(obj,Symbol)
            disp('hello')
            url = obj.BuildURL(Symbol)
            if isnan(url)
                s = obj.WEB_ReadURL(Symbol);
            else
                s = urlread(url);
            end
            %%
            PWD = pwd;
            Path = [obj.InstallDir,'Results\Forecasts\URL\',datestr(today),'\'];
            try
                cd(Path)
            catch
                mkdir(Path)
                cd(Path)
            end
            FileName = [Path,Symbol,'.mat'];
            save(FileName,'s');   
            cd(PWD)
        end
        function s = LoadURL_Fundamentals(obj,Symbol,date)
            %%
            PWD = pwd;
            Path = [obj.InstallDir,'Results\Forecasts\URL\',datestr(date),'\'];
            try
                cd(Path)
            catch
                mkdir(Path)
                cd(Path)
            end
            FileName = [Path,Symbol,'.mat'];
            load(FileName);   
            cd(PWD)
        end
        function SaveDAT(obj,DATASET,Cat,Symbol)
            %%
            save([obj.InstallDir,'\DAT\',Cat,'\',Symbol,'.mat'],'DATASET')
        end
        function DATASET = LoadDAT(obj,Cat,Symbol)
            load([obj.InstallDir,'\DAT\',Cat,'\',Symbol,'.mat'])
        end
        function DATASET = GetNextForecast(obj,Symbol)
            
            %%
            Cat = 'Forecasts';
            switch lower(obj.Mode2)
                case 'web'
                    DATASET = obj.WEB_Query(Symbol,Cat);
                case 'url'
                    DATASET = obj.URL_Query(Symbol,Cat);
            end
            
            %%
            DATASET = obj.AddDateStr('YearEnd',DATASET);
            DateNum = obj.GetColumn(DATASET,'YearEnd');
            n = find(min(DateNum) == DateNum);
            DATASET = [dataset({{Symbol},'Symbol'}),DATASET(n,:)];
        end
        function [DATASET,DateNum] = LoadLastResult(obj,ResultName)
            % [DATASET,DateNum] = obj.LoadLastResult('Forecast')
            %%
            PWD = pwd;
            cd([obj.InstallDir,'\Results\Forecasts\DATASET\'])
            filenames = struct2cell(dir);
            filenames = rot90(filenames(1,:),3);
            DateNum = datenum(strrep(filenames(3:end),'.mat',''));
            MaxDateNum = max(DateNum);
            load([datestr(MaxDateNum),'.mat']);
            DateNum = MaxDateNum;
            cd(PWD);
        end
    end
    methods %Extract data from web query raw data
        function [DATASET] = GetFundamentals(obj,raw,Symbol)
            %% Get Table
            Key = raw(:,1);
            [CompanyName] = obj.GetCompanyName(raw,Symbol);
            n = find(strcmpi(Key,[CompanyName,' Fundamentals']));
            Small = raw(n:end,:);
            n = find(strcmpi(Small,[CompanyName,' Forecasts']));
            n = n(1);
            Table = Small(2:n-4,:);
            
            [DATASET] = obj.ExtractTable(Table);
        end
        function [DATASET] = URL_GetForecasts(obj,raw,Symbol)
            %%
            n = findstr(raw,'Forecasts');
            if max(size(n)) < 2
                DATASET = [];
                return                
            end
            table = raw(n(2):n(2)+5000);
            n1 = findstr(table,'<td class="dataRegularUl');
            x = size(n1,2);
            rows = x/9;
            if rows == 0
                DATASET = [];
                return
            end
            for i = 1:rows
                %Year End
                StartLoc = (i-1)*9;
                n = n1(StartLoc+1);
                line = table(n:n+100);
                p = findstr(line,'</td>');
                r = findstr(line,'">');
                YearStr = line(r+2:p-1);
                YearEnd = datenum(YearStr,'dd-mmm-yy');
                if isempty(YearEnd)
                   YearEnd = NaN; 
                end 
                
                %Revenue 
                n = n1(StartLoc+2);
                line = table(n:n+100);
                p = findstr(line,'</td>');
                r = findstr(line,'">');
                
                temp = line(r+2:p-1);
                temp = strrep(temp,',','');
                Revenue = str2num(temp);
                if isempty(Revenue)
                   Revenue = NaN; 
                end 
                
                %Pre-tax 
                n = n1(StartLoc+3);
                line = table(n:n+100);
                p = findstr(line,'</td>');
                r = findstr(line,'">');
                
                temp = line(r+2:p-1);
                temp = strrep(temp,',','');
                PreTax = str2num(temp);
                
                if isempty(PreTax)
                   PreTax = NaN; 
                end 
                
                %EPS
                n = n1(StartLoc+4);
                line = table(n:n+100);
                p = findstr(line,'</td>');
                r = findstr(line,'">');
                EPS  = str2num(strrep(line(r+2:p-1),'p',''));
                if isempty(EPS)
                   EPS = NaN; 
                end                
                %P/E
                n = n1(StartLoc+5);
                line = table(n:n+100);
                p = findstr(line,'</td>');
                r = findstr(line,'">');
                PE  = str2num(strrep(line(r+2:p-1),'p',''));
                if isempty(PE)
                   PE = NaN; 
                end                
                %PEG
                n = n1(StartLoc+6);
                line = table(n:n+100);
                p = findstr(line,'</td>');
                r = findstr(line,'">');
                PEG  = str2num(strrep(line(r+2:p-1),'p',''));     
                if isempty(PEG)
                   PEG = NaN; 
                end
                
                %EPS Grth
                n = n1(StartLoc+7);
                line = table(n:n+100);
                p = findstr(line,'</td>');
                r = findstr(line,'">');
                EPSGrth  = str2num(strrep(line(r+2:p-1),'p','')); 
                if isempty(EPSGrth)
                   EPSGrth = NaN; 
                end
                
                %Div
                n = n1(StartLoc+8);
                line = table(n:n+100);
                p = findstr(line,'</td>');
                r = findstr(line,'">');
                Div  = str2num(strrep(line(r+2:p-1),'p','')); 
                if isempty(Div)
                   Div = NaN; 
                end
                
                %Yield
                n = n1(StartLoc+9);
                line = table(n:n+100);
                p = findstr(line,'</td>');
                r = findstr(line,'">');
                Yield  = str2num(strrep(line(r+2:p-1),'%',''));
                if isempty(Yield)
                   Yield = NaN; 
                end  
                
                try
                NewDataset = dataset(YearEnd,Revenue,PreTax,EPS,PE,PEG,EPSGrth,Div,Yield);
                catch
                    YearEnd 
                    Revenue
                    PreTax
                    EPS
                    PE
                    PEG
                    EPSGrth
                    Div
                    Yield
                end
                if i == 1
                    DATASET = NewDataset;
                else
                    DATASET = [NewDataset;DATASET];
                end
            end
        end
        function [DATASET] = URL_GetFundamentals(obj,raw,Symbol)
            n = findstr(raw,'Fundamentals');
            p = findstr(raw,'Forecasts');
            if max(size(p)) < 2
                 p = findstr(raw,'Announcements');
            end
            if max(size(n)) < 2
                DATASET = 'No Data';
                return
            end
            table = raw(n(2):p(2));
            n1 = findstr(table,'<td class="dataRegularUl');
            x = size(n1,2);
            rows = x/9;
            for i = 1:rows
                %Year End
                StartLoc = (i-1)*9;
                n = n1(StartLoc+1);
                line = table(n:n+100);
                p = findstr(line,'</td>');
                r = findstr(line,'">');
                YearStr = line(r+2:p-1);
                YearEnd = datenum(YearStr,'dd-mmm-yy');
                
                %Revenue 
                n = n1(StartLoc+2);
                line = table(n:n+100);
                line = strrep(line,'<sub class="footnoteSymbol">a</sub>','');
                p = findstr(line,'</td>');
                r = findstr(line,'">');
                RevenueStr = line(r+2:p-1);
                RevenueStr = strrep(RevenueStr,',','');
                Revenue = str2num(RevenueStr);
                if isempty(Revenue)
                   Revenue = NaN; 
                end 
                
                %Pre-tax 
                n = n1(StartLoc+3);
                line = table(n:n+100);
                line = strrep(line,'<sub class="footnoteSymbol">a</sub>','');
                p = findstr(line,'</td>');
                r = findstr(line,'">');
                PreTaxStr = line(r+2:p-1);
                PreTaxStr = strrep(PreTaxStr,',','');
                PreTax  = str2num(PreTaxStr);
                
                
                %EPS
                n = n1(StartLoc+4);
                line = table(n:n+100);
                p = findstr(line,'</td>');
                r = findstr(line,'">');
                str = strrep(line(r+2:p-1),'p','');
                str = strrep(str,')&cent;','');
                str = strrep(str,'(','');
                str = strrep(str,')','');
                str = strrep(str,',','');
                EPS  = str2num(str);
                if isempty(EPS)
                   EPS = NaN; 
                end     
                
                
                %P/E
                n = n1(StartLoc+5);
                line = table(n:n+100);
                p = findstr(line,'</td>');
                r = findstr(line,'">');
                PE  = str2num(strrep(line(r+2:p-1),'p',''));
                if isempty(PE)
                   PE = NaN; 
                end                
                %PEG
                n = n1(StartLoc+6);
                line = table(n:n+100);
                p = findstr(line,'</td>');
                r = findstr(line,'">');
                PEG  = str2num(strrep(line(r+2:p-1),'p',''));     
                if isempty(PEG)
                   PEG = NaN; 
                end
                
                %EPS Grth
                n = n1(StartLoc+7);
                line = table(n:n+100);
                p = findstr(line,'</td>');
                r = findstr(line,'">');
                EPSGrth  = str2num(strrep(line(r+2:p-1),'p','')); 
                if isempty(EPSGrth)
                   EPSGrth = NaN; 
                end
                
                %Div
                n = n1(StartLoc+8);
                line = table(n:n+100);
                p = findstr(line,'</td>');
                r = findstr(line,'">');
                
                Div = strrep(line(r+2:p-1),'p','');
                Div = strrep(Div,',','');
                Div  = str2num(Div); 
                if isempty(Div)
                   Div = NaN; 
                end
                
                %Yield
                n = n1(StartLoc+9);
                line = table(n:n+100);
                p = findstr(line,'</td>');
                r = findstr(line,'">');
                Yield  = strrep(line(r+2:p-1),'%','');
                Yield = strrep(Yield,',','');
                Yield = str2num(Yield);
                if isempty(Yield)
                   Yield = NaN; 
                end  
                
                try
                    NewDataset = dataset(YearEnd,Revenue,PreTax,EPS,PE,PEG,EPSGrth,Div,Yield);
                catch
                    YearEnd
                    Revenue
                    PreTax
                    EPS
                    PE
                    PEG
                    EPSGrth
                    Div
                    Yield
                end
                if i == 1
                    DATASET = NewDataset;
                else
                    try
                    DATASET = [NewDataset;DATASET];
                    catch
                        NewDataset
                        DATASET
                        error('Error, check decoded data displayed above')
                    end
                end  
            end
        end
    end
    methods (Hidden = true)
        function [DATASET] = ExtractTable(obj,Table)
            %% Extract Table
            YearEnd = datenum(Table(2:end,1),'dd/mm/yyyy');
            
            %Rev
            RevenueTemp = Table(2:end,2);
            PreTaxTemp = Table(2:end,3);
            x = size(RevenueTemp,1);
            for i = 1:x
                if ischar(RevenueTemp{i})
                    try
                    PreTax(i,1) = str2num(strrep(PreTaxTemp{i},'a',''));
                    catch
                    PreTax(i,1) = nan;    
                    end
                    try
                    Revenue(i,1) = str2num(strrep(RevenueTemp{i},'a',''));
                    catch
                    Revenue(i,1) = nan;
                    end
                else
                    PreTax(i,1) = PreTaxTemp{i};
                    Revenue(i,1) = RevenueTemp{i};
                end
            end
            
            %EPS
            EPS = str2double(strrep(Table(2:end,4),'p',''));
            %% PE
            PEcell = Table(2:end,5);
            x = size(PEcell,1);
            for i = 1:x
                try
                PE(i,1) = cell2mat(PEcell(i));
                catch
                PE(i,1) = nan;   
                end
            end
            %% PEG
            PEG = Table(2:end,6);
            %% EPS_Grth
            EPS_Grth_cell = Table(2:end,7);
            x = size(EPS_Grth_cell,1);
            for i = 1:x
                try
                EPS_Grth(i,1) = cell2mat(EPS_Grth_cell(i));
                catch
                EPS_Grth(i,1) = nan;   
                end
            end
            %Yield
            Yield = cell2mat(Table(2:end,9));
            
            DATASET = dataset(YearEnd,Revenue,PreTax,EPS,PE,EPS_Grth,Yield);
        end
        function [CompanyName] = GetCompanyName(obj,raw,Symbol)
            %%
            Key = raw(:,1);
            n = find(strcmpi(Key,'Events'));
            
            %%
            CompanyName = Key{n+1};
            start = findstr(CompanyName,'(');
            CompanyName = CompanyName(1:start);
            
            CompanyName = strrep(CompanyName,'(','');
            CompanyName = strrep(CompanyName,')','');
            
            CompanyName = CompanyName(1:end-1);
        end
        function url = BuildURL(obj,Symbol)
            [Num, Status] = obj.LOC_Symbol2Num(Symbol);
            if Status == -1
                [Num, Status] = obj.WEB_Symbol2Num(Symbol);
            end         
            if isnan(Num)
                url = NaN;
                return
            end
            url = [obj.QueryURL,num2str(Num)];
        end
        function StoreSymbolNum(obj,Symbol,Num)         
           %%
           try
                load([obj.InstallDir,'\Data\Symbol2NumLUT.mat']);
           catch
                disp('StoreSymbolNum:  No LUT found. New file created with 1 entry');
                Symbol2NumLUT = {Symbol,Num};
                save([obj.InstallDir,'\Data\Symbol2NumLUT.mat']) ; 
                return
           end
           
           n = find(strcmpi(Symbol2NumLUT(:,1),Symbol));
           if isempty(n)
                Symbol2NumLUT = [Symbol2NumLUT;{Symbol,Num}];
                save([obj.InstallDir,'\Data\Symbol2NumLUT.mat']);
                if obj.loglevel > 0
                disp('StoreSymbolNum: New entry. Lookup table has been updated');
                end
           else
                if obj.loglevel > 0
                disp('StoreSymbolNum: Entry already exists. Lookup table has NOT been updated');
                end
                return
           end
        end
    end
    methods (Hidden = true) %Not used in main kernel
        function obj = DigitalLook(varargin)
            [x] = size(varargin,2);
            for i = 1:2:x
                obj.(varargin{i}) = varargin{i+1};
            end
            
            if strcmpi(obj.RunOnInt,'on');
                obj.RunMacro(obj.Macro);
            end
        end
        function [Table] = SymbolLookupResults(obj,Symbol)
            %%
            Symbol = 'CSLT';
            string = sprintf(obj.Symbol2NumURL,Symbol);
            raw = obj.ReadWebQuery(string);
            
            %%
            identifier = 'Company Search Results';
            n = find(strcmpi(identifier,raw));
            
            %%
            identifier = 'Help & Education';
            p = find(strcmpi(identifier,raw));
            Table = raw(n+1:p-2,:);            
        end
        function WriteWebQuery(obj,string)
            if obj.loglevel > 0
                disp(string)
            end
            fid = fopen('DL.iqy', 'w');
            fprintf(fid, [ ...
                'WEB\n',...
                '1\n', ...
                string,'\n', ...
                '\n', ...
                'Selection=EntirePage\n', ...
                'Formatting=None\n', ...
                'PreFormattedTextToColumns=True\n', ...
                'ConsecutiveDelimitersAsOne=True\n', ...
                'SingleBlockTextImport=False\n', ...
                'DisableDateRecognition=False\n', ...
                'DisableRedirections=False']);
            fclose(fid);
        end
        function raw = ReadWebQuery(obj,string)
           time = 1;
           while time <200
                try
                    obj.WriteWebQuery(string);
                    [num,data,raw] = xlsread('DL.iqy');
                    break
                catch
                    disp('Connection problems')
                    pause(time);
                    time = time*2;
                end
            end            
        end
    end
end