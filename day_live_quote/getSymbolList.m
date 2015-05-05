%% NOT SURE IF THIS IS WORKING
function Symbols = getSymbolList(exchange)
%TODO: I can extract more information from this. 

    %exchange : nyse or nasdaq or AMEX
    % http://www.nasdaq.com/screening/companies-by-name.aspx?letter=0&exchange=nasdaq
    string = urlread(['http://www.nasdaq.com/screening/companies-by-name.aspx?letter=0&exchange=',exchange,'&render=download']);
    [Symbol,Name,LastSale,MarketCap,IPOyear,Sector,industry,SummaryQuote] = strread(string,'%s%s%s%s%s%s%s%s','delimiter',',');
    %remove all heading
    n = strmatch('"http',Symbol);
    Symbol = Symbol(n);
    Name = Name(n);
    LastSale = LastSale(n);
    MarketCap = MarketCap(n);
    IPOyear = IPOyear(n);
    Sector = Sector(n);
    industry = industry(n);
    SummaryQuote = SummaryQuote(n);
    Symbol = strrep(Symbol,'"http://www.nasdaq.com/symbol/','');
    Symbols = strrep(Symbol,'"','');
end