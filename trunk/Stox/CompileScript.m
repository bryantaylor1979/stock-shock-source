classdef CompileScript
    properties
        PreFix = 'v';
        PointSeparator = '.';   
        ProgramName = 'Stox';
        FilesNeeded = 'III_IndexMap';
        LastRev
        NewRev
        InstallDir = 'C:\SourceSafe\Stocks & Shares\Programs\Stox\';
    end
    methods
        function [obj] = CompileScript(obj)
            obj = obj.GetLastRev;
            ButtonName = questdlg('Do you want to create a new rev?', ...
                         ['Current Rev: ',num2str(obj.LastRev)], ...
                         'New', 'Overwrite', 'New');
                     
            switch ButtonName
                case 'New'
                    obj.NewRev = obj.LastRev + 0.01;
                    disp(['New Rev No: ',num2str(obj.NewRev)])
                    mkdir([obj.InstallDir,'Compiled\',obj.PreFix,strrep(num2str(obj.NewRev),'.',obj.PointSeparator),'\'])
                case 'Overwrite'
                    obj.NewRev = obj.LastRev;
                otherwise
            end
            
            fid = fopen([obj.InstallDir,'Compiled\',obj.PreFix,strrep(num2str(obj.NewRev),'.',obj.PointSeparator),'\',obj.ProgramName,'.bat'],'wt');
            if fid == -1
                disp('Error creating file')
                return
            end
            fprintf(fid,[obj.ProgramName,' "Rev" ',num2str(obj.NewRev)]);
            fclose(fid);
            
            fid = fopen([obj.InstallDir,'Compiled\Latest\',obj.ProgramName,'.bat'],'wt');
            fprintf(fid,[obj.ProgramName,' "Rev" ',num2str(obj.NewRev)]);
            fclose(fid);   
            
            obj.Compile;
            
            copyfile([obj.InstallDir,'Compiled\Latest\*.*'],[obj.InstallDir,'Compiled\',obj.PreFix,strrep(num2str(obj.NewRev),'.',obj.PointSeparator),'\'])
        end
        function [obj] = GetLastRev(obj);
            %%
            cd([obj.InstallDir,'Compiled\'])
            names = dir;
            names = struct2cell(names);
            names = rot90(names(1,:,1));
            n = strmatch(obj.PreFix,names);
            names = strrep(names(n),obj.PreFix,'');
            names = str2double(strrep(names,obj.PointSeparator,'.'));
            obj.LastRev = max(names);
        end
        function Compile(obj)
            %%
            try
            mcc('-m', [obj.ProgramName], obj.FilesNeeded,'-d',[obj.InstallDir,'Compiled\Latest\'])
            catch
               disp('Error compiling, ensure the program is closed') 
            end
        end
    end
end