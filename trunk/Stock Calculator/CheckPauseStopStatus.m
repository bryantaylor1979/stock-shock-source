function [State] = CheckPauseStopStatus();
%
global handles
Stop = get(handles.stopbutton,'Enable');
Pause = get(handles.pausebutton,'Enable');
if strcmp(Pause,'off');
    State = 'pause';
elseif strcmp(Stop,'off');
    State = 'stop';
else
    State = 'continue';
end