classdef DecodeTableFromURL < handle
    properties
    end
    methods
        function Table = DecodeTable(obj,s,struct)
            %%           
            [table] = obj.CropTable(s,struct.TableStart,struct.TableEnd);
            [rows] = obj.CropRows(table,struct.RowStart,struct.RowEnd);
            Table = obj.GetAllCells(rows,struct.CellStart,struct.CellEnd,struct.CellEndT);   
        end
    end
    methods (Hidden = true) %DecodeTable - Support
        function cells = GetAllCells(obj,rows,cellstart,cellend,cellend2)
            %%
            x = max(size(rows));
            cells = [];
            for i = 1:x
                rowstr = rows{i};
                cell = obj.GetCell(rowstr,cellstart,cellend,cellend2);
                y = size(cells,2);
                try
                cells = [cells;cell];
                catch
                cells = [cells;cell(1:y)];    
                end
            end
        end
        function cell = GetCell(obj,rowstr,cellstart,cellend,cellend2)
%             rowstr
            n1 = findstr(rowstr,cellstart);
            n2 = findstr(rowstr,cellend);
            x = max(size(n1));
            for i = 1:x
                startloc = n1(i);
                n = min(find(startloc < n2));
                endloc = n2(n);
                
                string = rowstr(startloc:endloc);
                n = findstr(string,'">');
                if isempty(n)
                   n = findstr(string,'>') - 1;
                end
                string2 = string(n+2:end-1);
                cell{i} = string2;
            end
            
            try
                En = findstr(rowstr,'/>');
                n = max(find(n1 < En));

                for i = 1:max(size(n))
                    cell{n(i)} = '';
                end
            end
        end
        function [rows] = CropRows(obj,table,rowstart,rowend)
            n3 = findstr(table,rowstart);
            n4 = findstr(table,rowend);
            disp([num2str(max(size(n3))),' rows detected'])
            
            for i = 1:max(size(n3))
                try
                temp = table(n3(i):end);
                n4 = findstr(temp,rowend);
                rows{i} = temp(1:n4(1));
                end
            end            
        end
        function [table] = CropTable(obj,s,tablestart,tableend)
            n1 = findstr(s,tablestart);
            n2 = findstr(s,tableend);
            table = s(n1:n2);
            
            if isempty(table)
                startindex = 1;
                size(n1,2);
                size(n2,2);
                n1 = n1(startindex);
                n = find(n1 < n2);
                n2 = n2(n);
                n2 = n2(1);
                table = s(n1:n2);
            end
        end
    end
end
