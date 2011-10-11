function [Output] = Buy_Sell_SequenceFcn(varargin)
%
%Written by: Bryan Taylor
%Date Created: 3rd January 2008
%Date Modified: 3rd January 2008

global h

%% Column Names Declarations
try
if strcmpi(varargin{1},'ColumnNames')
    Output = {  'Date'; ...
                'Symbol'; ...
                'Action'; ...
                'Close'; ...
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

%% Variables
Mode = 'Silent';
path = 'C:\SourceSafe\Stocks & Shares\Programs\Trade Guide\SaveData\HistoricalDayBestInvestments_Mat\';

%% function
[list] = GetDateList();
[NoOfInvestments] = GetNumberOfInvestments();
InvestedSymbols = [];

[x] = size(list,1);
for j = 1:x
      %% Update GUI
      set(h.Status,'String',['Processing... ',num2str(j),' of ',num2str(x),' (',num2str(round(j/x*100)),'%)']);
      drawnow;
      
      %% Load Date Short List
      String = [path,'Histroical_',num2str(list(j)),'.mat'];
      load(String);
      
      %% In Var
      SellRows = {};
      BuyRow = {};
      
      %% Sell Symbols
      if not(isempty(InvestedSymbols))
          [newsymbolset] = StockQuoteMatQuery(InvestedSymbols,list(j));
          n = find(cell2mat(newsymbolset(:,11))==0);
          SellSymbols = newsymbolset(n,:);
          [p] = size(SellSymbols,1);
          for i = 1:p
             SellRows{i,1} = num2str(list(j));
             SellRows{i,2} = SellSymbols{i,1};
             SellRows{i,3} = 'Sell';
             SellRows{i,4} = SellSymbols{i,3};
          end
          n = find(cell2mat(newsymbolset(:,11))==1);
          InvestedSymbols = InvestedSymbols(n);
      end
      
      %% Buy Symbols
      [y] = size(InvestedSymbols,1);
      NoOfInvestmentsRequired = NoOfInvestments-y;
      [BuySymbols] = RemoveSymbols(symbolset,InvestedSymbols,NoOfInvestmentsRequired);

      [p] = size(BuySymbols,1);
      for i = 1:p
          BuyRow{i,1} = num2str(list(j));
          BuyRow{i,2} = BuySymbols{i};
          BuyRow{i,3} = 'Buy';
          BuyRow{i,4} = symbolset{i,3};
      end
      InvestedSymbols = [InvestedSymbols;BuySymbols];
      
      %% Build Table Info
      if j == 1
          Data = BuyRow;
      else
          Data = [Data;SellRows;BuyRow];
      end     
      
      %% Update GUI
      if strcmpi(Mode,'Visual')
         set(h.table,'Data',Data);
      end
end

if strcmpi(Mode,'Silent')
    set(h.table,'Data',Data);
end
set(h.Status,'String',['Ready']);
Output = 1;

function [list] = GetDateList();
path = 'C:\SourceSafe\Stocks & Shares\Programs\Trade Guide\SaveData\HistoricalDayBestInvestments_Mat\';
cd(path);
filenames = dir;
names = struct2data(filenames,'name');
[x] = size(names,1);
list = names(3:x);
list = strrep(list,'.mat','');
list = strrep(list,'Histroical_','');
list = str2double(list);

function [NoOfInvestments] = GetNumberOfInvestments()
%Written by:    Bryan Taylor
%Date Created:  30th April 2008
prompt= {'Number Of Investments:'};  
name        = 'Inputs for Decsion function';
numlines    = 1;

% input para gui
defaultanswer   = {'10'};
answer          = inputdlg(prompt,name,numlines,defaultanswer);
drawnow;

% Return data
NoOfInvestments               = str2num(answer{1});

function [BuySymbols] = RemoveSymbols(symbolset,InvestedSymbols,NoOfInvestmentsRequired);
%Written by:    Bryan Taylor
%Date Created:  2nd September 2008 #

%remove invested
[x] = size(InvestedSymbols,1);
for i = 1:x
    n = find(strcmpi(InvestedSymbols{i},symbolset));
    [y] = size(symbolset,1);
    if not(isempty(n))
        symbolset = symbolset([1:n-1,n+1:y],1);
    end
end

x = size(symbolset,1);
if x<NoOfInvestmentsRequired
    NoOfInvestmentsRequired = x;
end
BuySymbols = symbolset(1:NoOfInvestmentsRequired,1); %Check not already invested.

 
