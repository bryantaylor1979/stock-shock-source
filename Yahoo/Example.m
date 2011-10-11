%% BB + Spread
obj = Yahoo('RunOnInt',     'on', ...
            'MacroName',    'SpreadBuyIf');
        
%% BB + Real-Time Confirmation
obj = Yahoo('RunOnInt',     'on', ...
            'MacroName',    'ConfirmationRT');
        
%% BB + Spread
obj = Yahoo('RunOnInt',     'on', ...
            'MacroName',    'Spread');
        
%% BB + Real-Time Confirmation
obj = Yahoo('RunOnInt',     'on', ...
            'MacroName',    'SellConfirmationDay');
        
%% BB + Real-Time Confirmation
obj = Yahoo('RunOnInt',     'on', ...
            'MacroName',    'SellConfirmationRT');
        
%% 
obj = Yahoo('RunOnInt',     'on', ...
            'MacroName',    'ConfirmationInvestedRT');
        
        
%% 
obj = Yahoo('RunOnInt',     'on', ...
            'MacroName',    'Winners');

%%
obj = Yahoo('RunOnInt',     'on', ...
            'MacroName',    'MasterSyncDayEnd');