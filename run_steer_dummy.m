function run_steer_dummy(concept_ids, reps)
% RUN_STEER_DUMMY  Test screen for task 3b, steer-to-adjective (local only:
% no daq, no Tobii, windowed 640x480 for the remote VNC test).
%
% Each trial shows a target adjective. The image starts at the concept's
% original (centre of a star); each arrow key is one "knob" = one direction
% in image space (here the stimset120 axes, later neural directions and
% controls). Pressing a knob moves one step out along its direction, or one
% step back toward the original if you are on another direction. Make the
% image fit the adjective, then press Space. Esc ends the test. No time limit.
% A small map (bottom right) shows the star of directions and where you are
% (rays unlabelled, so it does not reveal which direction is which word).
% The key -> direction mapping is reshuffled every trial, so the patient has
% to explore which knob does what (otherwise "up = metallic" is learned).
%
%   run_steer_dummy                concepts 8 and 5, every adjective once
%   run_steer_dummy([8 4 5], 2)    3 concepts, every adjective twice
% Logged per trial: concept, target adjective, key mapping, path with times,
% final direction and step, whether the final direction is the target's
% axis, reaction time.

if nargin < 1, concept_ids = [8 5]; end
if nargin < 2, reps = 1; end
here = fileparts(mfilename('fullpath'));
addpath(genpath(fullfile(here, 'functions')));
rng('shuffle');                              % new order and key mapping every run

%% parameters
stim_dir    = fullfile(here, 'stimuli', 'stimset120');
keys        = {'UpArrow', 'LeftArrow', 'RightArrow', 'DownArrow'};
max_time    = Inf;         % s per trial (Inf = no time limit, ends with Space)
step_hold   = 0.12;        % s between steps while a key is held
image_scale = 0.62;
window_rect = [0 0 640 480];
text_size   = 18;
log_dir     = fullfile(here, 'logs', 'steer_test');
if ~isfolder(log_dir), mkdir(log_dir); end

%% stimuli: one star per concept
all_stim = load_stimuli(stim_dir, [], 'STEER');
axes_ = unique([all_stim.axis_id]);
axes_ = axes_(1:min(numel(keys), end));
axis_names = arrayfun(@(a) all_stim(find([all_stim.axis_id] == a, 1)).axis_name, axes_, 'UniformOutput', false);
alphas = unique([all_stim.alpha]);              % includes 0 = original
n_steps = numel(alphas) - 1;

% trials: every concept x target adjective, reps times, shuffled
[cc, aa] = ndgrid(concept_ids, 1:numel(axes_));
trials = repmat([cc(:), aa(:)], reps, 1);
trials = trials(randperm(size(trials, 1)), :);

%% screen
KbName('UnifyKeyNames');
Screen('Preference', 'SkipSyncTests', 1);
[win, wrect] = Screen('OpenWindow', max(Screen('Screens')), 0, window_rect);
Screen('BlendFunction', win, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
white = WhiteIndex(win);
Screen('TextSize', win, text_size);

results = struct('trial', {}, 'concept_id', {}, 'target_axis', {}, 'target_label', {}, ...
    'key_to_axis', {}, 'path', {}, 'times', {}, 'final_axis', {}, 'final_step', {}, ...
    'hit_target_axis', {}, 'rt', {}, 'timed_out', {});
quit_all = false;
try
    for tr = 1:size(trials, 1)
        cid = trials(tr, 1); tgt = trials(tr, 2);
        [tex, img0] = load_star(win, all_stim, cid, axes_, alphas);
        dest = image_dest_rect(img0, wrect, image_scale);
        dest = OffsetRect(dest, 0, 0.04 * wrect(4));
        map = randperm(numel(axes_));            % key k moves along axis map(k)
        target_label = strrep(chimera_labels(axis_names{tgt}), '|', ' / ');

        pos = [map(1), 0];                       % (axis index, step); step 0 = original
        path = pos; times = 0;
        t0 = GetSecs; t_last = -Inf; done = false; timed_out = false;
        wait_keys_up({'space', 'ESCAPE', 'UpArrow', 'DownArrow', 'LeftArrow', 'RightArrow'});   % only these keys (Windows laptops may report others as always down)
        while ~done
            [~, t, kc] = check_keys();      % keyboard + gamepad
            for k = 1:numel(axes_)
                if kc(KbName(keys{k})) && t - t_last >= step_hold
                    pos = step(pos, map(k), n_steps);
                    path(end+1, :) = pos; times(end+1) = t - t0; %#ok<AGROW>
                    t_last = t;
                end
            end
            if kc(KbName('Space')), done = true; end
            if kc(KbName('Escape')), done = true; quit_all = true; end
            if t - t0 > max_time, done = true; timed_out = true; end

            Screen('DrawTexture', win, tex(pos(1), pos(2) + 1), [], dest);
            draw_star_map(win, wrect, pos, map, n_steps, white);
            DrawFormattedText(win, sprintf('Machen Sie das Bild:  %s', target_label), 'center', 0.07 * wrect(4), white);
            DrawFormattedText(win, sprintf('Pfeiltasten: verändern,  Leertaste: fertig   (%d/%d)', tr, size(trials, 1)), ...
                'center', wrect(4) - 0.04 * wrect(4), white);
            Screen('Flip', win);
        end
        rt = GetSecs - t0;
        Screen('Close', tex(:));
        Screen('Flip', win);
        results(end+1) = struct('trial', tr, 'concept_id', cid, 'target_axis', axes_(tgt), ...
            'target_label', target_label, 'key_to_axis', axes_(map), 'path', [axes_(path(:, 1))', path(:, 2)], ...
            'times', times, 'final_axis', axes_(pos(1)) * (pos(2) > 0), 'final_step', pos(2), ...
            'hit_target_axis', pos(1) == tgt && pos(2) > 0, 'rt', rt, 'timed_out', timed_out); %#ok<AGROW>
        fprintf('trial %d: concept %d, target %s | final axis %d step %d | %s | %d moves, %.1f s\n', tr, cid, ...
            target_label, results(end).final_axis, pos(2), ternary(results(end).hit_target_axis, 'HIT', 'miss'), ...
            size(path, 1) - 1, rt);
        if quit_all, break; end
        WaitSecs(0.5);
    end
catch ME
    sca; rethrow(ME);
end
sca;
f = fullfile(log_dir, sprintf('steer_test_%s.mat', datestr(now, 'yyyymmdd_HHMMSS')));
save(f, 'results', 'axes_', 'axis_names', 'alphas', '-v7');
fprintf('Saved %s  (target axis hit in %d of %d trials)\n', f, sum([results.hit_target_axis]), numel(results));
end


function [tex, img0] = load_star(win, stim, cid, axes_, alphas)
% textures (axis x step) for one concept; step 1 = original (alpha 0)
tex = zeros(numel(axes_), numel(alphas));
for a = 1:numel(axes_)
    for s = 1:numel(alphas)
        k = find([stim.concept_id] == cid & [stim.axis_id] == axes_(a) & abs([stim.alpha] - alphas(s)) < 1e-6, 1);
        if isempty(k), error('missing image: concept %d axis %d alpha %.1f', cid, axes_(a), alphas(s)); end
        img = imread(stim(k).image_file);
        if a == 1 && s == 1, img0 = img; end
        tex(a, s) = Screen('MakeTexture', win, img);
    end
end
end

function draw_star_map(win, wrect, pos, map, n_steps, color)
% small map, bottom right: rays up / left / right / down (as the keys), a tick
% per step, a filled dot at the current position (centre = original)
r = 0.11 * wrect(4);                          % ray length in px
c = [wrect(3) - r - 15, wrect(4) - r - 15];   % map centre
dirs = [0 -1; -1 0; 1 0; 0 1];                % up, left, right, down (key order)
for k = 1:4
    Screen('DrawLine', win, color * 0.5, c(1), c(2), c(1) + dirs(k, 1) * r, c(2) + dirs(k, 2) * r, 1);
    for st = 1:n_steps
        p = c + dirs(k, :) * r * st / n_steps;
        Screen('DrawDots', win, p', 3, color * 0.5, [], 1);
    end
end
k = find(map == pos(1), 1);                   % which ray (key direction) holds the current axis
p = c + dirs(k, :) * r * pos(2) / n_steps;
Screen('DrawDots', win, p', 9, [255 200 0], [], 2);
end

function pos = step(pos, d, n_steps)
% star navigation: out along direction d from the original or ray d, else inward
if pos(2) == 0 || pos(1) == d
    pos = [d, min(n_steps, pos(2) + 1)];
else
    pos(2) = pos(2) - 1;
end
end

function s = ternary(c, a, b)
if c, s = a; else, s = b; end
end

function wait_keys_up(names)
codes = KbName(names);
while true
    [~, ~, kc] = check_keys();
    if ~any(kc(codes)), return; end
    WaitSecs(0.01);
end
end
