
FieldNames={'PC_Name',			'ProgramName',	    'MacroName',		    'StartTime','Type'};

table   =  {'BRYAN_PC',  		    'URL_Download',     'BritishBulls_ALLSTATUS',       '20:00:00', 'WeekDaysOnly'; ...
            'BRYAN_PC',  		    'URL_Download',     'ADVFN_URL_CompanyInfo',        '19:01:00', 'WeekDaysOnly'; ...
            'BRYAN_PC',  		    'URL_Download',     'BritishBulls_HIST',            '19:10:00', 'WeekDaysOnly'; ...
            'BRYAN_PC',  		    'URL_Download',     'DigitalLook_Symbol2Num_URL',   '19:11:00', 'WeekDaysOnly'; ...
            'BRYAN_PC',  		    'URL_Download',     'NewsAlerts_RNS',               '19:09:00', 'WeekDaysOnly'; ...
            'BRYAN_PC',  		    'URL_Download',     'SharePrice_Summary',           '23:12:00', 'WeekDaysOnly'; ...
            'BRYAN_PC',  		    'URL_Download',     'FT_Analysis',                  '23:40:00', 'WeekDaysOnly'; ...
            'BRYAN_PC',  		    'URL_Download',     'FT_Performance',               '23:20:00', 'WeekDaysOnly'; ...
            'BRYAN_PC',  		    'URL_Download',     'Stox',                         '21:08:00', 'WeekDaysOnly'; ...
            'BRYAN_PC',  		    'URL_Download',     'WhatBrokersSay',               '21:00:00', 'WeekDaysOnly'; ...
            'MediaPc',              'URL_Download',     'BritishBulls_ALLSTATUS',       '19:00:00', 'WeekDaysOnly'; ...
            'MT',               	'URL_Download',     'ADVFN_URL_CompanyInfo',        '20:50:00', 'WeekDaysOnly'; ...
            'MT',               	'URL_Download',     'BritishBulls_HIST',            '20:55:00', 'WeekDaysOnly'; ...
            'MT',               	'URL_Download',     'DigitalLook_Symbol2Num_URL',   '20:55:00', 'WeekDaysOnly'; ...
            'MT',               	'URL_Download',     'NewsAlerts_RNS',               '20:50:00', 'WeekDaysOnly'; ...
            'MediaPc',             	'URL_Download',     'SharePrice_Summary',           '19:00:00', 'WeekDaysOnly'; ...
            'MT',               	'URL_Download',     'FT_Analysis',                  '19:03:00', 'WeekDaysOnly'; ...
            'MT',               	'URL_Download',     'FT_Performance',               '18:59:00', 'WeekDaysOnly'; ...
            'MT',               	'URL_Download',     'NakedTrader',                  '21:01:00', 'WeekDaysOnly'; ...
            'MediaPc',      		'URL_Download',     'Stox',                         '19:02:00', 'WeekDaysOnly'; ...
            'MediaPc',              'URL_Download',     'WhatBrokersSay',               '19:13:00', 'WeekDaysOnly';...
            'MediaPc',              'URL_Download',     'NakedTrader',                  '19:30:00', 'WeekDaysOnly';...
	    ...
            'BRYAN_PC',             'WebPageDecoder',   'ADVFN_ProcessDay',             '00:00:01', 'WeekDaysOnly'; ...
            'BRYAN_PC',             'WebPageDecoder',   'BB_HIST_Decode',               '00:00:01', 'WeekDaysOnly'; ...
            'MediaPc',          	'WebPageDecoder',   'BB_ALL_STATUS_Decode',         '00:00:01', 'WeekDaysOnly'; ... 
            'MediaPc',          	'WebPageDecoder',   'DL_Str2Num_ProcessDay',        '00:00:02', 'WeekDaysOnly' ... 
        };


DATASET.table = table;
DATASET.FieldNames = FieldNames;