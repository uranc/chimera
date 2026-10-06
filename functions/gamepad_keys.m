function [key_code, t] = gamepad_keys(cmd)
% GAMEPAD_KEYS  The gamepad as keys, for every task.
%   [key_code, t] = gamepad_keys()   1 x 256 logical, true for every key the
%                                    pad currently presses (KbName codes, like
%                                    KbCheck's keyCode); t = GetSecs
%   gamepad_keys('reset')            find the pad and reload the mapping
% The mapping (which button / axis direction means which key) comes from
% calibrate_gamepad, saved in setup/gamepad_map.mat; run it once per pad.
% Without a saved mapping a default for the Logitech F310 is used.
% Linux: the pad must be exposed raw by X (setup/53-gamepad-arrows.conf);
% Psychtoolbox reads it with GetMouse(..., device) as buttons + valuators.
% No pad found: returns all false (keyboard only).
persistent dev map ok
if nargin && strcmp(cmd, 'reset'), ok = []; end
key_code = false(1, 256);
t = GetSecs;
if isempty(ok)
    [dev, ok, name] = gamepad_find();
    if ok
        map = gamepad_map_load();
        fprintf('Gamepad: %s (device %d), mapping: %s\n', name, dev, map.source);
    end
end
if ~ok, return; end
try
    [~, ~, buttons, ~, val] = GetMouse([], dev);
catch
    ok = false; return
end
for k = 1:numel(map.entries)
    e = map.entries(k);
    if strcmp(e.type, 'button')
        on = e.index <= numel(buttons) && buttons(e.index);
    else
        on = e.index <= numel(val) && e.sign * val(e.index) > map.dead;
    end
    if on, key_code(KbName(e.key)) = true; end
end
end
