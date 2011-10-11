classdef Stox < handle & ...
                InvestedSymbols & ...
                Comms & ...
                DataSetFiltering & ...
                MacroRun & ...
                ResultsLog & ...
                URL_Download
    properties
        GUI_Mode = 'User';                              %Minimal or Full or User                              
        CloseGUIwhenComplete = 'off';                   %{'off','on'} When on the program will close when macro is complete.
    end
    properties (Hidden = true)
        Conn
        handles
        
        Rev = 0.07;
        StoxInstallDir = [];
    end
    methods
        function GetQuote(obj,Symbol)
            % Get last price quoted from yahoo
            try
                LastPrice = fetch(obj.Conn,Symbol,'Last');
            catch 
                obj.ErrorCode = -1;
                return
            end
            obj.LastPrice =  LastPrice.Last;
            drawnow;
        end
        function InvestedSymbolDownload(obj)
            obj.DownloadAllData(obj.InvestedSymbols);
        end
        function Data = LoadData(varargin)
        %Example 1: User promopted load data
        %===================================
        %obj = stox('GUI_Mode','Minimal');
        %obj.LoadData;
        %
        %Example 2: Automated load
        %=========================
        %obj = stox('GUI_Mode','Minimal');
        %obj.LoadData(today);
        %
        %Example 3: Get Last store data
        %==============================
        %obj = stox('GUI_Mode','Minimal');
        %DateNum = obj.GetLastDate;
        %obj.LoadData(DateNum);
            x = size(varargin,2)
            obj = varargin{1};
            if x > 1
                filename = varargin{2};
                filename = datestr(filename)
                pathname = obj.DataDir;
            else
                [filename,pathname] = uigetfile([obj.DataDir]);
            end
            Data = load([pathname,filename]);
            Data = Data.Data;
            obj.Data = Data;
            
            if strcmpi(obj.GUI_Mode,'Full')
            set(obj.handles.table,  'Data',Data, ...
                                    'ColumnName',{'Symbol','Signal','6 Month Target','LastPrice','Growth'});
            end
        end
        function LastRow = GetLastQuote(obj,Symbol)
            %% Example: 
            %obj = Stox;
            %obj.GetLastQuote('BARC.L')
            
            Symbol = 'BARC';
            DateNum = obj.GetLastDate;
            Data = obj.LoadData(DateNum);
            n = find(strcmpi(Data(:,1),[Symbol,'.L']))
            Dat = Data(n(1),:)
            
            %%
            Symbol = {Symbol}
            TargetsSixMonths = Dat(2);
            SupportOne = Dat(3);
            SupportTwo = Dat(4);
            ResistanceOne = Dat(5);
            TargetOneYear = Dat(6);
            ResistanceTwo = Dat(7);
            PivotPointStart = Dat(8);
            MA_Five = Dat(9);
            MA_Twenty = Dat(10);
            MA_OneHundred = Dat(11);
            MA_TwoHundredAndFifty = Dat(12)
            K = Dat(13);
            D = Dat(14);
            RSI = Dat(15);
            High = Dat(16);
            Low = Dat(17);
            TenDysVol = Dat(18);
            Change = Dat(19);
            ThreeMnthsVol = Dat(20);
            PriceAndMovingAvText = {Dat(21)};
            BollingerBands = {Dat(22)};
            Rating = Dat(23);
            Signal = {Dat(24)};
            Stars =  Dat(25);
            DateEval = Dat(26);
            
            %%
            LastRow= dataset(Symbol, ...
                     TargetsSixMonths, ...
                     SupportOne, ...
                     MA_OneHundred, ...
                     MA_TwoHundredAndFifty, ...
                     K, ...
                     D, ...
                     RSI, ...
                     High, ...
                     Low, ...
                     TenDysVol, ...
                     Change, ...
                     ThreeMnthsVol, ...
                     PriceAndMovingAvText, ...
                     BollingerBands, ...
                     Rating, ...
                     Signal, ...
                     ResistanceOne, ...
                     TargetOneYear, ...
                     ResistanceTwo, ...
                     PivotPointStart, ...
                     MA_Five, ...
                     MA_Twenty, ...
                     Stars, DateEval, ...
                     SupportTwo);
        end
        function DateNum = GetLastDate(obj)
            %%
            CD = pwd;
            cd(obj.DataDir);
            names = struct2cell(dir);
            names=rot90(names(1,1:end));
            
            str = names(1:end-2);
            DateNum = max(datenum(strrep(str,'.mat','')));   
            cd(CD)
        end
    end
    methods (Hidden = false)
        function s = LoadURL(obj,Symbol,Date)
            Path = ['C:\SourceSafe\Stocks & Shares\Programs\Stox\Results\Best_Investments\URL\',datestr(Date),'\'];
            load([Path,Symbol,'.mat']);
        end
        function DATASET = DecodeURL(obj,s,Symbol)
            DateStart = findstr(s,'<font face="Verdana" style="font-size: 8.5pt"></font></span><font face="Verdana" style="font-size: 8.5pt; font-weight:700"> ');
            DateEnd = findstr(s,'<font face="Verdana" style="font-size: 8.5pt; font-weight:700">Overall</font></td>');
            
%             <font face="Verdana" style="font-size: 8.5pt">&nbsp;&nbsp;&nbsp; <img border=0 src=http://uk.stoxline.com/pics/
            RatingStart = findstr(s,'&nbsp;&nbsp;&nbsp; <img border=0 src=http://uk.stoxline.com/pics/');  
            RatingEnd = findstr(s,'.bmp>&nbsp;&nbsp;&nbsp;');
            TargetSixStart = findstr(s,'Verdana">Six months: ');
            TargetOneYearStart = findstr(s,'One year: ');
            SupportsOneStart = findstr(s,'Support1');
            SupportsTwoStart = findstr(s,'Support2');
            ResistanceOneStart = findstr(s,'Resistance1');
            ResistanceTwoStart = findstr(s,'Resistance2');
            PivotPointStart = findstr(s,'Pivot Point');
            MovingAveragesStart = findstr(s,'Moving Averages');
            
            MA_Five_Start  = findstr(s,'MA(5): ');
            MA_Twenty_Start  = findstr(s,'MA(20): ');
            MA_OneHundred_Start  = findstr(s,'MA(100): ');
            MA_TwoHundredAndFifty_Start  = findstr(s,'MA(250): ');
            K = findstr(s,'%K(14,3):');
            D = findstr(s,'%D(3):');
            
            RSIStart = findstr(s,'RSI</font></p>');
            WeekStart = findstr(s,'52-Week');
            
            HighStart = findstr(s,'High: ');
            LowStart = findstr(s,'Low: ');
            ChangeStart = findstr(s,'Change(%): ');
            
            ThreeMnthsVolumeStart = findstr(s,'3-Month:');
            TenDaysVolumeStart = findstr(s,'10-Days ');
            
            PriceAndMovingAveragesStart = findstr(s,'font-size: 8.5pt">Price and moving averages');
            BollingerBandsStart = findstr(s,'font-weight: 700">Bollinger Bands</span');
            BollingerBandsEnd = findstr(s,'Strong Sell');
            
            TargetsSixMonths = str2num(s([TargetSixStart+22:TargetOneYearStart-30]));
            TargetOneYear = str2num(s([TargetOneYearStart+9:SupportsOneStart-779]));
            
            SupportOne = s([SupportsOneStart+10:SupportsTwoStart]);
            n = findstr(SupportOne,'<img border=0 src=http://uk.stoxline.com/pics/');
            SupportOne = str2num(SupportOne(1:n-1));
            
            SupportTwo = s([SupportsTwoStart+10:ResistanceOneStart]);
            n = findstr(SupportOne,'<img border=0 src=http://uk.stoxline.com/pics/');
            SupportTwo = str2num(SupportTwo(1:n-15));
            
            
            ResistanceOne = str2double(s([ResistanceOneStart+15:ResistanceTwoStart-14]));
            ResistanceTwo = str2double(s([ResistanceTwoStart+12:PivotPointStart-396]));
            PivotPointStart = str2double(s([PivotPointStart+393:MovingAveragesStart-476]));
            MA_Five = str2double(s([MA_Five_Start+6:MA_Twenty_Start-100]));
            MA_Twenty = str2double(s([MA_Twenty_Start+7:MA_OneHundred_Start-226]));
            MA_OneHundred = str2double(s([MA_OneHundred_Start+8:MA_TwoHundredAndFifty_Start-98]));
            MA_TwoHundredAndFifty = str2double(s([MA_TwoHundredAndFifty_Start+8:MA_TwoHundredAndFifty_Start+15]));
            K = str2double(s([K+9:D-93]));
            D = str2double(s([D+6:RSIStart-569]));
            RSI = str2double(s([RSIStart+496:WeekStart-553]));
            
            High = str2num(s([HighStart+5:LowStart-21]));
            Low = str2num(s([LowStart+4:ChangeStart-8]));
            Change = str2num(s([ChangeStart+10:ThreeMnthsVolumeStart-924]));
            
            ThreeMnthsVol = str2num(s([ThreeMnthsVolumeStart+8:TenDaysVolumeStart-21]));
            TenDysVol = str2num(s([TenDaysVolumeStart+8:PriceAndMovingAveragesStart-682]));
            
            PriceAndMovingAvText = strrep(s([PriceAndMovingAveragesStart+18:BollingerBandsStart-318]),'</span></font></td>','');
            BollingerBands = strrep(s([BollingerBandsStart+376:BollingerBandsEnd-342]),'</span></font></td>','');
            
            %Rating 
            Rating = str2num(s([RatingStart+65:RatingEnd-2]));
            
            %? Strong Sell ?? Sell ??? Neutral ???? Buy ????? Strong Buy
            switch Rating
                case 1
                    Signal = 'Strong Sell';
                    Stars = '?';
                case 2
                    Signal = 'Sell';
                    Stars = '??';
                case 3
                    Signal = 'Neutral';
                    Stars = '???';
                case 4
                    Signal = 'Buy';
                    Stars = '????';
                case 5
                    Signal = 'Strong Buy';
                    Stars = '?????';
                otherwise
            end
            
            DateEval = datenum(s([DateStart+346:DateEnd-380]));
            
            if isempty(TargetsSixMonths)
                TargetsSixMonths = NaN;
            end
            if isempty(SupportOne)
                SupportOne = NaN;
            end
            if isempty(TargetOneYear)
                TargetOneYear = NaN;
            end
            if isempty(SupportTwo)
                SupportTwo = NaN;
            end
            if isempty(ResistanceOne)
               ResistanceOne = NaN; 
            end
            if isempty(ResistanceTwo)
               ResistanceTwo = NaN; 
            end
            if isempty(PivotPointStart)
               PivotPointStart = NaN; 
            end            
            if isempty(MA_Five)
               MA_Five = NaN; 
            end  
            if isempty(MA_Twenty)
               MA_Twenty = NaN; 
            end  
            if isempty(MA_OneHundred)
               MA_OneHundred = NaN; 
            end 
            if isempty(MA_OneHundred)
               MA_OneHundred = NaN; 
            end 
            if isempty(DateEval)
               DateEval = NaN; 
            end
            if isempty(DateStart)
               DateStart = NaN;
            end
            if isempty(Change)
               Change = NaN; 
            end
            if isempty(Low)
               Low = NaN; 
            end
            if isempty(High)
               High = NaN; 
            end
            if isempty(Change)
               Change = NaN; 
            end
            if isempty(ThreeMnthsVol)
               ThreeMnthsVol = NaN;
            end
            if isempty(TenDysVol)
               TenDysVol = NaN;
            end
            PriceAndMovingAvText = {PriceAndMovingAvText};
            BollingerBands = {BollingerBands};
            Signal = {Signal};
            Stars = {Stars};
            Symbol = {Symbol};
            DATASET = ...
            dataset(Symbol, ...
                    TargetsSixMonths, ...
                    SupportOne, ...
                    SupportTwo, ...
                    ResistanceOne, ...
                    TargetOneYear, ...
                    ResistanceTwo, ...
                    PivotPointStart, ...
                    MA_Five, ...
                    MA_Twenty, ...
                    MA_OneHundred, ...
                    MA_TwoHundredAndFifty, ...
                    K, ...
                    D, ...
                    RSI, ...
                    High, ...
                    Low, ...
                    TenDysVol, ...
                    Change, ...
                    ThreeMnthsVol, ...
                    PriceAndMovingAvText, ...
                    BollingerBands, ...
                    Rating, ...
                    Signal, ...
                    Stars, ... 
                    DateEval);        
        end
        function DATASET = ProcessALL(obj,Symbols,Date)
            %%
            [x] = size(Symbols,1); 
            Symbol = strrep(Symbols{1},'.L','');
            [s, Error] = obj.LoadURLs('Stox','Best_Investments',Symbol,Date);
%             s = LoadURL(obj,Symbols{1},Date);
            if Error == 0   
                DATASET = obj.DecodeURL(s,Symbol);
            else
                disp(['Can''t find ',Symbols{1}])
            end
            for i = 2:x
                waitbar(i/x)
                drawnow
                Symbol = strrep(Symbols{i},'.L','');
                [s, Error] = obj.LoadURLs('Stox','Best_Investments',Symbol,Date);
                if Error == 0  
                    NEWDATASET = obj.DecodeURL(s,Symbol);
                    DATASET = [DATASET;NEWDATASET];
                else
                    disp(['Can''t find ',Symbols{i}])
                end
            end                                     
        end
    end
    methods (Hidden = true)
        function [obj] = Stox(varargin)
            [x] = size(varargin,2);
            for i = 1:2:x
                obj.(varargin{i}) = varargin{i+1};
            end
            obj.ProgramName = 'Stox';
            
            %%
            if isempty(obj.InstallDir)
                name = which(obj.ProgramName);
                obj.InstallDir = strrep(name,[obj.ProgramName,'.m'],'');                
            end
                    
            
            if strcmpi(obj.RunOnInt,'on')
                obj.Macro
                obj.RunMacro(obj.Macro);
            end
            if strcmpi(obj.CloseGUIwhenComplete,'on')
                close(obj.handles.figure)
            end     
            warning on
        end
    end
end