%Example 1: Loads without GUI,
%           Load "WatchList" Macro, which does the following:
%                  * Load data that from harddrive, 
%                  * Analysis Profit
%                  * Remove entry that are older than 14 days.
%                  * Filter on high profit stocks.
%                  * Save table to xls filename on harddrive and send e-mail with xls file attached.

%% Can be execute from the command prompt.
obj = WhatBrokersSay('Macro','Update','Visible','off');

%% Can be execute from the command prompt.
obj = WhatBrokersSay('Macro','WatchList','Visible','off');

%% Can be execute from the command prompt.
obj = WhatBrokersSay('Macro','InvestedAlerts','Visible','off');

%% Can be execute from the command prompt.
obj = WhatBrokersSay('Macro','InvestedSymbols','Visible','off');