function [] = PlotProfit()

global savecriteria

Stage = savecriteria.stage;
GuiStruct = savecriteria.GuiStruct;
GuiStruct = GuiStruct{1};
TradeStructureStake = GuiStruct(Stage).struct;

TotalMoney = cell2mat(Struct2Data(TradeStructureStake,'TotalMoney'));
datenum = cell2mat(Struct2Data(TradeStructureStake,'datenum'));
h.figure1 = figure;
plot(datenum,TotalMoney);
datetick;
xlabel('Date')
ylabel('Profit(£)')

[x] = size(TotalMoney,1);
PercentageGrowth = round(TotalMoney(x)/TotalMoney(1)*10000)/100;
TotalNumberOfDays = datenum(x) - datenum(1);
NumberOfYears = TotalNumberOfDays/365;
APR = round(PercentageGrowth/NumberOfYears*100)/100;

set(h.figure1,'Name','Profit Plot');
set(h.figure1,'NumberTitle','off');   
% set(h.figure,'MenuBar','none');

String = {['PercentageGrowth: ',num2str(PercentageGrowth),'%'];...
          ['TotalNumberOfDays: ',num2str(TotalNumberOfDays)];...
          ['NumberOfYears: ',num2str(NumberOfYears)];...
          ['APR: ',num2str(APR),'%']};
h.text = text(datenum(1),TotalMoney(x)*9/10,String);
    