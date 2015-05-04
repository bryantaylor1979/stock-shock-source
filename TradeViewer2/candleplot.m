function handle = candleplot(varargin)
% Description: Similar to candle.m but can support update and has some additonal
% formating.
% it also display last price and price mean.
%
% Optional inputs:
%    candlecolor: default [1,0,0]
%    title: title of graph (defaults as empty)
%
% Ex1 - New plot but giving the function a pre-defined axes.
%    handle.figure = figure;
%    handle.candle_ax = subplot(2,1,1);
%    handle = candleplot(Date,High,Low,Open,Close,'handle',handle)
%
% Ex2 - Generate a new plot
%    handle = candleplot(Date,High,Low,Open,Close)
%
% Ex3 - Update a exiting plot
%    handle = candleplot(Date,High,Low,Open,Close,'handle',handle)
%
% Written by: bryan taylor
% Date Written: 3rd May 2015

  % compulsory inputs
  Date = varargin{1};
  High = varargin{2};
  Low = varargin{3};
  Open = varargin{4};
  Close = varargin{5};
  
  args.candlecolor = [1,0,0];
  args.handle = [];
  args.title = '';
  args.lastprice_enable = true;
  args.pricemean_enable = true;
  args.LegendsVisible = 'on';
   
  varargin = varargin(6:end);
  x = size(varargin,2);
  for i = 1:2:x
    args.(varargin{i}) = varargin{i+1};
  end
  if isempty(args.handle)
      args.handle.candle_ax = [];
      args.handle.figure = figure;
  end
  args.handle.candle_ax = candle_custom(Date, High, Low, Close, Open, args.candlecolor, args.handle.candle_ax, args.title);
  if args.lastprice_enable == true
    args.handle = lastprice(args.handle,Date,Close);
  end
  if args.pricemean_enable == true
    args.handle = pricemean(args.handle,Date,High,Low,Close,Open);
  end
  args.handle.legend = legend({  'High-Low'; ...
            'Rise-Open-Close'; ...
            'Fall-Close-Open'; ...
            'PriceMean'; ...
            'LastPrice'}, ...
            'Location','NorthWest');   
  set(args.handle.legend,'visible',args.LegendsVisible);
  title(args.title);
  handle = args.handle;
end
function candle_ax = candle_custom(Date, High, Low, Close, Open, candlecolor, candle_ax, title)
  if not(isempty(candle_ax))
        % in this case the inbuilt function candle does not return set/get
        % params. So we a forced to clear the axes for the update
        axes(candle_ax);
        XTickLabel = get(candle_ax,  'XTickLabel');
        cla;
        New = true;
  else
        New = false;
  end
  
  candle(High, Low, Close, Open, candlecolor, Date); %Appears
  if isempty(candle_ax)
    candle_ax = gca;
  end
  grid on
  h = ylabel('Price');
  set(h,'FontWeight','bold');
  set(candle_ax,    'XLim',[min(Date)-5,max(Date)+5], ...
                    'YLim',[min(Low),max(High)]);
  if New == true
      set(candle_ax,'XTickLabel',XTickLabel);
  end
  xlabel('Date');
  title(title);
end
function handle = lastprice(handle,Date,Close)
      n = find(max(Date)==Date);
      LastPriceDate =Date(n);
      LastPrice = Close(n);
      n = find(strcmpi(fieldnames(handle),'LastPrice'));
      if not(isempty(n))
        set(handle.LstPriceTxt,'String',[num2str(LastPrice),' @ ',datestr(LastPriceDate)]);
        set(handle.LastPrice,'XDATA',LastPriceDate);
        set(handle.LastPrice,'YDATA',LastPrice);
      else
        fontcolor = [0.2,0.2,1];
        drawnow;
        Xlim = get(handle.candle_ax,'Xlim');
        Ylim = get(handle.candle_ax,'Ylim');
        XlimRange = Xlim(2)-Xlim(1);
        YlimRange = Ylim(2)-Ylim(1);
        handle.LstPriceTxt = text(Xlim(1)+XlimRange,Ylim(1)+YlimRange*0.95,[num2str(LastPrice),' @ ',datestr(LastPriceDate)]);
        set(handle.LstPriceTxt,  'Color',fontcolor, ...
                'FontWeight','bold', ...
                'FontSize', 14, ...
                'HorizontalAlignment','right');
        hold on
        handle.LastPrice = plot(LastPriceDate,LastPrice,'d', ...
                   'LineWidth',2,...
                   'MarkerEdgeColor','b',...
                   'MarkerFaceColor','b',...
                   'MarkerSize',8);
      end
end
function handle = pricemean(handle,Date,High,Low,Close,Open)
    pricemean = mean(rot90([High,Low,Close,Open]));
    n = find(strcmpi(fieldnames(handle),'pricemean'));
    if not(isempty(n))
        set(handle.pricemean,'XDATA',Date);   
        set(handle.pricemean,'YDATA',pricemean); 
    else
        handle.pricemean = plot(Date,pricemean, ...
                       'k:','Color',[0.2,0.8,0.2], ...
                       'LineWidth',2.5,...
                       'MarkerEdgeColor','k',...
                       'MarkerFaceColor','k',...
                       'MarkerSize',8);
    end
end
function Example()
    %% Init Graph
    close all
    clear classes
    ARRAY = fetch(yahoo,'HAWK.L',{'high','low','open','close'},today-31*3,today,'d');
    Date = ARRAY(:,1);
    High = ARRAY(:,2);
    Low = ARRAY(:,3);
    Open = ARRAY(:,4);
    Close = ARRAY(:,5);
    handle.figure = figure;
    handle.candle_ax = subplot(2,1,1);
    candleplot(Date,High,Low,Open,Close,'handle',handle);
    set(handle.candle_ax,   'Position',[0.094,0.268,0.862,0.6], ...
                            'XTickLabel',[]);
                
    %% Update Graph
    ARRAY = fetch(yahoo,'BARC.L',{'high','low','open','close'},today-31*3,today,'d');
    Date = ARRAY(:,1);
    High = ARRAY(:,2);
    Low = ARRAY(:,3);
    Open = ARRAY(:,4);
    Close = ARRAY(:,5);
    candleplot(Date,High,Low,Open,Close,'handle',handle);    
                
    %% Init Graph with no subplot
    close all
    clear classes
    ARRAY = fetch(yahoo,'HAWK.L',{'high','low','open','close'},today-31*3,today,'d');
    Date = ARRAY(:,1);
    High = ARRAY(:,2);
    Low = ARRAY(:,3);
    Open = ARRAY(:,4);
    Close = ARRAY(:,5);
    candleplot = candleplot(Date,High,Low,Open,Close);
end