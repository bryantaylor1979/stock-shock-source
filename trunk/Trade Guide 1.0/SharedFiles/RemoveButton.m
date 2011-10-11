function [] = AddButton()
%
%Written by:    Bryan Taylor
%Date Modified: 4th March 2008

global h

MoveListboxValue(h.SelectedListbox,h.CompleteListbox)

% Value = get(h.SelectedListbox,'Value');
% OldString = get(h.SelectedListbox,'String');
% 
% %Remove from selection box
% if not(isempty(OldString))
%     Selection = OldString{Value};
% 
%     %Add to SelectionListbox
%     String = get(h.CompleteListbox,'String');
% 
%     if isempty(String)
%         set(h.CompleteListbox,'String',Selection);
%     elseif size(String,1) == 1
%         set(h.CompleteListbox,'String',[{String};{Selection}]);
%     else
%         set(h.CompleteListbox,'String',[String;{Selection}]);
%     end
% 
%     [x] = size(OldString,1);
%     String = [OldString(1:Value-1);OldString(Value+1:x)];
%     set(h.SelectedListbox,'String',String);
%     if Value == 1;
%         set(h.SelectedListbox,'Value',Value);
%     else
%         set(h.SelectedListbox,'Value',Value-1);    
%     end
% end

