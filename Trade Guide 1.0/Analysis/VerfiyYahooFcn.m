function [Output] = VerifyYahooFcn(varargin)
%Calculate the number of symbols on each day.
%
%InputArray - Output from symbol information.
%Database must be intialised.
%
%Example: 
%IntialiseDatabase;
%[OutPutArray] = SymbolInformation();
%[startdateout,enddateout] = NumberOfSymbolsPerDay(MinimumThreshold,InputArray)
%
%Written by: Bryan Taylor
%Date Created: 3rd January 2008
%Date Modified: 3rd January 2008

global h

%% Column Names Declarations
try
if strcmpi(varargin{1},'ColumnNames')
    Output = {  'Yahoo Symbol'; ...
                'SymbolUnknown'; ...
                'InLocalBase'; ...
                'Status'; ...
                'TableAdded'; ...
                };
    return
end
end

%% Config Declarations
try
if strcmpi(varargin{1},'Config')
   Output = false; 
   return
end
end

%% Functional
[OutPutArray] = GetStageData('ImportInstruments');
try
conn = yahoo;
catch
uiwait(msgbox('Can''t connect to yahoo. Please check connection'));
Output = -1;
return
end
conn2 = database('SaxoTrader','','');
try
[tablelist] = GetAllTableNames(conn2);
catch %table list empty
tablelist = {''}; 
end
profile = '(datenum NUMBER PRIMARY KEY, close NUMBER, open NUMBER, low NUMBER, high NUMBER, volume NUMBER, closeadj NUMBER)';

[x] = size(OutPutArray,1);
% StatusBar(h.statusbar,0);
h1 = waitbar(0);
for j = 1:x
      waitbar(j/x,h1,['Processing ',num2str(j),' of ',num2str(x)]);
      set(h.Status,'String',['Processing... ',num2str(j),' of ',num2str(x),' (',num2str(round(j/x*100)),'%)']);
      TradeStructure(j).YahooSymbol =  OutPutArray{j,9};
      if not(strcmpi(OutPutArray{j,9},'N/A')) %if N/A suffix not found in last stage.
          SymbolUnknown = 'False';
          n = find(strcmpi(OutPutArray{j,10},tablelist));
          if not(isempty(n))
              InLocalBase = 'True';
              Status = 'N/A'; 
              Added = 'N/A';
          else
              InLocalBase = 'False';
              try
              D = fetch(conn,OutPutArray{j,9},'open',today-365,today,'m');
              clear D
              Status = 'Pass'; 
              try
                CreateTable(conn2,OutPutArray{j,10},profile);
                Added = 'True';
                catch
                Added = 'False';    
                end
              catch
                Status = 'Fail';  
                Added = 'False'; 
              end 
          end
      else
          SymbolUnknown = 'True';
          InLocalBase = 'N/A';
          Status = 'N/A'; 
          Added = 'N/A';
      end
      TradeStructure(j).SymbolUnknown = SymbolUnknown;
      TradeStructure(j).InLocalBase = InLocalBase;
      TradeStructure(j).Status = Status;
      TradeStructure(j).TableAdded = Added;
%       AddRow(RowInfo);
      clear RowInfo   
end
close(h1);
LoadStruct(h,TradeStructure);
close(conn2);
set(h.Status,'String',['100% Complete']);
Output = 1;