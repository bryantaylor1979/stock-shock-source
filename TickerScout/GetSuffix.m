function [suffix] = GetSuffix()
% Get suffix
global h
Value = get(h.exchangepulldown,'Value');
switch Value
    case 1
        suffix = '';
    case 2
        suffix = '.L';
    otherwise
        error('exchange not currently supported')
end