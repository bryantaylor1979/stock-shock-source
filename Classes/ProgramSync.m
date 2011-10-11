classdef ProgramSync <      handle & ...
                            DataSetFiltering
	properties
        domain = 'wfoote.com';
        user = 'shares';
        password = 'cormorant'; 
        ftphandle
    end
    methods
        function SyncProgram(obj,ProgramName,Rev)
            %%
            names1 = obj.GetLocalFileList(ProgramName,Rev);
            names2 = obj.GetFtpFileList(ProgramName);
            DATASET = obj.CompareDirectory(names1,names2);
              
            FileName = obj.GetColumn(DATASET,'FileName');
            RequireUpdating = obj.GetColumn(DATASET,'RequireUpdating');
            n = find(RequireUpdating == true);
            FileName = FileName(n);
            x = size(FileName,1);
            for i = 1:x
                 obj.UploadFile(ProgramName,Rev,FileName{i});  
            end
        end
        function UploadPrograms(obj)
            %%
            obj.SyncProgram('Yahoo','R0-05')                              
            obj.SyncProgram('Stox','R0-07');
            obj.SyncProgram('FinicialTimes','R0-15');
            obj.SyncProgram('DigitalLook','R0-01');
            obj.SyncProgram('BritishBulls','R0-15');         
        end
    end
    methods (Hidden = true)
        function DATASET = CompareDirectory(obj,names1,names2)
            % names1 2 cell array 
            Cell = rot90(struct2cell(names1),1);
            Cell1 = Cell(1:end-2,:);
            
            % names2 2 cell array 
            Cell2 = rot90(struct2cell(names2),1);

            
            % Get Combine List of filenames.
            FileNames1Array = Cell1(:,1);
            FileNames1 = dataset({FileNames1Array,'FileName'});
            FileNames2Array = Cell2(:,1);
            FileNames2 = dataset({FileNames2Array,'FileName'});
            FileName = sortrows([FileNames1; FileNames2]);
            
            x = size(FileName,1);
            Files = FileName(1,1);
            for i = 2:x
                logic = strcmpi(FileName{i-1,1},FileName{i,1});
                if logic == 0
                    Files = [Files;FileName(i,1)];
                end
            end
            
            % Find which file are new
            x = size(Files,1);
            for i = 1:x
                %Present 1
                n = find(strcmpi(Files{i,1},FileNames1Array));
                if isempty(n)
                    IsPresent1(i,1) = false;
                    Size1(i,1) = NaN;
                else
                    IsPresent1(i,1) = true;
                    Size1(i,1) = Cell1{n,3};
                end
                
                %Present 2
                n = find(strcmpi(Files{i,1},FileNames2Array));
                if isempty(n)
                    IsPresent2(i,1) = false;
                    Size2(i,1) = NaN;
                else
                    IsPresent2(i,1) = true;
                    Size2(i,1) = Cell2{n,3};
                end
            end
            
            %Require Updating
            for i = 1:x
                if IsPresent2(i,1) == false %File not found in FTP.
                    RequireUpdating(i,1) = true;
                elseif not(Size1(i,1) == Size2(i,1)) %File 
                    RequireUpdating(i,1) = true;
                else
                    RequireUpdating(i,1) = false;
                end
            end
            
            DATASET = [Files,dataset(IsPresent1,IsPresent2,Size1,Size2,RequireUpdating)];
        end
        function UploadFile(obj,ProgramName,Rev,filename)
            obj.SendFtp(    ['C:\Tasks\',ProgramName,'\',Rev,'\',filename], ...
                            ['httpdocs/Programs/']);
        end
        function SendFtp(obj,filename,directory)
            if isempty(obj.ftphandle)
                obj.ftphandle = ftp(obj.domain,obj.user,obj.password);
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
        function names = GetFtpFileList(obj,ProgramName)
            %%
            if isempty(obj.ftphandle)
                obj.ftphandle = ftp(obj.domain,obj.user,obj.password);
                pasv(obj.ftphandle);  
            end
            cd(obj.ftphandle,['/httpdocs/Programs/',ProgramName,'/']);
            names = dir(obj.ftphandle);
        end  
        function names = GetLocalFileList(obj,ProgramName,Rev)
            %%
            cd(['C:\Tasks\',ProgramName,'\',Rev,'\'])
            names = dir;
        end         
    end
end