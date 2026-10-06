function [cfg, blank_onset, aborted] = run_task_trial(cfg, blank_onset, hw, p, log_dir, trial_fn)
% RUN_TASK_TRIAL  One trial of a ptb task, shared by run_chimera_eye and
% run_spose_eye:
%   trial_start marker + trial train (all predetermined trial parameters)
%   image read from disk
%   blank until blank_onset + blank_duration + jitter_time, then the
%   fixation cross (fixation_cross_eye, dynamic helper)
%   the trial itself: [res, aborted] = trial_fn(cfg, img, hw, p)
%   the trial's cfg merged with res and saved as its own file
% The train and the image read run inside the blank, so the cross appears at
% the planned time unless that work takes longer (blank_actual logs it).
% blank_onset: flip time of the previous blank; returns this trial's blank.
ev = TaskCodes.EVENTS;
ts_trial_daq = send_train(hw, ev.trial_start, cfg.daq_trial_values, ...
    sprintf('trial_block-%i_trial-%i', cfg.block_id, cfg.trial_id));
img = imread(cfg.image_file);

wait_left = max(0, blank_onset + p.blank_duration + cfg.jitter_time - GetSecs);
[ts_fix, ts_fix_daq] = fixation_cross_eye(wait_left, p.fixation_duration, ...
    cfg.block_id, cfg.trial_id, ...
    hw.window, hw.windowRect, ...
    hw.daq, ev.fix_cross, ...
    hw.EThndl);

[res, aborted] = trial_fn(cfg, img, hw, p);

fn = fieldnames(res);
for k = 1:numel(fn), cfg.(fn{k}) = res.(fn{k}); end
cfg.ts_trial_daq = ts_trial_daq;
cfg.ts_fix = ts_fix;
cfg.ts_fix_daq = ts_fix_daq;
cfg.blank_actual = ts_fix - blank_onset;
save_trial(log_dir, p.file_prefix, cfg);
blank_onset = res.ts_blank;
end
