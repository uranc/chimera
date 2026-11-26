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
%   all others question  yes/no question (p.question_text, p.question_labels)
% Order constraints (repeat gap, no concept twice in a row, spread of naming
% trials): make_session_order.

%% stimuli
stim = load_stimuli(stim_dir, p, 'CHIMERA STIMULUS');
n_img = numel(stim);
axis_ids = unique([stim.axis_id]);
check_labels({stim.concept_name});

%% presentation order
disp("... generating trial structure ...");
[seq, rep] = make_session_order([stim.concept_id], p.min_reps, p.max_reps, p.min_image_gap, ...
    p.naming_spread * p.use_naming, p.spacing_floor);
n_trials = numel(seq);

%% build the trials
plan = repmat(new_trial_cfg(p, patient_id, session_nr), 1, n_trials);
for t = 1:n_trials
    s = stim(seq(t));
    c = fill_trial_stimulus(plan(t), s);
    c.trial_id   = t;
    c.block_id   = ceil(t / p.pause_every_trials);
    c.rep_id     = rep(t);
    c.is_minimum = t <= n_img * p.min_reps;
    mode = 'question';
    if p.use_naming && rep(t) == 1, mode = 'naming'; end
    c = set_options(c, mode, p);
    c.jitter_time = draw_jitter(p);
    c.daq_trial_values = TaskCodes.trial_train(c);
    plan(t) = c;
end
fprintf('--- %d trials planned (%d images x %d presentations, minimum %d trials) ---\n', ...
    n_trials, n_img, p.max_reps, n_img * p.min_reps);

%% practice
practice = make_practice(p, patient_id, session_nr, stim_dir, stim, axis_ids);

%% save everything predetermined before trial 1
save(fullfile(log_dir, [p.file_prefix '_plan.mat']), 'plan', 'practice', 'stim', 'p', '-v7');
end


%% ------------------------------------------------------------------------
function c = set_options(c, mode, p)
% answer options of one trial: Ja / Nein for question trials, none for naming
n_opt = numel(c.option_axis_ids);
c.trial_type_name = mode;
if strcmp(mode, 'question') && ~isfield(TaskCodes.TRIAL_TYPES, 'question')
    % TaskCodes has no own code for the question yet: the daq gets the
    % adjective trial type until TRIAL_TYPES.question is added
    c.trial_type = TaskCodes.TRIAL_TYPES.adjective;
else
    c.trial_type = TaskCodes.TRIAL_TYPES.(mode);
end
c.option_axis_ids = zeros(1, n_opt);
c.option_names = repmat({''}, 1, n_opt);
c.option_labels = repmat({''}, 1, n_opt);
if strcmp(mode, 'question')
    c.option_names(1:2) = p.question_labels;
    c.option_labels(1:2) = p.question_labels;
end
c.target_pos = 0;
end

function practice = make_practice(p, patient_id, session_nr, stim_dir, stim, axis_ids)
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
cand = cand(~ismember({cand.concept_name}, {stim.concept_name}) & ismember([cand.axis_id], axis_ids));   % by name: indices are per set
if isempty(cand)
    warning('prep_chimera_trials:practice', ['no practice images (concepts outside the session ' ...
        'with the session''s axes) in %s, no practice'], src);
    return
end
check_labels({cand.concept_name});
pick = cand(randperm(numel(cand), min(n_pr, numel(cand))));
practice = repmat(new_trial_cfg(p, patient_id, session_nr), 1, numel(pick));
for k = 1:numel(pick)
    c = fill_trial_stimulus(practice(k), pick(k));
    c.stim_idx = k;
    c.trial_id = k; c.block_id = 0; c.rep_id = 1; c.is_practice = true;
    mode = 'question';
    if p.use_naming && k <= p.n_practice_naming, mode = 'naming'; end
    c = set_options(c, mode, p);
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
