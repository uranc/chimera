function [buttons, axes_, ok] = gamepad_read(dev)
% GAMEPAD_READ  Raw gamepad state through Psychtoolbox.
%   buttons : logical row (pressed = true)
%   axes_   : row of axis values centred at 0 (about -32767..32767)
%   ok      : false if the pad cannot be read
% Windows: WinJoystickMex (ships with Psychtoolbox), joystick dev (0 = first);
%          axes x, y, z (left stick x/y, triggers) and buttons 1-4 (A, B, X, Y
%          on a Logitech F310). The D-pad is not reported by this interface.
% macOS / Linux: Psychtoolbox Gamepad.
buttons = false(1, 0); axes_ = zeros(1, 0); ok = true;
try
    if IsWin
        [x, y, z, b] = WinJoystickMex(dev);
        axes_ = double([x, y, z]) - 32767.5;
        buttons = logical(b(:)');
    else
        n_b = Gamepad('GetNumButtons', dev);
        n_a = Gamepad('GetNumAxes', dev);
        buttons = arrayfun(@(k) Gamepad('GetButton', dev, k), 1:n_b) > 0;
        axes_ = arrayfun(@(k) Gamepad('GetAxis', dev, k), 1:n_a);
    end
catch
    ok = false;
end
end
