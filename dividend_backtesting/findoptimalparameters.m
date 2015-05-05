function OptimalNumberOfDays = findoptimalparameters(regression_result)
    %%
    Sorted = sortrows([regression_result.NoOfDays',regression_result.TotalPerOfNegTrades'],2)
    OptimalNumberOfDays = Sorted(1,1);
end