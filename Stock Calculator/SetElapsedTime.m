
function [] = SetElapsedTime()

global handles
time = toc; %in seconds
seconds = floor(rem(time,60));
totalminutes = floor(time/60);
minutes = rem(totalminutes,60);
hours = floor(totalminutes/60);

set(handles.elapsedtime,'String',['Elapsed Time: ',num2str(hours),'h ',num2str(minutes),'m ',num2str(seconds),'s']);