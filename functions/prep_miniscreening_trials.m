function [plan, practice, stim] = prep_miniscreening_trials(patient_id, session_nr, p, stim_dir, log_dir)
% PREP_MINISCREENING_TRIALS  Predetermine the whole mini-screening and save it
% before trial 1 (same outputs as prep_chimera_trials).
%
% Per concept of the session's stimset (stim_dir):
%   original  : originals/..._inst0_level0.jpg        x p.reps_original
%   name      : the concept's German name, drawn on a blank image at run time
%               (image_file empty)                    x p.reps_name
%   exemplar  : originals/..._inst1..n_exemplars      x p.reps_exemplar
% Every trial: 4 words from the session's axes, no target (target_pos 0),
% chosen like chimera's target-absent trials (least-used words per item,
% balanced positions). axis_id / level_id are 0; concept_id is the concept's
% index in the session stimset (also for originals written by another set).
% Order: no concept twice in a row (make_session_order over all
% presentations; repeats of one item are not spaced further).
%   stim : one entry per item (original, name, exemplars), stim_idx = row

%% the session's concepts and axes (words)
sess = load_stimuli(stim_dir, p, 'MINISCREENING: SESSION STIMULUS');
axis_ids = unique([sess.axis_id]);
axis_names = arrayfun(@(a) sess(find([sess.axis_id] == a, 1)).axis_name, axis_ids, 'UniformOutput', false);
[cnames, k] = unique({sess.concept_name}, 'stable');
cids = [sess(k).concept_id];
things = [sess(k).things_id];

%% items
odir = p.originals_dir;
if ~isfolder(odir)
    error('prep_miniscreening_trials:dir', 'originals folder not found: %s', odir);
end
orig = load_stimuli(odir, [], 'MINISCREENING: ORIGINALS');
stim = orig([]);
reps = [];
for c = 1:numel(cnames)
    mine = orig(strcmp({orig.concept_name}, cnames{c}));
    if isempty(mine)
        error('prep_miniscreening_trials:orig', 'no originals for %s in %s', cnames{c}, odir);
    end
    o = mine([mine.inst_id] == 0);
    if isempty(o), error('prep_miniscreening_trials:orig', 'no instance 0 original for %s', cnames{c}); end
    o.axis_name = 'original';
    nm = o;
    nm.image_file = ''; nm.filename = ['name_' cnames{c}]; nm.axis_name = 'name';
    ex = mine([mine.inst_id] >= 1 & [mine.inst_id] <= p.n_exemplars);
    if numel(ex) < p.n_exemplars
        warning('prep_miniscreening_trials:exemplars', '%s: %d of %d exemplars', cnames{c}, numel(ex), p.n_exemplars);
    end
    [~, srt] = sort([ex.inst_id]); ex = ex(srt);
    [ex.axis_name] = deal('exemplar');
    items = [o, nm, ex];
    [items.concept_id] = deal(cids(c));
    [items.things_id] = deal(things(c));
    [items.axis_id] = deal(0);
    [items.level_id] = deal(0);
    stim = [stim, items]; %#ok<AGROW>
    reps = [reps, p.reps_original, p.reps_name, repmat(p.reps_exemplar, 1, numel(ex))]; %#ok<AGROW>
end
for i = 1:numel(stim), stim(i).stim_idx = i; end
check_labels([cnames, axis_names]);

%% presentation order: every presentation once, no concept twice in a row
pres = repelem(1:numel(stim), reps);
rep = zeros(size(pres));
for i = 1:numel(stim), rep(pres == i) = 1:reps(i); end
order = make_session_order([stim(pres).concept_id], 1, 1, 0, 0, 0);
pres = pres(order); rep = rep(order);
n_trials = numel(pres);

%% build the trials
use = zeros(numel(stim), numel(axis_ids));     % word use per item
pos = zeros(numel(axis_ids), p.n_options);     % position use per word
plan = repmat(new_trial_cfg(p, patient_id, session_nr), 1, n_trials);
for t = 1:n_trials
    s = stim(pres(t));
    c = fill_trial_stimulus(plan(t), s);
    c.trial_id   = t;
    c.block_id   = ceil(t / p.pause_every_trials);
    c.rep_id     = rep(t);
    c.is_minimum = true;
    c.trial_type = TaskCodes.TRIAL_TYPES.(s.axis_name);
    c.trial_type_name = s.axis_name;
    % least-used words for this item, then positions by least use per word
    [~, o] = sort(use(s.stim_idx, :) + rand(1, numel(axis_ids)) * 0.5);
    w = o(1:p.n_options);
    use(s.stim_idx, w) = use(s.stim_idx, w) + 1;
    pos_of = zeros(1, p.n_options); free = 1:p.n_options;
    for d = w(randperm(numel(w)))
        [~, q] = sort(pos(d, free) + rand(size(free)) * 0.5);
        pos_of(free(q(1))) = d; free(q(1)) = [];
    end
    for k = 1:p.n_options, pos(pos_of(k), k) = pos(pos_of(k), k) + 1; end
    c.option_axis_ids = axis_ids(pos_of);
    c.option_names = axis_names(pos_of);
    c.option_labels = cellfun(@chimera_labels, c.option_names, 'UniformOutput', false);
    c.target_pos = 0;
    c.jitter_time = draw_jitter(p);
    c.daq_trial_values = TaskCodes.trial_train(c);
    plan(t) = c;
end
fprintf('--- %d trials planned (%d concepts: original x%d, name x%d, %d exemplars x%d) ---\n', ...
    n_trials, numel(cnames), p.reps_original, p.reps_name, p.n_exemplars, p.reps_exemplar);

practice = plan([]);
save(fullfile(log_dir, [p.file_prefix '_plan.mat']), 'plan', 'practice', 'stim', 'p', '-v7');
end


function check_labels(names)
% every word shown to the patient needs a German label in chimera_labels.m
names = unique(names);
missing = names(cellfun(@(n) strcmp(chimera_labels(n), n), names));
if ~isempty(missing)
    warning('prep_miniscreening_trials:labels', 'no German label in chimera_labels.m for: %s', ...
        strjoin(missing, ', '));
end
end
