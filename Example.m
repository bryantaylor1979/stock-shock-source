%% Sync
stox('Macro','Sync','RunOnInt','on','GUI_Mode','Minimal','CloseGUIwhenComplete','on')

%% Invested Symbol report.
obj = stox('Macro','Invested','RunOnInt','off','GUI_Mode','Minimal')

%% Retrieve Resistance And Support levels from a stox
obj = stox('GUI_Mode','Minimal');