function [ output ] = TickerSymbolSuffixLookup( Mode,Country )
%[ output ] = TickerSymbolSuffixLookup('SaxoSymbol',Country)
%
%
%Information extracted from:
%   http://uk.biz.yahoo.com/p/dk/cpi/cpit0.html
%
%Written by:    Bryan Taylor
%Date created:  27th May 2008

LUT = { ...
'United States of America',   'American Stock Exchange',         'N/A',  '20 min',   'Direct from Exchange',    'xase ';
'United States of America',   'NASDAQ Stock Exchange',           'N/A',  '15 min',   'Direct from Exchange',    'xnas ';
'United States of America',   'New York Stock Exchange',         'N/A',  '20 min',   'Direct from Exchange',    'xnys ';
'United States of America',   'OTC Bulletin Board Market',       'OB',   '20 min',   'Direct from Exchange',    'N/A';  
'United States of America',   'Pink Sheets',                     'PK',   '15 min',   'Direct from Exchange',    'N/A'; 
'Argentina',                  'Buenos Aires Stock Exchange',     'BA',   '30 min',   'Telekurs Financial',      'N/A'; 
'Austria',                    'Vienna Stock Exchange',           'VI',   '15 min',   'Telekurs Financial',      'xwbo '; 
'Australia',                  'Australian Stock Exchange',       'AX',   '20 min',   'Comstock',                'xbru ';
'Australia',                  'Australian Stock Exchange',       'AX',   '20 min',   'Comstock',                'xasx ';
'Brazil',                     'Sao Paolo Stock Exchange',        'SA',   '15 min',   'Comstock',                'N/A'; 
'Canada',                     'Toronto Stock Exchange',          'TO',   '15 min',   'Comstock',                'N/A'; 
'Canada',                     'TSX Venture Exchange',            'V',    '15 min',   'Comstock',                'N/A'; 
'China',                      'Shanghai Stock Exchange',         'SS',   '30 min',   'Telekurs Financial',      'N/A'; 
'China',                      'Shenzhen Stock Exchange',         'SZ',   '30 min',   'Telekurs Financial',      'N/A'; 
'Denmark'                     'Copenhagen Stock Exchange',       'CO',   '15 min',   'Telekurs Financial',      'xcse ';  
'France'                      'Paris Stock Exchange',            'PA',   '15 min',   'Telekurs Financial',      'xpar '; 
'Germany'                     'Berlin-Bremen Stock Exchange',    'BE',   '15 min',   'Telekurs Financial',      'N/A'; 
'Germany',                    'Dusseldorf Stock Exchange',       'DU',   '15 min',   'Telekurs Financial',      'N/A'; 
'Germany',                    'Frankfurt Stock Exchange',        'F',    '15 min',   'Telekurs Financial',      'xetr ';
'Germany',                    'Hamburg Stock Exchange',          'HM',   '15 min',   'Telekurs Financial',      'N/A'; 
'Germany',                    'Hanover Stock Exchange',          'HA',   '15 min',   'Telekurs Financial',      'N/A'; 
'Germany',                    'Munich Stock Exchange',           'MU',   '15 min',   'Telekurs Financial',      'N/A'; 
'Germany',                    'Stuttgart Stock Exchange',        'SG',   '15 min',   'Telekurs Financial',      'N/A'; 
'Germany',                    'XETRA Stock Exchange',            'DE',   '15 min',   'Telekurs Financial',      'N/A';  
'Hong Kong',                  'Hong Kong Stock Exchange',        'HK',   '60 min',   'Telekurs Financial',      'N/A'; 
'India',                      'Bombay Stock Exchange',           'BO',   '15 min',   'Comstock',                'N/A'; 
'India',                      'National Stock Exchange of India','NS',   '15 min',   'Telekurs Financial',      'N/A'; 
'Indonesia',                  'Jakarta Stock Exchange',          'JK',   '10 min',   'Comstock',                'N/A'; 
'Ireland',                    'Irish Stock Exchange',            'IR',   '15 min',   'Telekurs Financial',      'N/A'; 
'Israel',                     'Tel Aviv Stock Exchange',         'TA',   '20 min',   'Telekurs Financial',      'N/A'; 
'Italy',                      'Milan Stock Exchange',            'MI',   '20 min',   'Comstock',                'xmil '; 
'South Korea',                'Korea Stock Exchange',            'KS',   '20 min',   'Comstock',                'N/A'; 
'South Korea',                'KOSDAQ',                          'KQ',   '20 min',   'Comstock',                'N/A'; 
'Mexico',                     'Mexico Stock Exchange',           'MX',   '20 min',   'Telekurs Financial',      'N/A'; 
'Netherlands',                'Amsterdam Stock Exchange',        'AS',   '15 min',   'Telekurs Financial',      'xams '; 
'New Zealand',                'New Zealand Stock Exchange',      'NZ',   '20 min',   'Comstock',                'N/A'; 
'Norway',                     'Oslo Stock Exchange',             'OL',   '15 min',   'Telekurs Financial',      'xosl '; 
'Portugal',                   'Lisbon Stock Exchange',           'LS',   '15 min',   'Telekurs Financial',      'xlis ';
'Singapore',                  'Singapore Stock Exchange',        'SI',   '20 min',   'Comstock',                'xses '; 
'Spain',                      'Barcelona Stock Exchange',        'BC',   '15 min',   'Telekurs Financial',      'xmce '; 
'Spain',                      'Bilbao Stock Exchange',           'BI',   '15 min',   'Telekurs Financial',      'N/A'; 
'Spain',                      'Madrid Fixed Income Market',      'MF',   '15 min',   'Telekurs Financial',      'N/A'; 
'Spain',                      'Madrid SE C.A.T.S.',              'MC',   '15 min',   'Telekurs Financial',      'N/A'; 
'Spain',                      'Mardid Stock Exchange',           'MA',   '15 min',   'Telekurs Financial',      'N/A'; 
'Sweden',                     'Stockholm Stock Exchange',        'ST',   '15 min',   'Telekurs Financial',      'xome '; 
'Switzerland',                'Swiss Exchange',                  'SW',   '15 min',   'Telekurs Financial',      'xswx '; 
'Switzerland',                'Virt-X',                          'VX',   '15 min',   'Telekurs Financial',      'xvtx ';
'Taiwan',                     'Taiwan OTC Exchange',             'TWO',  '20 min',   'Comstock',                'N/A'; 
'Taiwan',                     'Taiwan Stock Exchange',           'TW',   '20 min',   'Comstock',                'N/A'; 
'Thailand',                   'Stock Exchange of Thailand',      'BK',   '15 min',   'Comstock',                'N/A'; 
'Brussels',                   'Euronext Brussels',               'BR',   'N/A',      'N/A',                     'N/A';
'United Kingdom',             'London Stock Exchange',           'L',    '20 min',   'Telekurs Financial',      'xlon '}; 
 

n = find(strcmpi(LUT(:,6),Country));
try
if strcmpi(LUT{n,3},'n/a')
    Suffix = '';
else
    Suffix = LUT{n,3};
end
catch
error(['Couldn''t Find: ',Country]) 
end
ExchangeName = LUT{n,2};
Country = LUT{n,1};
Delay = LUT{n,4};
Source = LUT{n,5};
output.Suffix = Suffix;
output.ExchangeName = ExchangeName;
output.Country = Country;
output.Delay = Delay;
output.Source = Source;