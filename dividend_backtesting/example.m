%%
%TODO: BUG: The search will not got over 45 days???? 

[adjClose,div] =getdata('SPY')

%%
TotalNumberOfDays = 45; %Total Number of day to search
regression_result = backtesting(adjClose,div,TotalNumberOfDays);

figure, plot(regression_result.NoOfDays,regression_result.TotalPerOfNegTrades)
ylabel('Negative trades (%)')
xlabel('No of days')

figure, plot(regression_result.NoOfDays,regression_result.AverageProfitPerDay)
ylabel('Average Profit Per Day')
xlabel('No of days')
    
OptimalNumberOfDays = findoptimalparameters(regression_result)

title(['Optimal Number Of Days: ',num2str(OptimalNumberOfDays)])