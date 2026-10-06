function [dev, ok, name] = gamepad_find()
% GAMEPAD_FIND  The first gamepad Psychtoolbox can read.
% Windows: joystick 0 via WinJoystickMex. macOS / Linux: the first
% Psychtoolbox Gamepad whose name says gamepad / joystick / controller.
dev = []; ok = false; name = '';
try
    if IsWin
        if exist('WinJoystickMex', 'file') ~= 3, return; end
        [~, ~, ok_read] = gamepad_read(0);
        if ok_read, dev = 0; ok = true; name = 'Windows joystick 0'; end
    else
        for k = 1:Gamepad('GetNumGamepads')      % the list also holds mice / virtual pointers
            names = Gamepad('GetGamepadNamesFromIndices', k);
            if contains(lower(names{1}), {'gamepad', 'joystick', 'controller'})
                dev = k; ok = true; name = names{1};
                return
            end
        end
    end
catch
    ok = false;
end
end
