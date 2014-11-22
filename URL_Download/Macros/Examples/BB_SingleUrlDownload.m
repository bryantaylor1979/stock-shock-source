%%
obj.sURL = 'http://www.britishbulls.com/SignalPage.aspx?lang=en&Ticker=';
obj.eURL = '';
obj.timeout = 100000;

url = [obj.sURL,'BA.L',obj.eURL]
s = urlread2(url,[],[],obj.timeout);
%s = urlread(url)

obj.DisplayHTML(s,'temp.html')