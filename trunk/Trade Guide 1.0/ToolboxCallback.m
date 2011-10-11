function [] = ToolboxCallback(obj, event, handles, State,ProgramDir)

switch lower(State)
    case 'stop'        
%% STOP CALLBACK
        State = get(GetHandle(handles.toolbars.toolbar,'Stop'),'State');
        switch lower(State)
            case 'on'
                set(GetHandle(handles.toolbars.toolbar,'Analysis'),'State','off');
                set(handles.Status,'String','Paused');
            case 'off'
                set(GetHandle(handles.toolbars.toolbar,'Analysis'),'State','on');
                % the next if statement ensure the analysis script isn't
                % executed twice.
%                 if strcmp(get(handles.Status,'String'),'Ready')
                    set(handles.Status,'String','Analysis Started ....')
                    Analysis_Callback(handles,ProgramDir);
                    set(GetHandle(handles.toolbars.toolbar,'Stop'),'State','on');
                    set(GetHandle(handles.toolbars.toolbar,'Analysis'),'State','off');
%                 end
        end
    case 'analysis_callback'
        State = get(GetHandle(handles.toolbars.toolbar,'Analysis'),'State');
        switch lower(State)
            case 'on'
                set(GetHandle(handles.toolbars.toolbar,'Stop'),'State','off');
                % the next if statement ensure the analysis script isn't
                % executed twice.
                if strcmp(get(handles.Status,'String'),'Ready')
                    Analysis_Callback(handles,ProgramDir);
                    set(GetHandle(handles.toolbars.toolbar,'Stop'),'State','on');
                    set(GetHandle(handles.toolbars.toolbar,'Analysis'),'State','off');
                end
            case 'off'
                set(GetHandle(handles.toolbars.toolbar,'Stop'),'State','on');
                set(handles.Status,'String','Paused');
        end       
    case 'new'
        
    case 'save'
        
    case 'saveas'
        
    otherwise
        error('Toolbox selection not recognised')
end
drawnow;

