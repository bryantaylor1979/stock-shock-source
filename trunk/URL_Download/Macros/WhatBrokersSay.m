
obj.sURL = 'http://www.digitallook.com/dlmedia/investing/uk_shares/broker_ratings.cgi?&story_category_id=0212&ac=212437&username=bryantaylor&action=broker_ratings&orderby_field=date&selected_menu_link=/dlmedia/investing/uk_shares/broker_views&limitstart=';
obj.eURL = '';
obj.timeout = 2;
Method = 'URL';

obj.timeout = 2; %2 - only attempted once

ProgramName = 'WhatBrokersSay';
ResultName = 'BrokersView';
MacroName = 'WhatBrokersSay';

Date = floor(now);
Date = obj.GetStoreDate(Date);

Symbols = { '0' ; ...
            '50'; ...
            '100'};
        
obj.SaveALL(Method,Symbols,ProgramName,ResultName,Date, MacroName);
