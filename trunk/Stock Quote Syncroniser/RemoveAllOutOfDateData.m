function [SummaryStruct] = RemoveAllOutOfDateData(SummaryStruct,MaxThreshold)

NumberOfDaysOutOfSync = cell2mat(Struct2Data(SummaryStruct,'NumberOfDaysOutOfSync'));
n = find(NumberOfDaysOutOfSync < 7);
SummaryStruct = SummaryStruct(n);