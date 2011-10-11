ProgramName = 'WhatBrokersSay';
ResultName = 'BrokersView';
Date = today - 1;

%
Page = '0';
s = obj.LoadResult_Type(ProgramName,ResultName,Page,Date,'URL');
DATASET1 = obj.WBS.DecodeTable(s);

Page = '50';
s = obj.LoadResult_Type(ProgramName,ResultName,Page,Date,'URL');
DATASET2 = obj.WBS.DecodeTable(s);

Page = '100';
s = obj.LoadResult_Type(ProgramName,ResultName,Page,Date,'URL');
DATASET3 = obj.WBS.DecodeTable(s);

DATASET = [DATASET1;DATASET2;DATASET3];

%
[updated,DATASET2] = obj.WBS.SaveData(DATASET);

obj.SaveDataSet(DATASET,ProgramName,ResultName,Date);