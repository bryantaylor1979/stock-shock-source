function [] = MoveListboxValue(ToHandle,FromHandle)

Value = get(ToHandle,'Value');
OldString = get(ToHandle,'String');

%Remove from selection box
if not(isempty(OldString))
    Selection = OldString{Value};

    %Add to SelectionListbox
    String = get(FromHandle,'String');

    if isempty(String)
        set(FromHandle,'String',Selection);
    else
        %ensure this is a cell
        if not(iscell(String))
            String = {String}; 
        end
        set(FromHandle,'String',[String;{Selection}]);
    end

    [x] = size(OldString,1);
    String = [OldString(1:Value-1);OldString(Value+1:x)];
    set(ToHandle,'String',String);
    if Value == 1;
        set(ToHandle,'Value',Value);
    else
        set(ToHandle,'Value',Value-1);    
    end
end