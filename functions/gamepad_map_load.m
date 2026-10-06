function map = gamepad_map_load()
% GAMEPAD_MAP_LOAD  The saved gamepad mapping (calibrate_gamepad), or the
% default (left stick = arrows, buttons 1-4 = Space) if none is saved.
% map.entries: struct array with type ('button' | 'axis'), index (button
% number, or axis number from gamepad_read), sign (+1 / -1 for axes), key (KbName name);
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
ax = {2, -1, 'UpArrow'; 2, 1, 'DownArrow'; 1, -1, 'LeftArrow'; 1, 1, 'RightArrow'};   % left stick
for k = 1:size(ax, 1)
    e(end+1) = struct('type', 'axis', 'index', ax{k, 1}, 'sign', ax{k, 2}, 'key', ax{k, 3}); %#ok<AGROW>
end
map = struct('entries', e, 'dead', 16000, 'source', 'default (stick = arrows, buttons 1-4 = Space; not calibrated)');
end
