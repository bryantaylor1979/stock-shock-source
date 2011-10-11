function [] = AddButton()
%
%Written by:    Bryan Taylor
%Date Modified: 4th March 2008

global h

MoveListboxValue(h.CompleteListbox,h.SelectedListbox)

% Value = get(h.CompleteListbox,'Value');
% OldString = get(h.CompleteListbox,'String');
% 
% %Remove from selection box
% if not(isempty(OldString))
%     Selection = OldString{Value};
% 
%     %Add to SelectionListbox
%     String = get(h.SelectedListbox,'String');
% 
%     if isempty(String)
%         set(h.SelectedListbox,'String',Selection);
%     elseif size(String,1) == 1
%         set(h.SelectedListbox,'String',[{String};{Selection}]);
%     else
%         set(h.SelectedListbox,'String',[String;{Selection}]);
%     end
% 
%     [x] = size(OldString,1);
%     String = [OldString(1:Value-1);OldString(Value+1:x)];
%     set(h.CompleteListbox,'String',String);
%     if Value == 1;
%         set(h.CompleteListbox,'Value',Value);
%     else
%         set(h.CompleteListbox,'Value',Value-1);    
%     end
% end

