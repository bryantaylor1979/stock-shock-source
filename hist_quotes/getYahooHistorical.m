function getYahooHistorical()
    [data] = fetch(yahoo,'ibm',{'Close','Open','Low','High','Volume'},today-30,today);
end