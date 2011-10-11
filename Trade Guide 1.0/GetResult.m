function [Value] = GetResult(StageName,Attribute)
%Example: 
%[Value] = GetResult('NoOfSymbolsPerDay','StartDate');
%
%Written by:    Bryan Taylor
%Date Created:  28th April 2008
global savecriteria

GuiStruct = savecriteria.GuiStruct;
stagename = struct2data(GuiStruct,'stagename');
n = find(strcmpi(stagename,StageName));
output = getfield(GuiStruct(n),'rptoutput');
Value = getfield(output,Attribute);