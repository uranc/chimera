function run_respmax_dummy(concept_id, n_trials)
% RUN_RESPMAX_DUMMY  Test screen for the response-maximization paradigm
% (slide 42), local only: no daq, no Tobii, windowed.
%
% Stimulus space = a star: the concept's original (alpha 0) in the centre,
% one ray per axis (stimset120: axes 1,2,3,5) with the generated steps.
% Input: arrow keys (or a gamepad / joystick if one is connected).
%   Up / Left / Right / Down each belong to one axis. Pressing an axis's
%   direction moves one step out along that axis if you are in the centre
%   or on that ray; on another ray it moves one step back toward the centre.
% Feedback: a frame of dots around the image; its density = score(position).
% The reference frame on the right shows the target density. Move until the
% two match, then press Space. Esc ends the test.
% score: placeholder = closeness to a hidden target image (random per
% trial). Later this becomes the model / neural score (score_fn below).
%
%   run_respmax_dummy            concept 8 (banana), 5 trials
%   run_respmax_dummy(4, 3)      concept 4 (hamburger), 3 trials

if nargin < 1, concept_id = 8; end
if nargin < 2, n_trials = 5; end
here = fileparts(mfilename('fullpath'));
addpath(genpath(fullfile(here, 'functions')));
rng('shuffle');                              % new order and key mapping every run

%% parameters
stim_dir    = fullfile(here, 'stimuli', 'stimset120');
dir_keys    = {'UpArrow', 'LeftArrow', 'RightArrow', 'DownArrow'};   % direction k -> axis k
max_time    = 30;          % s per trial
step_hold   = 0.25;        % s between steps while a key is held
image_scale = 0.6;
n_dots_max  = 400;         % dots in the frame at score 1
frame_width = 40;          % px
log_dir     = fullfile(here, 'logs', 'respmax_test');
if ~isfolder(log_dir), mkdir(log_dir); end

%% stimuli: the star for one concept
stim = load_stimuli(stim_dir, [], 'RESPMAX');
stim = stim([stim.concept_id] == concept_id);
if isempty(stim), error('no images for concept %d in %s', concept_id, stim_dir); end
axes_ = unique([stim.axis_id]);
axes_ = axes_(1:min(4, end));
alphas = unique([stim.alpha]);                       % includes 0 = original
n_steps = numel(alphas) - 1;
img_file = cell(numel(axes_), numel(alphas));
for a = 1:numel(axes_)
    for s = 1:numel(alphas)
        k = find([stim.axis_id] == axes_(a) & abs([stim.alpha] - alphas(s)) < 1e-6, 1);
        img_file{a, s} = stim(k).image_file;
    end
end
fprintf('Concept %s: %d axes x %d steps. Keys: %s\n', stim(1).concept_name, numel(axes_), n_steps, ...
    strjoin(arrayfun(@(a) sprintf('%s=%s', dir_keys{a}, stim(find([stim.axis_id] == axes_(a), 1)).axis_name), ...
    1:numel(axes_), 'UniformOutput', false), ', '));

%% screen
KbName('UnifyKeyNames');
Screen('Preference', 'SkipSyncTests', 1);
[win, wrect] = Screen('OpenWindow', max(Screen('Screens')), 0, [0 0 1280 800]);
Screen('BlendFunction', win, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
white = WhiteIndex(win);
tex = zeros(size(img_file));
for k = 1:numel(img_file)
    tex(k) = Screen('MakeTexture', win, imread(img_file{k}));
end
img = imread(img_file{1});
dest = image_dest_rect(img, wrect, image_scale);
dest = OffsetRect(dest, -0.12 * wrect(3), 0);        % image left, reference right
ref = CenterRectOnPoint([0 0 0.18 0.18] .* wrect([3 4 3 4]), wrect(3) * 0.82, wrect(4) / 2);
dots_img = dot_frame(dest, frame_width, n_dots_max);   % fixed positions: no flicker
dots_ref = dot_frame(ref, frame_width, n_dots_max);
has_pad = exist('Gamepad', 'file') == 2 && Gamepad('GetNumGamepads') > 0;
if has_pad, disp('Gamepad found: axes 1/2 move the image.'); end

results = struct('trial', {}, 'target', {}, 'path', {}, 'times', {}, 'final', {}, 'score', {}, 'rt', {});
try
    for tr = 1:n_trials
        target = [randi(numel(axes_)), randi(n_steps)];  % hidden target: (axis, step)
        score_fn = @(pos) 1 - star_distance(pos, target) / (2 * n_steps);
        pos = [1, 0];                                    % (axis, step); step 0 = centre
        path = pos; times = 0;
        t0 = GetSecs; t_last = -Inf; done = false; quit_all = false;
        while ~done
            % input -> direction (1..4) or 0
            d = 0;
            [~, t, kc] = KbCheck;
            for k = 1:numel(axes_)
                if kc(KbName(dir_keys{k})), d = k; end
            end
            if has_pad && d == 0
                x = Gamepad('GetAxis', 1, 1) / 32768; y = Gamepad('GetAxis', 1, 2) / 32768;
                if max(abs([x y])) > 0.5
                    if abs(y) >= abs(x), d = 1 + 3 * (y > 0); else, d = 2 + (x > 0); end
                end
            end
            if kc(KbName('Space')), done = true; end
            if kc(KbName('Escape')), done = true; quit_all = true; end
            if d > 0 && d <= numel(axes_) && t - t_last >= step_hold
                pos = step(pos, d, n_steps);
                path(end+1, :) = pos; times(end+1) = t - t0; %#ok<AGROW>
                t_last = t;
            end
            if t - t0 > max_time, done = true; end

            % draw: image, dot frame (score), reference frame (target)
            sc = score_fn(pos);
            Screen('DrawTexture', win, tex(pos(1), pos(2) + 1), [], dest);
            n = round(sc * n_dots_max);
            if n > 0, Screen('DrawDots', win, dots_img(:, 1:n), 3, white, [], 1); end
            Screen('FillRect', win, 40, ref);
            Screen('DrawDots', win, dots_ref, 3, white, [], 1);
            Screen('TextSize', win, 24);
            DrawFormattedText(win, sprintf('Trial %d/%d   Pfeile / Joystick: bewegen,  Leertaste: fertig', tr, n_trials), ...
                'center', wrect(4) - 40, white);
            Screen('Flip', win);
        end
        KbReleaseWait;
        results(end+1) = struct('trial', tr, 'target', target, 'path', path, 'times', times, ...
            'final', pos, 'score', score_fn(pos), 'rt', GetSecs - t0); %#ok<AGROW>
        fprintf('trial %d: target axis %d step %d | final axis %d step %d | score %.2f | %d moves\n', ...
            tr, target, pos, score_fn(pos), size(path, 1) - 1);
        if quit_all, break; end
    end
catch ME
    sca; rethrow(ME);
end
sca;
f = fullfile(log_dir, sprintf('respmax_test_%s.mat', datestr(now, 'yyyymmdd_HHMMSS')));
save(f, 'results', 'img_file', 'axes_', 'alphas', 'concept_id', '-v7');
fprintf('Saved %s\n', f);
end


function pos = step(pos, d, n_steps)
% star navigation: out along axis d from the centre or ray d, else inward
if pos(2) == 0 || pos(1) == d
    pos = [d, min(n_steps, pos(2) + 1)];
else
    pos(2) = pos(2) - 1;
end
end

function dist = star_distance(a, b)
% steps along the star between two positions (axis, step)
if a(1) == b(1) || a(2) == 0 || b(2) == 0
    dist = abs(a(2) - b(2));     % same ray, or one end is the centre
else
    dist = a(2) + b(2);          % different rays: via the centre
end
end

function xy = dot_frame(r, w, n)
% n fixed random dot positions in a band of width w around rect r
outer = InsetRect(r, -w, -w);
xy = zeros(2, 0);
while size(xy, 2) < n
    p = [outer(1) + rand(1, n) * RectWidth(outer); outer(2) + rand(1, n) * RectHeight(outer)];
    inside = p(1, :) > r(1) & p(1, :) < r(3) & p(2, :) > r(2) & p(2, :) < r(4);
    xy = [xy, p(:, ~inside)]; %#ok<AGROW>
end
xy = xy(:, 1:n);
end
