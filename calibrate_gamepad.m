function calibrate_gamepad()
% CALIBRATE_GAMEPAD  Teach the tasks which gamepad control means which key.
% Run once per gamepad (in MATLAB, pad plugged in, X configured with
% setup/53-gamepad-arrows.conf). For each key you press the control you want
% for it; every press is recorded as a button or an axis direction.
% Saved to setup/gamepad_map.mat and used by gamepad_keys in every task.
% You can press more than one control per key (e.g. D-pad AND stick for an
% arrow): press, release, press the next; ENTER in the Command Window when done.
here = fileparts(mfilename('fullpath'));
addpath(genpath(fullfile(here, 'functions')));
KbName('UnifyKeyNames');
[dev, ok, name] = gamepad_find();
if ~ok, error('calibrate_gamepad:none', 'No gamepad found (is X configured? see setup/).'); end
fprintf('Gamepad: %s (device %d)\n', name, dev);

keys = {'UpArrow', 'DownArrow', 'LeftArrow', 'RightArrow', 'space'};
what = {'UP', 'DOWN', 'LEFT', 'RIGHT', 'ANSWER / CONTINUE (= Space)'};
dead = 16000;
e = struct('type', {}, 'index', {}, 'sign', {}, 'key', {});
for k = 1:numel(keys)
    fprintf('\nPress the control(s) for %s, one at a time. Then press ENTER here.\n', what{k});
    [~, ~, b0, ~, v0] = GetMouse([], dev);           % rest state
    got = 0;
    while true
        [~, ~, b, ~, v] = GetMouse([], dev);
        [down, ~, kc] = KbCheck(-1);
        if down && kc(KbName('Return')) && got > 0, KbReleaseWait; break; end
        nb = find(b & ~b0, 1);
        na = find(abs(v - v0) > dead & abs(v) > dead, 1);
        if ~isempty(nb)
            e(end+1) = struct('type', 'button', 'index', nb, 'sign', 1, 'key', keys{k}); %#ok<AGROW>
            fprintf('   button %d -> %s\n', nb, keys{k}); got = got + 1;
            wait_rest(dev, b0, v0, dead);
        elseif ~isempty(na)
            e(end+1) = struct('type', 'axis', 'index', na, 'sign', sign(v(na)), 'key', keys{k}); %#ok<AGROW>
            fprintf('   axis %d %s -> %s\n', na, ternary(v(na) < 0, 'low', 'high'), keys{k}); got = got + 1;
            wait_rest(dev, b0, v0, dead);
        end
        WaitSecs(0.01);
    end
end
map = struct('entries', e, 'dead', dead, 'device_name', name, 'created', datestr(now)); %#ok<NASGU>
f = gamepad_map_file();
save(f, 'map', '-v7');
gamepad_keys('reset');
fprintf('\nSaved %d mappings to %s\n', numel(e), f);
end

function wait_rest(dev, b0, v0, dead)
% wait until the pad is back at rest
while true
    [~, ~, b, ~, v] = GetMouse([], dev);
    if ~any(b & ~b0) && all(abs(v - v0) < dead / 2 | abs(v) < dead / 2), return; end
    WaitSecs(0.01);
end
end

function s = ternary(c, a, b)
if c, s = a; else, s = b; end
end
