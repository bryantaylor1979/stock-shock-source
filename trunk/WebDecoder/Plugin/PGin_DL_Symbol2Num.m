  classdef PGin_DL_Symbol2Num <     handle & ...
                                    DataSetFiltering & ...
                                    ResultsLog
    properties
    end
    methods 
        function [DATASET] = ProcessALL(obj,ProgramName,ResultName,Symbols,Date)
            x = size(Symbols,1)
            for i = 1:x
                try
                Num(i,1) = obj.Symbol2Num(ProgramName,ResultName,Symbols{i},Date);
                catch
                Num(i,1) = NaN;    
                end
            end
            %%
            DATASET = dataset(Symbols,Num);
        end
        function Num = Symbol2Num(obj,ProgramName,ResultName,Symbol,Date)
            TABLE = obj.LoadResult_Type(ProgramName,ResultName,Symbol,Date,'TABLE');

            %% Filter on Symbols
            SymbolsCol = TABLE(:,4);
            n = find(strcmpi(SymbolsCol,Symbol));
            TABLE = TABLE(n,:);

            %% Filter on Exchange
            Exchange = TABLE(:,5);
            n = find(strcmpi(Exchange,'LSE'));
            TABLE = TABLE(n,:);

            %%
            Num = obj.URL2Num(TABLE{3});
        end
        function Num = URL2Num(obj,Str)
            %%
            Val = Str;
            n = findstr(Val,'=');
            Val = Val(n(end)+1:end);
            n = findstr(Val,'"');
            Num = str2num(Val(1:n(1)-1));
        end
    end
end