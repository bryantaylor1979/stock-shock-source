function candleplot(candle_ax,Date,High,Low,Open,Close,title_input)
  args.LegendsVisible = 'on';
  args.candlecolor = [1,0,0];
  args.pricemean_enable = true;
  args.pricemean = mean(rot90([High, Low, Close, Open]));
  args.lastprice_enable = true;
  args.title = '';
  
  axes(candle_ax)             
  candle(High, Low, Close, Open, args.candlecolor, Date); %Appears
  grid on
  set(candle_ax,    'Position',[0.094,0.268,0.862,0.6], ...
                    'XTickLabel',[], ...
                    'XLim',[min(Date)-5,max(Date)+5], ...
                    'YLim',[min(Low),max(High)]);

  if args.pricemean_enable == true 
      hold on
      handles.pricemean = plot(Date,args.pricemean, ...
                   'k:','Color',[0.2,0.8,0.2], ...
                   'LineWidth',2.5,...
                   'MarkerEdgeColor','k',...
                   'MarkerFaceColor','k',...
                   'MarkerSize',8);
  end
  if args.lastprice_enable == true
      n = find(max(Date)==Date);
      LastPriceDate =Date(n);
      LastPrice = Close(n);
      Position = get(gcf,'Position')
      LstPriceTxt=uicontrol(    'Style','text', ...
                                'Position',[Position(3)-170,Position(4)-35,250,19], ...
                                'HorizontalAlignment','left', ...
                                'FontWeight','bold', ... 
                                'String',[num2str(LastPrice),' @ ',datestr(LastPriceDate)], ...
                                'ForegroundColor',[0.2,0.2,1]);
      hold on
      s.LastPrice = plot(LastPriceDate,LastPrice,'d', ...
                   'LineWidth',2,...
                   'MarkerEdgeColor','b',...
                   'MarkerFaceColor','b',...
                   'MarkerSize',8);
  end

  %format graph
  h = ylabel('Price');
  set(h,'FontWeight','bold');
  title(title_input);
  obj.handles.legends = legend({  'High-Low'; ...
            'Rise-Open-Close'; ...
            'Fall-Close-Open'; ...
            'PriceMean'; ...
            'LastPrice'}, ...
            'Location','NorthWest');
  set(obj.handles.legends,'visible',args.LegendsVisible);
end
function example()
    %%
    close all
    clear classes
    ARRAY = fetch(yahoo,'HAWK.L',{'high','low','open','close'},today-31*3,today,'d');
    Date = ARRAY(:,1);
    High = ARRAY(:,2);
    Low = ARRAY(:,3);
    Open = ARRAY(:,4);
    Close = ARRAY(:,5);
    
    subplot(2,1,2);
    volume_ax = gca;
    drawnow
    subplot(2,1,1);
    candle_ax = gca;
    drawnow
%     
%     info = MAP.GetSymbolsInfo(COMM.Symbol);
%     title = [obj.Symbol,' - ',info.SectorDescription];
  
    %
    title = 'HAWK.L'
    candleplot(candle_ax,Date,High,Low,Open,Close,title);
end