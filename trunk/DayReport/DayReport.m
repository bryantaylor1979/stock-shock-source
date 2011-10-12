classdef DayReport < handle
    properties
        InvestedSymbolList =   {'JPR'; ...
                                'PPA'; ...
                                'EIL'; ...
                                'HAWK'; ...
                                'FPM'; ...
                                'PCF'; ...
                                'PCI'; ...
                                'RENE'}                     
        EmailAdd = {'bryan.taylor@talktalk.net'; ...
                    'bryan.taylor@st.com'; ...
                    }
        ProgramName = 'Day Report'
        DocFormat = '-fpdf'   % -fdoc, -fpdf
        FT_Table
        FT_LastDate
        WBS_Table
        BB_Table
        BB_Table2
        Rev = 0.07
        UpdateRate = 60*60*24 % Once a Day
        InstallDir = 'C:\SourceSafe\Stocks & Shares\Programs\DayReport\'
    end
    %Rev 0.04   Error fixed in DownloadData. Caused when timeout occurs.
    %Rev 0.05   Add varaiable inputs.
    %Rev 0.06   Sendmail error supression
    %Rev 0.07   Add FT support
    methods
        function [obj] = DayReport(varargin)
            %
            [x] = size(varargin,2);
            for i = 1:2:x
                obj.(varargin{i}) = varargin{i+1};
            end
            
            obj.BuildDocument;
            obj.GenerateReport;
            obj.SendEmail;
        end
        function GenerateReport(obj)
            global BB_Table WBS_Table FT_Table FT_LastDate BB_Table2
            FT_Table = obj.FT_Table
            WBS_Table = obj.WBS_Table;
            BB_Table = obj.BB_Table;
            BB_Table2 = obj.BB_Table2;
            FT_LastDate = obj.FT_LastDate;
            
            CrDr = pwd;
            cd([obj.InstallDir,'Reports\'])
            pause(1);
            drawnow;
            filename = [obj.InstallDir,'Reports\',datestr(today,1),'.xml'];
            report([obj.InstallDir,'DayReport.rpt'],['-o',filename]);
            RPTNAME = rptconvert(filename,'pdf',[obj.InstallDir,'verbose2.rgs'])
            cd(CrDr)
            open(RPTNAME)
        end
        function BuildDocument(obj)
            obj.BritishBulls;
            obj.FT_BrokersView;
            obj.WhatBrokersSay;
        end
    end
    methods %Sections
        function FT_BrokersView(obj)
            try
                %%
                directory = 'C:\SourceSafe\Stocks & Shares\Programs\FT_BrokersView\Results\Invested\';
                cd(directory);
                names = rot90(struct2cell(dir));
                names = names(1:end-2,1);
                n = find(not(strcmpi(names,'FT.iqy')));
                names = names(n);
                latest = max(datenum(strrep(names,'.xls','')));
                %%
                [Data,Num,Raw] = xlsread(['C:\SourceSafe\Stocks & Shares\Programs\FT_BrokersView\Results\Invested\',datestr(latest,1),'.xls']);
                obj.FT_Table = Raw;
                obj.FT_LastDate = latest;
            catch
               obj.FT_Table = {'No Data Available'};
            end
        end
        function WhatBrokersSay(obj)
            try
               [Data,Num,Raw] = xlsread(['C:\SourceSafe\Stocks & Shares\Programs\What Brokers Say\Results\InvestedSymbols\',datestr(today,1),'.xls']);
               obj.WBS_Table = Raw;
            catch
               obj.WBS_Table = {'No Data Available'};
            end
        end
        function BritishBulls(obj)
            %%
            try
               [Data,Num,Raw] = xlsread(['C:\SourceSafe\Stocks & Shares\Programs\BritishBulls\Results\InvestedSymbols\',datestr(today,1),'.xls']);
               obj.BB_Table = Raw;
            catch
               obj.BB_Table = {'No Data Available'};
            end
            
            %%
            try
               [Data,Num,Raw] = xlsread(['C:\SourceSafe\Stocks & Shares\Programs\BritishBulls\Results\INVESTED_STATUS\xls\',datestr(today,1),'.xls']);
               obj.BB_Table2 = Raw;
            catch
               obj.BB_Table2 = {'No Data Available'};
            end
        end
    end
    methods (Hidden = true)
        function SendEmail(obj)
            %% 
            setpref('Internet','SMTP_Server','smtp.talktalk.net');
            setpref('Internet','E_mail','bryan.taylor@talktalk.net');
            string = [obj.InstallDir,'Reports\',datestr(today,1),'.pdf'];
            try
            sendmail(   obj.EmailAdd, [obj.ProgramName,' - ',datestr(now)], ...
                         {'Program details: '; ...
                         ['Name: ',obj.ProgramName]; ...
                         ['Rev: ',num2str(obj.Rev)]; ...
                         ['Date: ',datestr(now)]; ...
                         }, ...
                         {string}); 
            catch
%                 obj.CheckConnection;
                try
                sendmail(   obj.EmailAdd, [obj.ProgramName,' - ',datestr(now)], ...
                         {'Program details: '; ...
                         ['Name: ',obj.ProgramName]; ...
                         ['Rev: ',num2str(obj.Rev)]; ...
                         ['Date: ',datestr(now)]; ...
                         }, ...
                         {string}); 
                catch
                    disp('Send mail failed')
                end
            end
        end
    end
end%%



