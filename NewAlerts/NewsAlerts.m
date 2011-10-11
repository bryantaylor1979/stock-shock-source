classdef NewsAlerts <   handle & ...
                        InvestedSymbols & ...
                        Comms
    properties
        URL = 'http://www.iii.co.uk/rss/news/cotn:TW-.L.xml';
        xmlobj
        DataLocation = 'C:\SourceSafe\Stocks & Shares\Programs\NewAlerts\Data\';
        ProgramName = 'NewAlerts';
        Rev = 0.01
        EmailAdd
        DistributionDir = 'C:\SourceSafe\Stocks & Shares\Programs\What Brokers Say\';
    end
    methods (Hidden = false)
        function [obj] = NewsAlerts()
            %% 
            obj.LoadDistributionList('DistrubtionListMe.txt');
            [logic, NewData] = obj.SyncInvestedSymbolsNews;
            [x] = size(NewData,2);
            if logic == true
                for i = 1:x
                    String = ...
                    {   [NewData(i).Title]; ...
                        [NewData(i).Date]; ...
                        [NewData(i).NewsCaption]; ...
                        [NewData(i).Link];'';''}; ...
                    obj.SendEmail2([],'New',String);
                    String2 = { [NewData(i).Title]; ...
                                [NewData(i).Date]};
                    obj.SendSMS(String2);
                end
            end
        end
        function LoadDistributionList(obj,Name)
              file = textread([obj.DistributionDir,Name],'%s','delimiter','\n','whitespace','');
              [x] = size(file,1);
              for i = 1:x
                  eval(file{i});
              end
              obj.EmailAdd = EmailAdd;
        end
        function [struct] = GetSymbolNews(obj,Symbol)
            Symbol = strrep(Symbol,'_','-');
            Symbol = strrep(Symbol,'.','-');
            
            xDoc = parseXML(['http://www.iii.co.uk/rss/news/cotn:',Symbol,'.L.xml']);
            [x] = size(xDoc(1,2).Children(1,2).Children,2);
            for i = 8:2:x
                struct((i-6)/2) = obj.SingleNewsUpdate(xDoc,i);
            end
        end
        function [Updated,NewDatas] = SyncInvestedSymbolsNews(obj)
            obj.LoadInvestedSymbols('InvestedSymbolList.txt');
            [x] = size(obj.Symbols,1);
            NewDatas = [];
            for i = 1:x
                Symbol = obj.Symbols{i};
                if strcmpi(Symbol,'TW.L')
                    Symbol = 'TW-.L';
                end
                Symbol = strrep(Symbol,'.L','');
                Symbol = strrep(Symbol,'.','-');
                [logic,Data,NewData] = obj.IsOutOfDate(Symbol);
                NewDatas = [NewDatas,NewData];
                if logic == true
                    disp('Saved')
                    Symbol2Save = strrep(Symbol,'.L','');
                    Symbol2Save = strrep(Symbol2Save,'.','-');
                    obj.SaveData(NewData,Symbol2Save);
                end
                LOGIC(i) = logic;
            end
            NoUpdated = sum(LOGIC);
            disp([num2str(NoUpdated),' symbols updated'])
            if NoUpdated > 0 
                Updated = true;
            else
                Updated = false;
            end
        end
        function SaveData(obj,Data,Symbol)
             save([obj.DataLocation,Symbol],'Data');
        end
        function [Data,Error] = LoadData(obj,Symbol)
            try
                load([obj.DataLocation,Symbol])
                Error = 0;
            catch
                Data = []; 
                Error = -1;
            end
        end
        function [logic,OldData,NewDatas] = IsOutOfDate(obj,Symbol)
            [OldData,Error] = obj.LoadData(Symbol);
            NewData = obj.GetSymbolNews(Symbol);
            
            if Error == -1;
                NewDatas = NewData;
                logic = true;
                return
            end
            
            try
                Data = struct2cell(OldData);
            catch
                NewDatas = NewData;
                logic = true;
                return
            end
            [x] = size(Data,3);
            Data = reshape(Data(4,1,:),1,x);
            
            count = 0;
            NewDatas = [];
            [x] = size(NewData,2);
            for i = 1:x
                Date = NewData(i).Date;
                n = find(strcmpi(Data,Date));
                if isempty(n)
                    count = count + 1;
                    OldData = [OldData,NewData(i)];
                    NewDatas = [NewDatas,NewData(i)];
                else
                end
            end
            if count > 0
                logic = true;
            else
                logic = false;
            end
        end
    end
    methods (Hidden = true)
        function [struct] = SingleNewsUpdate(obj,xDoc,Num)
            struct.Title = xDoc(1,2).Children(1,2).Children(1,Num).Children(1,2).Children.Data;
            struct.Link = xDoc(1,2).Children(1,2).Children(1,Num).Children(1,4).Children.Data;
            struct.NewsCaption = xDoc(1,2).Children(1,2).Children(1,Num).Children(1,6).Children.Data;
            struct.Date = xDoc(1,2).Children(1,2).Children(1,Num).Children(1,8).Children.Data;
        end
    end
end