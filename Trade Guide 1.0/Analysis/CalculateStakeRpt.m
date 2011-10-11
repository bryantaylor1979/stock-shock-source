function [Output] = CalculateStake(tablehandle)

global savecriteria

% Stage = savecriteria.stage;
% GuiStruct = savecriteria.GuiStruct;
% GuiStruct = GuiStruct{1};
% TradeStructureStake = GuiStruct(Stage).struct;

% TotalMoney = cell2mat(Struct2Data(TradeStructureStake,'TotalMoney'));
% datenum = cell2mat(Struct2Data(TradeStructureStake,'datenum'));
meanTotalMoney = str2double(GetTableData(tablehandle,'TotalMoney'));
datenum = str2double(GetTableData(tablehandle,'DateNum'));


h.figure = figure;

%Increase Size Of Figure
Position = get(h.figure,'Position');
Position(4) = Position(4)+50;
set(h.figure,'Position',Position);


h.line = plot(datenum,meanTotalMoney);
h.axes = gca;
Position = get(h.axes,'Position');
Position(4) = 0.7;
Position(2) = 0.2;
set(h.axes,'Position',Position);

datetick;
xlabel('Date')
ylabel('Profit(£)')
title('Profit Curve')

[x] = size(meanTotalMoney,2);
PercentageGrowth = round(meanTotalMoney(1)/meanTotalMoney(x)*10000)/100;
TotalNumberOfDays = datenum(1) - datenum(x);
NumberOfYears = TotalNumberOfDays/365;
APR = round(PercentageGrowth/NumberOfYears*100)/100;

set(h.figure,'Name','Profit Plot');
set(h.figure,'NumberTitle','off');   
% set(h.figure,'MenuBar','none');

String = {['PercentageGrowth: ',num2str(PercentageGrowth),'%'];...
          ['TotalNumberOfDays: ',num2str(TotalNumberOfDays)];...
          ['NumberOfYears: ',num2str(NumberOfYears)];...
          ['APR: ',num2str(APR),'%']};
      
Output.PercentageGrowth = PercentageGrowth;
Output.TotalNumberOfDays = TotalNumberOfDays;
Output.NumberOfYears = NumberOfYears;
Output.APR = APR;
      
h.text = uicontrol( 'Style','text', ...
                    'String',String, ...
                    'HorizontalAlignment','left');
set(h.text,'Position',[40,10,200,60]);

    