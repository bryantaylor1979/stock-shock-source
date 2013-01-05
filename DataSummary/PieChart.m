%Root directory				43.1 GB

SizesOfData = { ...
	'British Bulls',		3320000000; ... %3.32 GB
	'ADVFN',			    6180000000; ... %6.18 GB
	'NewAlerts',            1250000000; ... %1.25 GB		
	'Finaical Times', 		  50400000; ... %50.4 MB
	'FinaicalTimes', 		1940000000; ... %19.4 GB
	'Generic',			        501000; ... %501 KB
	'DigitalLook',			4760000000; ... %4.76 GB
	'QuoteAbstractionLayer', 102000000; ...	%102 MB
	'TaskMaster',			      1200; ... %1.2 KB
	'URL_Download',			 380000000; ... %380 MB
	'Schedular',			1280000000; ... %1.28 GB
	'Stox',			        4450000000; ... %4.45 GB
	'SharePrice',		    1500000000; ... %1.50 GB
	'Yahoo',		         171000000; ... %171 MB
	'WhatBrokersSay',		   9070000; ... %9.07 MB 
	'WebDecoder',			 301000000; ... %301 MB
	'NakedTrader',		       1250000};    %1.25 MB

pie(cell2mat(SizesOfData(:,2)),SizesOfData(:,1))
