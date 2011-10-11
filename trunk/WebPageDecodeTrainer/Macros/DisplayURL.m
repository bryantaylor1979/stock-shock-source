Symbol = 'BARC'
s = obj.LoadResult_Type('FinicialTimes','Analysis',Symbol,today-1,'URL')

%%
HTML_PATH = ['C:\temp\temp.html'];
obj.DisplayHTML(s,HTML_PATH)