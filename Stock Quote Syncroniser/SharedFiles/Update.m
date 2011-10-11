function [] = Update()
%This function does everything required to update you local database.

AddSymbolsIdentified;
DownloadData('empty');
DownloadData('update');