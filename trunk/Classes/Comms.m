classdef Comms < handle & ...
                 dynamicprops & ...
                 Properties2Store
    properties
        MaxSMSperDay = 5;
        EmailAdd = {'bryan.taylor@talktalk.net'; ...
                    'bryan.taylor@st.com'; ...
                    };   
        ftphandle
    end
    methods
        function UploadProgram(obj,File)
            %%
            handle = ftp('ftp.drivehq.com','bryantaylor','tango224');
            cd(handle,'Programs/');
            try
            mput(handle,File)
            end
            %%
            close(handle);
        end
        function SendFtp(obj,filename,directory,host,user,password)
            if isempty(obj.ftphandle)
                obj.ftphandle = ftp(host,user,password);
                pasv(obj.ftphandle);
            end           
            try
            cd(obj.ftphandle,directory);
            end
            try
                mput(obj.ftphandle,filename)
            catch
                close(obj.ftphandle);
                error('ftp upload error')
            end
        end
        function SendEmail(obj,DataSet,Caption)
            %%
            VarNames = get(DataSet,'VarNames');
            DATA1 = obj.FormatTable(DataSet);
            DATA2 = [VarNames;DATA1];
            %% 
            string = [obj.InstallDir,'Data.xls'];
            try
                warning off
                delete(string);
                warning on
            end
            try
                xlswrite(string,DATA2);
            catch
                disp(['Path: ',string])
                warning('Problem writing xls file. Now writing to Data1.xls'); 
                string = [obj.InstallDir,'Data1.xls'];
                xlswrite(string,DATA2);
            end
            disp('Complete')
            %
            setpref('Internet','SMTP_Server','smtp.talktalk.net');
            setpref('Internet','E_mail','bryan.taylor@talktalk.net');
            sendmail(   obj.EmailAdd,[obj.ProgramName,' (',Caption,')-',datestr(now)], ...
                        {'Program details: '; ...
                         ['Name: ',obj.ProgramName]; ...
                         ['Rev: ',num2str(obj.Rev)]; ...
                         }, ...
                         {[obj.InstallDir,'Data.xls']});  
            disp('E-mail sent')
        end
        function SendSMS(obj,Number,Message)
            % Check credit
            if obj.SMS_Credit == 0 
                disp('No Credit available')
                return
            end
            
            % Check enable
            if obj.SMS_Enable == false
                disp('SMS has been disable')
                return
            end
            
            % Check daily allowance
            if obj.LastSMS_DateNum == today
                if obj.SMS_NoSentToday == obj.MaxSMSperDay 
                    disp('Exceed max allowance')
                    return
                end
                obj.SMS_NoSentToday = obj.SMS_NoSentToday + 1;
                disp([num2str(obj.SMS_NoSentToday),' SMS have been sent today'])
            else
                obj.LastSMS_DateNum = today;
                obj.SMS_NoSentToday = 1;
            end
            
            % Send SMS
            setpref('Internet','SMTP_Server','smtp.talktalk.net');
            setpref('Internet','E_mail','bryan.taylor@talktalk.net'); 
            sendmail(    [Number,'@txtlocal.co.uk'], ...
                         'hello', ...
                         Message);  
            obj.SMS_Credit = obj.SMS_Credit - 1;
        end
        function SendEmail2(obj,DataSet,Caption,String)
            %%
            if not(isempty(DataSet))
                VarNames = get(DataSet,'VarNames');
                DATA1 = obj.FormatTable(DataSet);
                DATA2 = [VarNames;DATA1];
                %% 
                string = [obj.InstallDir,'Data.xls'];
                try
                   delete(string);
                end
                try
                    xlswrite(string,DATA2);
                catch
                    disp(['Path: ',string])
                    error('Problem writing xls file'); 
                end
                disp('Complete')
            end
            %%
            NewString = [   String; ...
                           {['Program details: ']; ...
                            ['Name: ',obj.ProgramName]; ...
                            ['Rev: ',num2str(obj.Rev)]}];
            %%
            setpref('Internet','SMTP_Server','smtp.talktalk.net');
            setpref('Internet','E_mail','bryan.taylor@talktalk.net');
            if isempty(DataSet)
                sendmail(   obj.EmailAdd,[obj.ProgramName,' (',Caption,')-',datestr(now)], ...
                            NewString);  
            else
                sendmail(   obj.EmailAdd,[obj.ProgramName,' (',Caption,')-',datestr(now)], ...
                            NewString, ...
                            {[obj.InstallDir,'Data.xls']});                  
            end
            disp('E-mail sent')
        end
        function LoadDistributionList(obj,Name)
              file = textread([obj.DistributionDir,Name],'%s','delimiter','\n','whitespace','');
              [x] = size(file,1);
              for i = 1:x
                  eval(file{i});
              end
              obj.EmailAdd = EmailAdd;
        end  
    end
end