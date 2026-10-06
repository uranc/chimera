function [plan, practice, stim] = prep_chimera_trials(patient_id, session_nr, p, stim_dir, log_dir)
% PREP_CHIMERA_TRIALS  Predetermine the whole chimera session (analogue of
% prep_trial_strx / mini_screening_prep_trial_strx) and save it before trial 1.
%
%   plan     : 1 x n_images*p.max_reps struct array, one cfg per trial, in
%              presentation order. Trials 1..n_images*p.min_reps contain every
%              image exactly p.min_reps times (the minimum the session must
%              reach); the rest are extra presentations run while time allows.
%   practice : practice trials (images of concepts that are not in the session)
%   stim     : the session's images (load_stimuli)
%
% Trial types per image (presentation number = rep_id):
%   rep 1      naming    only if p.use_naming: image stays on, spoken response recorded
%   all others adjective 4 adjectives: the manipulated axis's adjective (target)
%                        + 3 others from the session's axes
%              catch     one in every p.catch_every adjective presentations:
%                        4 adjectives without the target
% Distractor adjectives are the ones used least often for this image so far,
% so each image sees every other adjective about equally often; the target
% position cycles through the 4 positions per image; distractor positions
% follow a global per-adjective position count. Order constraints (repeat gap,
% no concept twice in a row, spread of naming trials): make_session_order.

%% stimuli
stim = load_stimuli(stim_dir, p, 'CHIMERA STIMULUS');
n_img = numel(stim);
axis_ids = unique([stim.axis_id]);
axis_names = arrayfun(@(a) stim(find([stim.axis_id] == a, 1)).axis_name, axis_ids, 'UniformOutput', false);
check_labels([{stim.concept_name}, axis_names]);
if p.catch_every > 0 && numel(axis_ids) < p.n_options + 1
    error('prep_chimera_trials:catch', ['catch trials need at least %d axes (target + %d others), ' ...
        'found %d; set catch_every = 0'], p.n_options + 1, p.n_options, numel(axis_ids));
end
if numel(axis_ids) < p.n_options
    error('prep_chimera_trials:axes', '%d options need at least %d axes, found %d', ...
        p.n_options, p.n_options, numel(axis_ids));
end

%% presentation order
disp("... generating trial structure ...");
[seq, rep] = make_session_order([stim.concept_id], p.min_reps, p.max_reps, p.min_image_gap, ...
    p.naming_spread * p.use_naming, p.spacing_floor);
n_trials = numel(seq);

% catch presentations: within every group of catch_every adjective
% presentations of an image, one at a random position
n_adj = p.max_reps - p.use_naming;          % adjective presentations per image
is_catch = false(n_img, n_adj);
if p.catch_every > 0
    for i = 1:n_img
        for g0 = 1:p.catch_every:n_adj
            g = g0:min(g0 + p.catch_every - 1, n_adj);
            if numel(g) == p.catch_every          % only complete groups get a catch
                is_catch(i, g(randi(numel(g)))) = true;
            end
        end
    end
end

%% build the trials
opt = option_state(n_img, axis_ids, p.n_options);
plan = repmat(new_trial_cfg(p, patient_id, session_nr), 1, n_trials);
for t = 1:n_trials
    s = stim(seq(t));
    c = fill_trial_stimulus(plan(t), s);
    c.trial_id   = t;
    c.block_id   = ceil(t / p.pause_every_trials);
    c.rep_id     = rep(t);
    c.is_minimum = t <= n_img * p.min_reps;
    adj_idx = rep(t) - p.use_naming;         % adjective presentation number
    if p.use_naming && rep(t) == 1
        mode = 'naming';
    elseif is_catch(seq(t), adj_idx)
        mode = 'catch';
    else
        mode = 'adjective';
    end
    [c, opt] = set_options(c, mode, s.stim_idx, opt, axis_ids, axis_names);
    c.jitter_time = draw_jitter(p);
    c.daq_trial_values = TaskCodes.trial_train(c);
    plan(t) = c;
end
fprintf('--- %d trials planned (%d images x %d presentations, minimum %d trials) ---\n', ...
    n_trials, n_img, p.max_reps, n_img * p.min_reps);

%% practice
practice = make_practice(p, patient_id, session_nr, stim_dir, stim, axis_ids, axis_names);

%% save everything predetermined before trial 1
save(fullfile(log_dir, [p.task_name '_plan.mat']), 'plan', 'practice', 'stim', 'p', '-v7');
end


%% ------------------------------------------------------------------------
function opt = option_state(n_img, axis_ids, n_options)
opt.use = zeros(n_img, numel(axis_ids));          % distractor use per image x adjective
opt.tpos = zeros(n_img, n_options);               % target position use per image
opt.pos = zeros(numel(axis_ids), n_options);      % position use per adjective (all trials)
end

function [c, opt] = set_options(c, mode, img, opt, axis_ids, axis_names)
% choose the words of one trial and update the balancing counts
n_opt = numel(c.option_axis_ids);
c.trial_type = TaskCodes.TRIAL_TYPES.(mode);
c.trial_type_name = mode;
if strcmp(mode, 'naming')
    c.option_axis_ids = zeros(1, n_opt);
    c.option_names = repmat({''}, 1, n_opt);
    c.option_labels = repmat({''}, 1, n_opt);
    c.target_pos = 0;
    return
end
tgt = find(axis_ids == c.axis_id, 1);
has_target = strcmp(mode, 'adjective') && ~isempty(tgt);
others = setdiff(1:numel(axis_ids), tgt);
n_d = n_opt - has_target;
% least-used distractors for this image (ties broken at random)
[~, o] = sort(opt.use(img, others) + rand(size(others)) * 0.5);
dis = others(o(1:n_d));
opt.use(img, dis) = opt.use(img, dis) + 1;
% positions
pos_of = zeros(1, n_opt);                          % word index (into axis_ids) per position
free = 1:n_opt;
if has_target
    [~, o] = sort(opt.tpos(img, :) + rand(1, n_opt) * 0.5);
    tp = o(1);
    pos_of(tp) = tgt; free(free == tp) = [];
    opt.tpos(img, tp) = opt.tpos(img, tp) + 1;
end
for d = dis(randperm(numel(dis)))
    [~, o] = sort(opt.pos(d, free) + rand(size(free)) * 0.5);
    pos_of(free(o(1))) = d;
    free(o(1)) = [];
end
for k = 1:n_opt
    opt.pos(pos_of(k), k) = opt.pos(pos_of(k), k) + 1;
end
c.option_axis_ids = axis_ids(pos_of);
c.option_names = axis_names(pos_of);
c.option_labels = cellfun(@chimera_labels, c.option_names, 'UniformOutput', false);
c.target_pos = 0;
if has_target, c.target_pos = find(pos_of == tgt, 1); end
end

function practice = make_practice(p, patient_id, session_nr, stim_dir, stim, axis_ids, axis_names)
% practice images: concepts that are not in the session (no pre-exposure)
n_pr = p.n_practice_naming * p.use_naming + p.n_practice_adj;
practice = repmat(new_trial_cfg(p, patient_id, session_nr), 1, 0);
if n_pr == 0, return; end
src = p.practice_dir;
if isempty(src), src = stim_dir; end
if ~isfolder(src)
    warning('prep_chimera_trials:practice', 'practice folder %s not found, no practice', src);
    return
end
cand = load_stimuli(src, [], 'PRACTICE');
cand = cand(~ismember([cand.concept_id], [stim.concept_id]) & ismember([cand.axis_id], axis_ids));
if isempty(cand)
    warning('prep_chimera_trials:practice', ['no practice images (concepts outside the session ' ...
        'with the session''s axes) in %s, no practice'], src);
    return
end
check_labels({cand.concept_name});
pick = cand(randperm(numel(cand), min(n_pr, numel(cand))));
opt = option_state(numel(pick), axis_ids, p.n_options);
practice = repmat(new_trial_cfg(p, patient_id, session_nr), 1, numel(pick));
for k = 1:numel(pick)
    c = fill_trial_stimulus(practice(k), pick(k));
    c.stim_idx = k;
    c.trial_id = k; c.block_id = 0; c.rep_id = 1; c.is_practice = true;
    mode = 'adjective';
    if p.use_naming && k <= p.n_practice_naming, mode = 'naming'; end
    [c, opt] = set_options(c, mode, k, opt, axis_ids, axis_names);
    c.jitter_time = draw_jitter(p);
    c.daq_trial_values = TaskCodes.trial_train(c);
    practice(k) = c;
end
end

function check_labels(names)
% every word shown to the patient needs a German label in chimera_labels.m
names = unique(names);
missing = names(cellfun(@(n) strcmp(chimera_labels(n), n), names));
if ~isempty(missing)
    warning('prep_chimera_trials:labels', ['no German label in chimera_labels.m for: %s ' ...
        '(the raw filename token will be shown)'], strjoin(missing, ', '));
end
end
