classdef CompileALL <   handle & ...
                        Comms
    properties
        McodePth = 'C:\SourceSafe\Stocks & Shares\Programs\';
        ExePth = 'C:\Tasks\';
    end
    methods
        function obj = CompileALL()
              % obj.Compile('FinicialTimes');
               obj.Compile('BritishBulls');
 %            obj.Compile('Yahoo');
%              obj.Compile('DigitalLook');
%               obj.Compile('Stox');
        end
    end
    methods (Hidden = true)
        function Compile(obj,ProgramName)
            %%
            PWD = pwd;
            
            McodePath = [obj.McodePth,ProgramName,'\'];
            ExePath = [obj.ExePth,ProgramName,'\'];  

            %% Get Rev Number
            cd(McodePath);
            String = ['obj = ',ProgramName,'(''GUI_Mode'',''Minimal'')'];
            try
            obj = feval(ProgramName,'GUI_Mode','Minimal');
            catch
            obj = feval(ProgramName);    
            end
            try
            close(obj.handles.figure)
            end
            Rev = obj.Rev;
            disp(['Program Rev No: ',num2str(Rev)]);

            %% Compile path string
            PATH = [McodePath,'Compiled\R',num2str(Rev),'\'];
%             try
%             cd(PATH);
%             catch
%             mkdir(PATH);    
%             end

            % Compile
            feval('mcc','-m',ProgramName,'III_IndexMap','SymbolInfo.m','-v','-d',PATH,'-I',McodePath);
            Path = [ExePath,'R',strrep(num2str(Rev,3),'.','-'),'\'];
            
            try
            cd(Path);
            catch
            mkdir(Path);    
            end           
            
            %Copy exe to folder.
            [SUCCESS,MESSAGE,MESSAGEID] = copyfile([PATH,ProgramName,'.exe'],Path,'f');
            cd(PWD)
        end
    end
end