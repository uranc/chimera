function [plan, practice, stim] = prep_spose_trials(patient_id, session_nr, p, stim_dir, log_dir)
% PREP_SPOSE_TRIALS  Predetermine the whole SPoSE session and save it before
% trial 1 (same structure as prep_chimera_trials, one trial type).
%   plan : 1 x n_images*p.max_reps trial structs in presentation order; the
%          first n_images*p.min_reps trials hold every image p.min_reps times.
% Order: every image once per round, >= p.min_image_gap trials between repeats,
% never the same concept twice in a row (make_session_order).

stim = load_stimuli(stim_dir, p, 'SPOSE STIMULUS');
disp("... generating trial structure ...");
[seq, rep] = make_session_order([stim.concept_id], p.min_reps, p.max_reps, p.min_image_gap, ...
    0, p.spacing_floor);

plan = repmat(new_trial_cfg(p, patient_id, session_nr), 1, numel(seq));
for t = 1:numel(seq)
    c = fill_trial_stimulus(plan(t), stim(seq(t)));
    c.trial_id   = t;
    c.block_id   = ceil(t / p.pause_every_trials);
    c.rep_id     = rep(t);
    c.is_minimum = t <= numel(stim) * p.min_reps;
    c.trial_type = TaskCodes.TRIAL_TYPES.liftable;
    c.trial_type_name = 'liftable';
    c.jitter_time = draw_jitter(p);
    c.daq_trial_values = TaskCodes.trial_train(c);
    plan(t) = c;
end
practice = plan([]);
fprintf('--- %d trials planned (%d images x %d presentations) ---\n', numel(plan), numel(stim), p.max_reps);

save(fullfile(log_dir, 'spose_plan.mat'), 'plan', 'practice', 'stim', 'p', '-v7');
end
