%% Invested Symbol Update
obj = FinicialTimes(    'Visible','off', ...
                        'GUI_Mode','Minimal', ...
                        'Macro','Invested', ...
                        'Mode','wq', ...
                        'ForceUpdate','on', ...
                        'CloseGUIwhenComplete','on', ...
                        'RunOnInt','on');
                    
%% Sync Symbol Update
clear classes
obj = FinicialTimes(    'Visible','off', ...
                        'GUI_Mode','Minimal', ...
                        'Macro','Sync', ...
                        'CloseGUIwhenComplete','on', ...
                        'RunOnInt','on');
                    
%% Sync Symbol Update
obj = FinicialTimes(    'Visible','off', ...
                        'GUI_Mode','Minimal', ...
                        'Macro','BestInvestments', ...
                        'CloseGUIwhenComplete','on', ...
                        'RunOnInt','on');  
                    
%% Sync Performance Data
obj = FinicialTimes(    'Visible','off', ...
                        'GUI_Mode','Minimal', ...
                        'Macro','DownloadPerformance', ...
                        'CloseGUIwhenComplete','on', ...
                        'RunOnInt','on');     
                    
%% URL_Performance2Results
obj = FinicialTimes(    'Visible','off', ...
                        'GUI_Mode','Minimal', ...
                        'Macro','URL_Performance2Results', ...
                        'CloseGUIwhenComplete','on', ...
                        'RunOnInt','on');     
                    
%% Sync Performance Data
obj = FinicialTimes(    'Visible','off', ...
                        'GUI_Mode','Minimal', ...
                        'Macro','BUY_IF', ...
                        'CloseGUIwhenComplete','on', ...
                        'RunOnInt','on');
                    
%% Broker Updates Data
obj = FinicialTimes(    'Visible','off', ...
                        'GUI_Mode','Minimal', ...
                        'Macro','BrokerUpdates', ...
                        'CloseGUIwhenComplete','on', ...
                        'RunOnInt','on');
                    
%% Open on Up beat pc
obj = FinicialTimes(    'InstallDir',   'A:\Stocks & Shares\Programs\FT_BrokersView\', ...
                        'RootDir',      'A:\Stocks & Shares\Programs\');
                    