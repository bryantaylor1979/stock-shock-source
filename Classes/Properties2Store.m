classdef Properties2Store < handle & ...
                            dynamicprops
    properties (Hidden = true)
       PS_handles
       DataPath = 'A:\Stocks & Shares\Programs\Classes\CommsData\';
       Parameters = {   'SMS_NoSentToday', 0; ...
                        'SMS_Credit',      100; ...
                        'SMS_Enable',      false; ...
                        'LastSMS_DateNum', 0}
    end
    methods (Hidden = true)
        function struct = CreateSMSStatusFromDefaults(obj)
            %%
            struct.SMS_NoSentToday = obj.SMS_NoSentToday;
            struct.SMS_Credit = obj.SMS_Credit;
        end
        function [struct,error] = LoadSMSStatus(obj)
            try
                load([obj.DataPath,'SMSstatus.mat'])
                error = 0;
            catch
                error = -1;
                struct = [];
            end
        end
        function SaveSMSStatus(obj,struct)
            save([obj.DataPath,'SMSstatus.mat'],'struct')
        end
        function GetListener(obj,src,evnt)
            switch src.Name
                case obj.Parameters
                     struct = obj.LoadSMSStatus;
                     
                     x = size(obj.Parameters,1);
                     for i = 1:x
                         PropName = obj.Parameters{i};
                         obj.PS_handles.(PropName).SetObservable = false;
                         obj.(PropName) = struct.(PropName);
                         obj.PS_handles.(PropName).SetObservable = true;
                     end
                otherwise
            end
        end
        function SetListener(obj,src,evnt)
            switch src.Name
                case obj.Parameters
                     x = size(obj.Parameters,1);
                     
                     for i = 1:x
                         PropName = obj.Parameters{i};
                         obj.PS_handles.(PropName).GetObservable = false;
                         struct.(PropName) = obj.(PropName);
                     end
                     obj.SaveSMSStatus(struct);
                     for i = 1:x
                         PropName = obj.Parameters{i};
                         obj.PS_handles.(PropName).GetObservable = true;
                     end
                otherwise
            end
        end
        function obj = Properties2Store
            x = size(obj.Parameters,1);
            for i = 1:x % Create properties
                propname = obj.Parameters{i};
                obj.PS_handles.(propname) = addprop(obj,propname);
            end
            
            [struct,error] = obj.LoadSMSStatus;
            if error ==  -1; % Set defaults since no file exsits
                for i = 1:x
                    propname = obj.Parameters{i};
                    default = obj.Parameters{i,2};
                    obj.(propname) = default;
                    struct.(propname) = default;
                    obj.SaveSMSStatus(struct);
                end
            elseif error == 0 % Set propreties based on load file.  
                for i = 1:x 
                    propname = obj.Parameters{i};
                    obj.(propname) = struct.(propname);                  
                end
            end
            
            for i = 1:x % Set properties
                propname = obj.Parameters{i};
                
                obj.PS_handles.(propname).SetObservable = true;
                obj.PS_handles.(propname).GetObservable = true;

                try
                obj.addlistener(propname,'PostSet',@(src,evnt)SetListener(obj,src,evnt));
                obj.addlistener(propname,'PostGet',@(src,evnt)GetListener(obj,src,evnt));
                end
            end
        end
    end
end