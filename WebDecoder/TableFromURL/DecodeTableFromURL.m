classdef DecodeTableFromURL < handle
    properties
        s
        RemoveFormatting = true;
        tableNum = 6;
        TableStart = '<table'
        TableEnd = '</table>'
        RemoveFirstRow = true;
        RowStart = '<td'
        RowEnd = '</tr>'
        CellStart = '<td'
        CellEnd = '</td>'
        CellEndT = '</td>'
        Table
    end
    methods
        function Example(obj)
            %%
            close all
            clear classes
            load('/var/lib/jenkins/jobs/Stox SymbolList Download/workspace/URL_Download/Results/A.mat')
            obj = DecodeTableFromURL()
            obj.s = s;
            obj.RUN();
            obj.Table
        end
        function RUN(obj)
            %%           
            [table] = obj.CropTable(obj.s,obj.TableStart,obj.TableEnd,obj.tableNum);
            [rows] = obj.CropRows(table,obj.RowStart,obj.RowEnd);
            obj.Table = obj.GetAllCells(rows,obj.CellStart,obj.CellEnd,obj.CellEndT); 
            if obj.RemoveFormatting == true
                obj.Table = obj.RemoveFormating(obj.Table);
            end
        end
    end
    methods (Hidden = true) %DecodeTable - Support
        function cells = GetAllCells(obj,rows,cellstart,cellend,cellend2)
            %%
            x = max(size(rows));
            cells = [];
            if obj.RemoveFirstRow == true
                start = 2;
            else
                start = 1;
            end
            for i = start:x
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
            NumberOfPossibles = max(size(n3));
            disp([num2str(NumberOfPossibles),' rows detected'])
            complete = false;
            count = 1;
            while complete == false
                [table, row, complete] = obj.GetNextRow(table,rowstart,rowend);
                if complete == false
                    rows{count} = row;
                end
                count = count + 1;
                if count == NumberOfPossibles
                   break 
                end
            end
        end
        function [table_reduced, row, complete] = GetNextRow(obj,table,rowstart,rowend)
            n3 = findstr(table,rowstart);
            if isempty(n3)
                complete = true;
                row = [];
                table_reduced = [];
                return
            else
                complete = false; 
            end
            n4 = findstr(table,rowend);
            temp = table(n3(1):end);
            n4 = findstr(temp,rowend);
            row = temp(1:n4(1)); 
            table_reduced = temp(n4(1):end);
        end
        function [table] = CropTable(obj,s,tablestart,tableend,tableNum)
            n1 = findstr(s,tablestart);
            table = s(n1(tableNum):end);
            n2 = findstr(table,tableend);
            table = table(1:n2(1));           
        end
        function TableOUT = RemoveFormating(obj,Table)
            %%
            [x,y] = size(Table);
            for i = 1:x
               for j = 1:y
                   str = Table{i,j};
                   n = findstr(str,'>');
                   string = str(n(end-1)+1:end);
                   n1 = findstr(string,'<');
                   TableOUT{i,j} = string(1:n1-1);
               end
            end
        end
    end
end
