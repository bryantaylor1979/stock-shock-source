classdef StructureManagement < handle
    properties
    end
    methods
        function [Dat] = GetField(obj,struct,field)
            %%
            Dat = squeeze(struct2cell(struct));
            n = find(strcmpi(fieldnames(struct),field));
            Dat = rot90(Dat(n,:));
        end
        function Table = struct2Table(obj,struct)
            Table = [rot90(fieldnames(struct),3);fliplr(rot90(squeeze(struct2cell(struct))))];
        end
    end
end