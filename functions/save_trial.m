function save_trial(log_dir, prefix, cfg)
% SAVE_TRIAL  Save one trial's cfg (everything: ids, stimulus, options,
% daq trains, time stamps, response) as its own small file, right after
% the trial: <log_dir>/<prefix>_trials/trial_0001.mat (practice_01.mat),
% prefix = <task>_<run start time>.
d = fullfile(log_dir, [prefix '_trials']);
if ~isfolder(d), mkdir(d); end
if cfg.is_practice
    f = sprintf('practice_%02d.mat', cfg.trial_id);
else
    f = sprintf('trial_%04d.mat', cfg.trial_id);
end
save(fullfile(d, f), 'cfg', '-v7');
end
