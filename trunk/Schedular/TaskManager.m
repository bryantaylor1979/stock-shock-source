classdef TaskManager < handle
    methods
        function DATASET = ReadTaskList(obj)
            %% 
            filename = obj.RunTaskList;
            drawnow
            DATASET = obj.TaskListFile2DataSet(filename);
        end
        function filename = RunTaskList(obj)
            filename = ['TaskList__',strrep(datestr(now),':','_'),'.txt'];
            diary(filename);
            dos('TaskList');
            drawnow
            diary off;
        end
        function DATASET = TaskListFile2DataSet(obj,filename)
            %%
            [p] = textread(filename,'%s','delimiter','\n','whitespace','');
            Strings = cell2mat(p(2:end));
            
            ImageName = Strings(3:end,1:26);
            x = size(ImageName,1);
            for i = 1:x
                Name{i,1} = strrep(ImageName(i,:),' ','');
            end
            ImageName = Name;
            
            PID = Strings(3:end,27:35);
            x = size(PID,1);
            for i = 1:x
                PID_(i,1) = str2num(strrep(PID(i,:),' ',''));
            end
            PID = PID_;
            
            SessionName = Strings(3:end,36:53);
            x = size(SessionName,1);
            for i = 1:x
                Name{i,1} = strrep(SessionName(i,:),' ','');
            end
            SessionName = Name;
            
            
            Session = Strings(3:end,53:65);
            x = size(Session,1);
            for i = 1:x
                Session_(i,1) = str2num(strrep(Session(i,:),' ',''));
            end
            Session = Session_;
            
            MemUsage = Strings(3:end,65:end); 
            x = size(MemUsage,1);
            for i = 1:x
                MemUsage_(i,1) = str2num(strrep(strrep(MemUsage(i,:),'K',''),',',''));
            end
            MemUsage = MemUsage_;            

            
            DATASET = dataset(ImageName,PID,SessionName,Session,MemUsage);            
        end
    end
end