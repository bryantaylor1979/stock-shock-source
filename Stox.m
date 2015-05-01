classdef Stox < handle & ...
                InvestedSymbols & ...
                Comms
    properties
        GUI_Mode = 'User';                              %Minimal or Full or User                              
        CloseGUIwhenComplete = 'off';                   %{'off','on'} When on the program will close when macro is complete.
    end
    properties (Hidden = true)
        Conn
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