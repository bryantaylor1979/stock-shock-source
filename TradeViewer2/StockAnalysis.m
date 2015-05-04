classdef StockAnalysis < handle
    %TODO:  Date range Icons added to SS.
    %TODO:  Change symbol by changing properties (using set/get events)
    %TODO:  Change date range by changing the properties (using set/get)
    %TODO:  Add support and resistance levels.
   properties (SetObservable = true)
      IsVisible = 'on';
      LegendsVisible = 'off';
      Range = '3m'; %1w, 2w, 1m, 3m, 6m, 1y, All
      Symbol = 'HAWK.L';
      ToolbarVisible = 'off';
      ResistanceTwo = NaN;
      ResistanceOne = 36;
      SupportOne = 28;
      SupportTwo = NaN;
   end
   properties % Read Only
      Open = 1:300;
      Close = 11:310;
      Volume = 1:300;
      SectorName
      SectorSymbol
      Name = 'Description';
   end
   properties (Hidden = true)
      handles
      Children
      OpenLineColour = [1,0,0];
      ProgramName = 'Stock Analysis'
      Path = '/home/imagequality/stock-shock-source/TradeViewer2/';
      DataPath = 'C:\SourceSafe\Stocks & Shares\Programs\Stock Quote Sync\Data\';
      SectorList
      Rev = 0.02
      Date = now-300:now-1;
   end
   methods
      function [COMM,MAP] = LoadObjects(obj)
          %% Local Database Setup
          COMM = obj.LoadCommObject(obj.DataPath)
          
          %% Symbol Info
          MAP = readsymbolslist('iii_map_v2.m');
          COMM.Symbol = obj.Symbol;   
          COMM.LoadData; 
          
          info = MAP.GetSymbolsInfo(obj.Symbol)
          obj.Name = info.Name;
      end
      function SaveFig(obj,filename)
          %%
%            set(obj.handles.figure,'Visible','off')
          saveas(obj.handles.figure,filename)
%            set(obj.handles.figure,'Visible','on')
      end
   end
   methods (Hidden = true) % Comms to Database
       function OBJ = LoadCommObject(obj,DataPath)
          OBJ = LocalDatabase('ExternalCommObj','offline'); %'yahoo-fetch' or 'offline'          
          OBJ.Location = DataPath;           
       end
   end
   methods (Hidden = true) %Listeners
       function IsVisibleCallback(varargin)
           obj = varargin{1};
           set(obj.handles.figure,'visible',obj.IsVisible)
       end
       function IsLegendsVisibleCallback(varargin)
           obj = varargin{1};
           set(obj.handles.legends,'visible',obj.LegendsVisible)
       end
   end
   methods (Hidden = true)%GUI
       function PlotResistanceLevels(obj,handle)
           %%
           if not(isnan(obj.ResistanceOne))
               obj.PlotLine(obj.ResistanceOne,handle)
           end
           if not(isnan(obj.ResistanceTwo))
               obj.PlotLine(obj.ResistanceTwo,handle)
           end
           if not(isnan(obj.SupportOne))
               obj.PlotLine(obj.SupportOne,handle)
           end
           if not(isnan(obj.SupportTwo))
               obj.PlotLine(obj.SupportTwo,handle)
           end
       end
       function PlotLine(obj,Value,handle)
           %%
           axes(handle);
           obj.handles.resistance1 = plot([obj.Date(1),obj.Date(end)],[Value,Value],'r:');
           
           %%
           set(obj.handles.resistance1, ...
                            'LineWidth',3, ...
                            'Color',[1,0.2,1]);
       end
       function handles = CreateFigure(obj,COMM,MAP)
          % Create Main Figure
          handles.figure       =figure ('Name',[obj.ProgramName,' - R',num2str(obj.Rev)], ...
                                            'Color',[0.92549 0.913725 0.847059], ...
                                            'NumberTitle','off',...
                                            'Visible','off', ...
                                            'MenuBar','none', ...
                                            'Resize','on');
          FieldNames = COMM.DataStoreColumnNames;
          if isempty(FieldNames(7:end))
              String = {'N/A'};
          else
              String = FieldNames(7:end);
          end
          handles.DataType =uicontrol(  'Style',    'popupmenu', ...
                                            'String',   String, ...
                                            'Position', [2,380,130,40]);                           
          handles.IndexPullDown = obj.IndexPullDown(MAP,obj.Symbol);
          handles.SymbolPulldown = obj.SymbolPullDown(MAP,obj.Symbol);
          obj.AddButton(handles);
          
          
          %Menu Bar
          handles.menu = uimenu(handles.figure,'Label','Help');
          handles.About = uimenu(handles.menu, ...
                            'Label',['About ',upper(obj.ProgramName)], ...
                            'Callback',@obj.About);
       end
       function handle = IndexPullDown(obj,MAP,Symbol)
          SectorList = MAP.GetSectorList();
          [x] = size(SectorList,1);
          
          for i = 1:x
            info = MAP.GetIndexDescription(SectorList{i});
            Combined{i} = [info.Description,' (',info.Symbol,')'];
          end
                  
          info = MAP.GetSymbolsInfo(Symbol);
          n = find(strcmpi(info.Sector,SectorList));
          handle = uicontrol(  'Style',    'popupmenu', ...
                                           'Value',     n, ...
                                            'String',   Combined );
          %%
          set(handle,'Position', [132,380,316,40]);     
       end
       function handle = SymbolPullDown(obj,MAP,Symbol)
          
          info = MAP.GetSymbolsInfo(Symbol)
          Symbol = MAP.GetIndexSymbols(info.Sector)
          
          n = find(strcmpi(Symbol,obj.Symbol));
          
          handle = uicontrol(  'Style',    'popupmenu', ...
                                                    'Value',   n+1, ...
                                                    'String',    [{'Parent Index'};Symbol] );
          %%
          set(handle,'Position', [449,380,178,40]);   
       end
       function DateRangeButtons(obj,handles)
         handles.DataRangeToolbar = uitoolbar(handles.figure,'Visible','on');
         
         Ranges = { '5d','5 Days'; ...
                    '2w','2 Weeks'; ...
                    '1m','1 Month'; ...
                    '3m','3 Months'; ...
                    '6m','6 Months'; ...
                    '1y','1 Year'};
                
         [x] = size(Ranges,1);
         for i = 1:x
             try
                filename = fullfile(obj.Path,'Icons',[Ranges{i,1},'.bmp'])
                CDATA = imread(filename);
                warning('5 day symbol not found')
             catch
                CDATA(1:16,1:16,1:3) = 1;
             end
             h = uitoggletool(handles.DataRangeToolbar, ...
                                              'TooltipString',Ranges{i,2}, ...
                                              'CDATA',CDATA, ...
                                              'tag',Ranges{i,1});  
             handles.(['H_',Ranges{i,1}]) = h;
         end
         for i = 1:x
             set(handles.(['H_',Ranges{i,1}]),'ClickedCallback',{@obj.DataRangeButtonCallback});
         end
       end
       function handle = Plot(varargin)
          obj = varargin{1};
          handle = varargin{2};
          COMM = varargin{3};
          MAP = varargin{4};
          try
              First = varargin{5};
          catch
              try
                 obj.handles.candle_ax;
                 First = false;
              catch

                 drawnow

                 drawnow
                 First = true;
              end
          end
          %%
          ARRAY = fetch(yahoo,obj.Symbol,{'high','low','open','close','volume'},today-31*3,today,'d');
          Date = ARRAY(:,1);
          High = ARRAY(:,2);
          Low = ARRAY(:,3);
          Open = ARRAY(:,4);
          Close = ARRAY(:,5);
          Volume = ARRAY(:,6);
            
          
          obj.PlotResistanceLevels(handle.candle_ax);
       end
       function AddButton(obj,handles)
        handles.toolbar = uitoolbar(handles.figure,'Visible',obj.ToolbarVisible);

        filename = fullfile(obj.Path,'Icons','ADD.ico')
        [a,b,c] = imread(filename);
        BackgroundColour = [0.8314    0.8157    0.7843];
        b2 = [b; BackgroundColour]; 
        % Create new image for display. 
        d = ones(size(a)) * (length(b2) - 1); 
        % Use the AND mask to mix the background and
        % foreground data on the new image
        d(c == 0) = a(c == 0); 

        % Display new image 
        RGB = ind2rgb(uint8(d),colormap(b2));
        RGB = imcrop(RGB,[10,10,16,16]);
        RGB = imresize(RGB,[16 16],'nearest');
        handles.Add = uipushtool(handles.toolbar, ...
                                          'CData',RGB, ... 
                                          'TooltipString','Take Measurement', ...
                                          'tag','Add', ...
                                          'ClickedCallback',{@obj.AddButtonCallback});
       end
       function Resize(varargin)
          
          obj = varargin{1};
          disp('Resisze')
          handle = varargin{2}
          oldpos = get(handle.figure,'UserData');
          PosFig = get(handle.figure,'Position');
          
          % Apply min size
          if PosFig(1) == oldpos(1)
              if PosFig(3) < 628
                  PosFig(3) = 628;
              end
          elseif PosFig(3)< 628
              diff = PosFig(3) - oldpos(3);
              PosFig(1) = PosFig(1) + diff;
              if PosFig(3) < 628
                  PosFig(3) = 628;
              end
          end
          if PosFig(2) == oldpos(2)
              if PosFig(4) < 400
                  PosFig(4) = 400;
              end
          elseif PosFig(4) < 400
              diff = PosFig(4) - oldpos(4);
              PosFig(2) = PosFig(2) + diff;
              if PosFig(4) < 400
                  PosFig(4) = 400;
              end              
          end
          set(handle.figure,'Position',PosFig);
          
          % 
          PosPulldown = get(handle.DataType,'Position');
          PosPulldown(2) = PosFig(4)-40;
          set(handle.DataType,'Position',PosPulldown);
          
          PosPulldown = get(handle.IndexPullDown,'Position');
          PosPulldown(2) = PosFig(4)-40;
          set(handle.IndexPullDown,'Position',PosPulldown);
          
          PosPulldown = get(handle.SymbolPulldown,'Position');
          PosPulldown(2) = PosFig(4)-40;
          set(handle.SymbolPulldown,'Position',PosPulldown);
          
%           PosPulldown = get(obj.handles.CoNameTxt,'Position');
%           PosPulldown(2) = PosFig(4)-50;
%           set(obj.handles.CoNameTxt,'Position',PosPulldown);
          
          set(handle.figure,'UserData',PosFig);
       end
       function About(varargin)
            obj = varargin{1};
            names = fieldnames(obj.Children);
            [x] = size(names,1);
            for i = 1:x
                Componet = getfield(obj.Children,names{i});
                Rev = Componet.Rev;
                String{i,1} = [names{i},': R',num2str(Rev)];
            end
            msgbox([{'Component Information';'==================';''};String])
       end
       function AddButtonCallback(varargin)
          obj = varargin{1};
                   
          Value = get(obj.Children.IndexPulldown,'Value');
          obj.LDobj.Symbol =  obj.SymbolObj.SectorList{Value};
          
          DataStore = obj.LDobj.DataStore;
          FieldNames = obj.LDobj.DataStoreColumnNames;
          
          String = get(obj.Children.Pulldown,'String');
          Value = get(obj.Children.Pulldown,'Value');
          
          hold on
          Data = obj.LDobj.GetRange(String{Value},obj.Range);
          Date = obj.LDobj.GetRange('Date',obj.Range);
          PriceMean = obj.LDobj.GetRange('PriceMean',obj.Range);
          
          ax2 = axes(   'Position',[0.094,0.268,0.862,0.6],...
                        'XAxisLocation','top',...
                        'YAxisLocation','right',...
                        'XTick',[],...
                        'YTick',[],...
                        'Color','none',...
                        'XColor','k',...
                        'YColor','k');
       
          h.Children.Line = line(Date,Data,'Color','k','Parent',ax2);
          XLim = get(obj.Children.OpenLineHandle,'XLim');
          YLim = get(obj.Children.OpenLineHandle,'YLim');
          set(gca,'Position',[0.094,0.268,0.862,0.6]);
          set(ax2,'YLim',YLim);
          set(ax2,'XLim',XLim);
       end
       function IndexPulldownCallback(varargin)
          %Sector Update
          obj = varargin{1};
          
          Value = get(obj.handles.IndexPulldown,'Value');
          obj.Children.LocalDatabase.Symbol = obj.SectorList{Value,2};
          
          % Index
          Symbol = obj.Children.SymbolObj.GetIndexSymbols(obj.Children.LocalDatabase.Symbol);
          set(obj.handles.SymbolPulldown,'Value', 1);
          set(obj.handles.SymbolPulldown,'String',    [{'Parent Index'};Symbol]);
          title('');
          
          obj.Children.LocalDatabase = obj.Children.LocalDatabase.LoadData;         
          obj.Plot;
       end
       function SymbolPulldownCallback(varargin)
          obj = varargin{1};
          
          Value = get(obj.handles.SymbolPulldown,'Value');
          String = get(obj.handles.SymbolPulldown,'String');
          obj.Children.LocalDatabase.Symbol = String{Value};
          obj.Symbol = obj.Children.LocalDatabase.Symbol;
          
          obj.Children.LocalDatabase = obj.Children.LocalDatabase.LoadData;         
          obj.Plot
       end
       function DataRangeButtonCallback(varargin)
          obj = varargin{1};
          hObject = varargin{2}
          
          Ranges = { '5d','5 Days'; ...
                     '2w','2 Weeks'; ...
                     '1m','1 Month'; ...
                     '3m','3 Months'; ...
                     '6m','6 Months'; ...
                     '1y','1 Year'};
          [x] = size(Ranges,1);
          for i = 1:x
              try
              set(obj.handles.(['H_',Ranges{i,1}]),'State','off','Enable','on');
              end
          end
          set(hObject,'State','on','Enable','on');
          obj.Range = get(hObject,'tag');
          obj.Plot(false);
       end
       function ResistanceCallback(varargin)
           obj = varargin{1};
           obj.Plot;
       end
       function obj = StockAnalysis(varargin)
          %% Manage input varaiables
          % variable arg in
          [x] = size(varargin,2);
          for i = 1:2:x
              obj.(varargin{i}) = varargin{i+1};
          end
          
          %%
          addlistener(obj,'IsVisible','PostSet',@obj.IsVisibleCallback);
          addlistener(obj,'LegendsVisible','PostSet',@obj.IsLegendsVisibleCallback); 
  
          %%
          [COMM,MAP] = obj.LoadObjects;
          handle = obj.CreateFigure(COMM,MAP)
          handle = obj.Plot(handle,COMM,MAP)
          
          Fields = {    'ResistanceTwo'; ...
                        'ResistanceOne'; ...
                        'SupportOne'; ...
                        'SupportTwo'};
                    
          obj.addlistener(Fields,'PostSet',@obj.ResistanceCallback);
         
          obj.DateRangeButtons(handle);
%           set(handle.figure,'ResizeFcn',{@obj.Resize}); 
          PosFig = get(handle.figure,'Position');
          set(handle.figure,'UserData',PosFig);
          obj.Resize(handle);
          set(handle.figure,'Visible','on');
          set(handle.IndexPullDown,'Callback',@obj.IndexPulldownCallback);  
          set(handle.SymbolPulldown,'Callback',@obj.SymbolPulldownCallback);  
      end
   end
end