function save_task_session(log_dir, p, plan, practice, stim, session_cfg, n_run, stop_reason, minutes_run, ...
    paradigm_times_daq, paradigm_events_daq, EThndl)
% SAVE_TASK_SESSION  End-of-session files in the style of run_dynamic_eye
% (-v7, so German texts can be stored), prefixed with the task name (chimera_*, spose_*):
%   <task>_session_cfg.mat           session_cfg (parameters, protocol, stop info)
%   <task>_trials.mat                every planned trial struct (completed flags)
%   <task>_imgOnOff.mat              image on/off times per trial
%   <task>_behavioral_responses.mat  responses, RTs, choices per trial
%   <task>_paradigm_events.mat       paradigm-level daq events
%   <task>_fixation_events.mat       fixation cross times
%   <task>_tobii_data*.mat           Titta session data (or a dummy file)
% Trial-wise vectors have one entry per planned trial (NaN = not run).
% Every trial was also saved on its own right after it ran (save_trial).
tn = p.task_name;
session_cfg.n_trials_run = n_run;
session_cfg.stop_reason = stop_reason;
session_cfg.minutes_run = minutes_run;
save(fullfile(log_dir, [tn '_session_cfg.mat']), 'session_cfg', '-v7');
save(fullfile(log_dir, [tn '_trials.mat']), 'plan', 'practice', 'stim', 'session_cfg', '-v7');

trial_type     = [plan.trial_type];
image_idx      = [plan.stim_idx];
rep_id         = [plan.rep_id];
completed      = [plan.completed];
fix_times_ts   = [plan.ts_fix];
fix_times_daq  = [plan.ts_fix_daq];
imgOn_ts       = [plan.ts_stim_on];
imgOn_daq      = [plan.ts_stim_daq];
imgOff_ts      = [plan.ts_stim_off];
imgOff_daq     = [plan.ts_stim_off_daq];
pat_question_ts     = [plan.ts_question];
pat_question_daq    = [plan.ts_question_daq];
pat_response_values = [plan.response];
pat_response_ts     = [plan.ts_response];
pat_response_daq    = [plan.ts_response_daq];
pat_response_rt     = [plan.rt];
pat_response_rt_question = [plan.rt_question];
pat_chosen_axis_id  = [plan.chosen_axis_id];
pat_correct         = [plan.correct];
pat_voice_onset     = [plan.voice_onset];

save(fullfile(log_dir, [tn '_imgOnOff.mat']), 'imgOn_ts', 'imgOn_daq', 'imgOff_ts', 'imgOff_daq', ...
    'trial_type', 'image_idx', 'rep_id', 'completed', '-v7');
save(fullfile(log_dir, [tn '_behavioral_responses.mat']), 'pat_question_ts', 'pat_question_daq', ...
    'pat_response_values', 'pat_response_ts', 'pat_response_daq', 'pat_response_rt', ...
    'pat_response_rt_question', 'pat_chosen_axis_id', 'pat_correct', 'pat_voice_onset', ...
    'trial_type', 'image_idx', 'rep_id', 'completed', '-v7');
save(fullfile(log_dir, [tn '_paradigm_events.mat']), 'paradigm_events_daq', 'paradigm_times_daq', ...
    'stop_reason', 'n_run', '-v7');
save(fullfile(log_dir, [tn '_fixation_events.mat']), 'fix_times_ts', 'fix_times_daq', '-v7');

% eyetracking info (as run_dynamic_eye)
if p.use_eyetracking && ~isempty(EThndl)
    dat = EThndl.collectSessionData();
    save(EThndl.getFileName(fullfile(log_dir, [tn '_tobii_data']), true), '-struct', 'dat');
else
    dat = struct('eyetracking_used', false, ...
        'note', 'Dummy file - eyetracking was disabled for this session (use_eyetracking = false)', ...
        'patient_id', session_cfg.patient_id, 'session_nr', session_cfg.session_nr, ...
        'timestamp', datestr(now)); %#ok<NASGU>
    save(fullfile(log_dir, [tn '_tobii_data_dummy.mat']), '-struct', 'dat', '-v7');
end
fprintf('Logs written to %s\n', log_dir);
end
