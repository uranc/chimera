function [key_code, t] = gamepad_keys(cmd)
% GAMEPAD_KEYS  The gamepad as keys, for every task.
%   [key_code, t] = gamepad_keys()   1 x 256 logical, true for every key the
%                                    pad currently presses (KbName codes, like
%                                    KbCheck's keyCode); t = GetSecs
%   gamepad_keys('reset')            find the pad and reload the mapping
% Everything goes through Psychtoolbox (gamepad_read); no system setup.
% The mapping (which button / axis direction means which key) comes from
% calibrate_gamepad, saved in setup/gamepad_map.mat; run it once per pad.
% Without a saved mapping: left stick = arrows, buttons 1-4 = Space.
% No pad found: returns all false (keyboard only).
persistent dev map ok
if nargin && strcmp(cmd, 'reset'), ok = []; end
key_code = false(1, 256);
t = GetSecs;
if isempty(ok)
    [dev, ok, name] = gamepad_find();
    if ok
        map = gamepad_map_load();
        fprintf('Gamepad: %s, mapping: %s\n', name, map.source);
    end
end
if ~ok, return; end
[buttons, axes_, read_ok] = gamepad_read(dev);
if ~read_ok, return; end
for k = 1:numel(map.entries)
    e = map.entries(k);
    if strcmp(e.type, 'button')
        on = e.index <= numel(buttons) && buttons(e.index);
    else
        on = e.index <= numel(axes_) && e.sign * axes_(e.index) > map.dead;
    end
    if on, key_code(KbName(e.key)) = true; end
end
end
