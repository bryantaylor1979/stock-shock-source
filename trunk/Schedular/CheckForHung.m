%% Check#
clear classes
obj = Schedular
Name = 'MEDIAPC'
[struct, Error] = obj.LoadStatus(floor(now)-1,Name)
DATASET = obj.struct2DATASET(struct.detial)