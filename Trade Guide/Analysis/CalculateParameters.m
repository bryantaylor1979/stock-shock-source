classdef CalculateParameters
    properties
       Mode = 'fastupdate'; %or update/fastupdate 
       Config = true;
       ColumnNames = [];
       CalculationsSelected = { 'PriceMean'; ...
                                'PercentageChange'; ...
                                'TradeSignal'};
       TradeGuideHandle = [];
    end
    methods
        function [Output] = Process(varargin)    
            
            global conn h
            conn = database('SaxoTrader','','');

            %% Check
            try
            [OutPutArray] = TradeGuideHandle.GetStageData('CalculateParameters');
            [x] = size(OutPutArray,1);
            symbol = OutPutArray{x,1};
            n = find(strcmpi(OutPutArray,symbol))
            Status = 'Update';
            StartPoint = n + 1;
            catch
            Status = 'Complete';   
            StartPoint = 1;
            end

            try
                %% Get Data
                [OutPutArray] = TradeGuideHandle.GetStageData('GetFieldNames');

                %% Filter all failed
                n = find(strcmpi(OutPutArray(:,2),'Pass'));
                OutPutArray = OutPutArray(n,:);
            catch
                disp('Warning: Could not find getfieldnames report')
                [OutPutArray] = TradeGuideHandle.GetStageData('DateRange');
                OutPutArray = OutPutArray(:,1);
            end

            %% Get Calculations
            NewCalculation = obj.CalculationsSelected

            Output = 1;
            x = size(OutPutArray,1)
            h1 = waitbar(0);
            for i = StartPoint:x %loop over symbols
                set(h.Status,'String',[num2str((i-StartPoint)/(x-StartPoint)*100,3),'% Complete']);
                drawnow;

                %Check Stop
                State = get(h.toolbars.Stop,'State');
                if strcmpi(State,'on')
                   close(h1)
                   return
                end

                clear RowInfo
                waitbar(i/x,h1);
                if iscell(OutPutArray)
                    symbol = OutPutArray{i,1};
                else
                    symbol = OutPutArray(i,1);
                end
            %     disp(symbol);
                [y] = size(NewCalculation,1);
                struct.symbol = symbol;
                for j = 1:y %loop over calculations
            %          fprintf(['Calculating & Appending: ',NewCalculation{j},' '])
                     try
                         [NewData] = feval(NewCalculation{j},symbol);
                         Status = 'Pass';
                         %        %Check the field name is there
                         if not(NewData(1) == -1)           
                            try
                            obj.AppendData(conn, symbol,NewData,NewCalculation{j},Mode);
                            Status = 'Pass';
                            catch
                            Status = 'Failed to Append';
                            end
                         end
                     catch
                     Status = 'Failed to Calc';    
                     end
                     RowInfo{1,j} = Status; 
                     struct = setfield(struct,NewCalculation{j},Status);
                     fprintf(['Complete\n'])
                end
                RowInfo = [{symbol},RowInfo];
                TradeGuideHandle.AddRow(RowInfo);
                disp(' ');
            end
            %close(h)
        end        
        function [Output] = Report(tablehandle)
            %
            %Written by:    Bryan Taylor
            %Date Created:  3rd August 2008
            %Date Modified: 3rd August 2008


            [OutPutArray] = GetStageData('CalculateParameters');

            poin = size(OutPutArray);

            Values = OutPutArray(:,2:poin(2));
            Pass = strcmpi(Values,'Pass');
            NoPass = sum(rot90(Pass));

            NumberPassed = size(find(NoPass == 3),2);
            TotalNumber = poin(1);
            NumberFailed = TotalNumber-NumberPassed;

            string = {  ['Total Number Passed: ',num2str(NumberPassed),' (',num2str(round(NumberPassed/TotalNumber*100)),'%)']; ...
                        ['Total Number Failed: ',num2str(NumberFailed),' (',num2str(round(NumberFailed/TotalNumber*100)),'%)']; ...
                        };

            uiwait(msgbox(string))

            Output.NumberPassed = NumberPassed;
            Output.NumberFailed = NumberFailed;
            Output.TotalNumber = TotalNumber;
        end
    end
    methods (Hidden = true)
        function [obj] = CalculateParameters(obj);
        end 
        function [] = AppendData(conn,symbol,data,FieldName,Mode);
            %Append Data to databased
            %
            %Written by: Bryan Taylor
            %Date Created: 25th Febuary 2008
            %Date Modified: 25th Febuary 2008

            %Check the field name is there
            [y] = size(data,1);
            whereclause = '';
            count = 1;
            Updated = 'false';

            [Date,OldData] = StockQuote(symbol,{'DateNum';FieldName},'all','report',false,'outputs','multiple');
            if CompareData(data,OldData)
                drawnow;
            else
                for j = 1:y
                    if not(data(j) == OldData(j))
                        Updated = 'true';
                        if strcmpi(Mode,'update')
                            try
                            whereclause = ['WHERE datenum = ',num2str(Date(j))];
                            update(conn, symbol, {FieldName}, data(j), whereclause);
                            catch
                            disp(['Symbol: ',symbol,' DateNum: ',num2str(OldData(j))])
                            error('Update not possible')
                            end
                        else
                        if j == 1
                            whereclause = {['WHERE datenum = ',num2str(Date(j))]};
                        else
                            whereclause = [whereclause;{['WHERE datenum = ',num2str(Date(j))]}];
                        end
                        AppendDatas(count,1) = data(j);
                        count = count + 1;
                        end
                    end
                end
            end
            disp(['Updated: ',Updated])
            if strcmpi(Mode,'fastupdate')
                try
                    if exist('AppendDatas')
                    update(conn, symbol, {FieldName}, AppendDatas, whereclause);
                    disp('fast update complete');
                    else
                    disp('symbol up to date')    
                    end
                catch
                    disp(['Symbol: ',symbol,' DateNum: ',num2str(OldData(j))])
                    error('Update not possible')
                end
            end
        end
    end
end