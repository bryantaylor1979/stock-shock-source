function [Names] = GetTableColumnNames(Selection)
%Get column names from table
%
%Written by:    Bryan Taylor
%Date Modified: 7th June 2008

Names = feval([Selection,'Fcn'],'ColumnNames');