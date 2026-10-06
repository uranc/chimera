function map = gamepad_map_load()
% GAMEPAD_MAP_LOAD  The saved gamepad mapping (calibrate_gamepad), or the
% default for a Logitech F310 in XInput mode if none is saved.
% map.entries: struct array with type ('button' | 'axis'), index (button
% number, or valuator index), sign (+1 / -1 for axes), key (KbName name);
% map.dead: axis threshold (of +-32767).
f = gamepad_map_file();
if isfile(f)
    s = load(f, 'map');
    map = s.map;
    map.source = f;
    return
end
KbName('UnifyKeyNames');
e = struct('type', {}, 'index', {}, 'sign', {}, 'key', {});
for b = 1:4, e(end+1) = struct('type', 'button', 'index', b, 'sign', 1, 'key', 'space'); end %#ok<AGROW>
ax = {9, -1, 'UpArrow'; 9, 1, 'DownArrow'; 8, -1, 'LeftArrow'; 8, 1, 'RightArrow'; ...   % D-pad
      4, -1, 'UpArrow'; 4, 1, 'DownArrow'; 3, -1, 'LeftArrow'; 3, 1, 'RightArrow'};      % left stick
for k = 1:size(ax, 1)
    e(end+1) = struct('type', 'axis', 'index', ax{k, 1}, 'sign', ax{k, 2}, 'key', ax{k, 3}); %#ok<AGROW>
end
map = struct('entries', e, 'dead', 16000, 'source', 'default (F310, not calibrated)');
end
