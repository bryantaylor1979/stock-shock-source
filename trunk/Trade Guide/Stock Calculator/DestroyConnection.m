function [] = DestroyStocksConnection()
%UNTITLED1 Summary of this function goes here
%  Detailed explanation goes here

global conn

%check connection
if isempty(conn)
   warning('There is no connection to destroy')
   return
end

close(conn)
clear global conn