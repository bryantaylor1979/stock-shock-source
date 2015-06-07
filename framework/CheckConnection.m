classdef CheckConnection
    properties
    end
    methods
        function Check(obj)
            %%
            urlread('http://192.168.1.1/')
        end
        function Reliability
            %%
            h = waitbar(0);
            UserEnd = false;
            Successfull = 0;
            UnSuccessfull = 0;
            State = 0;
            while UserEnd == false;
                %User exit test. (If you close the waitbar) 
                try 
                    get(h,'Visible');
                    UserEnd = false;
                catch
                    UserEnd = true;
                end
                
                try
                    s = urlread('http://www.shareprice.co.uk/');
                    Successfull = Successfull + 1;
                    pause(1);
                catch
                    UnSuccessfull = UnSuccessfull + 1;
                    pause(1);
                end
                drawnow;
                State = not(State);
                waitbar(State,h,['Successfull: ',num2str(Successfull),' - UnSuccessfull:',num2str(UnSuccessfull)]);
            end
        end
    end
end