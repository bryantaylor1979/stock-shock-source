function [] = SaveButton();

global h
String = get(h.SelectedListbox,'String');

CalcSetting.CalculationsSelected = String;
save CalcSetting CalcSetting

close(h.figure)