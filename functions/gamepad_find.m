function [dev, ok, name] = gamepad_find()
% GAMEPAD_FIND  Psychtoolbox device index of the first real gamepad (Linux:
% X joystick devices, skipping the virtual XTEST pointer).
dev = []; ok = false; name = '';
if ~IsLinux, return; end
try
    [idx, names] = GetGamepadIndices;
catch
    return
end
for k = 1:numel(idx)
    if ~contains(lower(names{k}), 'xtest')
        dev = idx(k); ok = true; name = names{k};
        return
    end
end
end
