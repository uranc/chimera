function r = empty_trial_results()
% EMPTY_TRIAL_RESULTS  The run-time fields of one trial, all unset.
% Defined once here and used by the plan builders (to preset every trial)
% and by the trial helpers (to start each result), so the per-trial cfg
% always has the same fields in the same order.
% Times are GetSecs/flip times; *_daq are the daqOut time stamps.
r = struct( ...
    'completed',          false, ...   % trial ran to its end
    'aborted',            false, ...   % F10 during this trial
    'ts_trial_daq',       NaN, ...     % trial_start marker
    'ts_fix',             NaN, ...     % fixation cross onset (flip)
    'ts_fix_daq',         NaN, ...
    'blank_actual',       NaN, ...     % s from the previous trial's blank onset to the cross
    'ts_stim_on',         NaN, ...     % image onset (flip)
    'ts_stim_daq',        NaN, ...
    'ts_stim_off',        NaN, ...     % image offset (flip)
    'ts_stim_off_daq',    NaN, ...
    'ts_question',        NaN, ...     % words / prompt onset (flip)
    'ts_question_daq',    NaN, ...
    'ts_response',        NaN, ...     % key press time (KbQueue)
    'ts_response_daq',    NaN, ...
    'ts_blank',           NaN, ...     % blank screen after the trial (flip)
    'ts_trial_end_daq',   NaN, ...     % trial_end marker before the outcome train
    'response',           NaN, ...     % key index (0 = none / timeout)
    'response_key',       '', ...      % key name
    'rt',                 NaN, ...     % s from image onset to the key
    'rt_question',        NaN, ...     % s from words / prompt onset to the key
    'chosen_pos',         NaN, ...     % adjective trials: position of the chosen word
    'chosen_axis_id',     NaN, ...     % adjective trials: axis id of the chosen word
    'chosen_label',       '', ...
    'correct',            NaN, ...     % TaskCodes.CORRECT code
    'voice_onset',        NaN, ...     % naming trials: s from image onset (online estimate)
    'audio_file',         '', ...      % naming trials: wav file (relative to the log folder)
    'audio_capture_start', NaN, ...    % GetSecs time of the first audio sample
    'audio_overflow',     NaN, ...
    'daq_outcome_values', []);         % TaskCodes.TRAIN_OUTCOME values that were sent
end
