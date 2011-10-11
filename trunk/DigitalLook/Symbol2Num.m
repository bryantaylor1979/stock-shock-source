classdef Symbol2Num <   handle & ...
                        URL_Download
    methods
        function Main
            %%
            Symbol = 'HAWK';
            Date = 734647;
            s = obj.Load(Symbol,'DigitalLook','Symbol2Num','URL',Date);
        end
        function [Num,Status] = URL_Symbol2Num(obj,Symbol,Date)
            %%
            Status = 0;
            s = obj.Load(Symbol,'DigitalLook','Symbol2Num','URL',Date);    
            try
                Num = obj.GetNum(s,Symbol)
            catch
                Num = NaN;
                Status = -1;
                return
            end
%             obj.StoreSymbolNum(Symbol,Num);
        end
        function Num = GetNum(obj,s,Symbol)
            
            %%
            DATASET = obj.CompanySearch(s,Symbol);
            
            %% Get num from link
            Exchange = obj.GetColumn(DATASET,'Exchange');
            n = find(strcmpi(Exchange,'LSE'));
            LSE_Symbol = DATASET(n,:);
            
            Ticker = obj.GetColumn(LSE_Symbol,'Ticker');
            n = find(strcmpi(Ticker,Symbol));
            LSE_Symbol = LSE_Symbol(n,:);
            
            %%
            CompanyName = obj.GetColumn(LSE_Symbol,'CompanyName');
            shortest = strrep(CompanyName{1},'<a href="/cgi-bin/dlmedia/security.cgi?username=&amp;ac=&amp;csi=','');
            n = findstr(shortest,'">');
            Num = str2num(shortest(1:n-1));
        end
        function DATASET = CompanySearch(obj,s,Symbol)
            %%
            identifier = 'Company Search Results';
            n = findstr(identifier,s);
            if isempty(n)
               identifier = 'Investment Companies Search Results'; 
               n = findstr(identifier,s);
            end
            identifier = '</table>';
            p = findstr(identifier,s);
            
            short = s(n:p);            
            n = findstr(short,'</tr>');
            
            x = size(n,2);
            for i = 2:x
                endo = n(i);
                start = n(i-1);
                crop{i-1} = short(start:endo);
                
                row = crop{i-1};
                
                % Company Name
                identifier = '<td class="dataRegularUl';
                p = findstr(identifier,row);
                shorter = row(p(2)+24:p(3));
                p = findstr('>',shorter);
                st = p(1);
                q = findstr('</td>',shorter);
                CompanyName{i-1,1} = shorter(st+1:q-1);
                
                % Ticker
                p = findstr(identifier,row);
                shorter = row(p(3)+24:p(4));
                p = findstr('>',shorter);
                st = p(1);
                q = findstr('</td>',shorter);
                Ticker{i-1,1} = shorter(st+1:q-1);
                
                % Stock Exchange
                p = findstr(identifier,row);
                shorter = row(p(4)+24:p(5));
                p = findstr('>',shorter);
                st = p(1);
                q = findstr('</td>',shorter);
                Exchange{i-1,1} = shorter(st+1:q-1);   
                
                % Currency             
                p = findstr(identifier,row);
                shorter = row(p(5)+24:p(6));
                p = findstr('>',shorter);
                st = p(1);
                q = findstr('</td>',shorter);
                Currency{i-1,1} = shorter(st+1:q-1);
                
                DATASET = dataset(CompanyName,Ticker,Exchange,Currency);
            end
        end
    end 
    methods
        function [Num,Status] = LOC_Symbol2Num(obj,Symbol2)
            %%
            try
               load([obj.InstallDir,'\Data\Symbol2NumLUT.mat']);
               n = find(strcmpi(Symbol2NumLUT(:,1),Symbol2));
               Num = Symbol2NumLUT{n,2};
               Status = 0;
            catch
                Num = NaN;
                Status = -1; 
            end
        end %Obselete
        function s = LOC_ReadURL(obj,Symbol)
            load s s
        end %Obselete
        function s = WEB_ReadURL(obj,Symbol)
            %%
            url = sprintf(obj.Symbol2NumURL,Symbol);
            s = urlread(url);
        end %Obselete
    end
end