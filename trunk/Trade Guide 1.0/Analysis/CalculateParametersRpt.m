function [Output] = CalculateParametersRpt(tablehandle)
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