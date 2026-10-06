function run_chimera_eye(patient_id, session_nr, overrides)
% RUN_CHIMERA_EYE  Chimera task (screening-based follow-up), built on the
% skeleton of run_dynamic_eye.m / run_mini_screening.m and the same helpers
% (daqInit, daqOut, fixation_cross_eye, Titta).
%
%   run_chimera_eye(patient_id, session_nr)             rig
%   run_chimera_eye(patient_id, session_nr, overrides)  parameter overrides
%                                                       (run_chimera_dummy)
% All parameters: functions/chimera_params.m. Daq protocol: functions/TaskCodes.m.
%
% Design: 4 concepts x 8 axes x 3 generated steps = 96 images. Every
% presentation is an adjective trial: image for display_time, then 4
% adjectives (the manipulated axis's adjective + 3 others); one in every
% catch_every is a catch without the target. (use_naming = true adds a naming
% trial as presentation 1: image stays on, spoken response recorded.) The
% session runs until every image has min_reps presentations AND max_minutes
% have passed (extra presentations continue up to max_reps); pause screen
% every pause_every_trials trials. F10 ends the session at any wait; all
% data so far is saved. The whole plan is saved before trial 1 and every
% trial is saved right after it ran.

%% exp parameters
if nargin < 3, overrides = struct(); end
base_dir = fileparts(mfilename('fullpath'));
addpath(genpath(fullfile(base_dir, 'functions')));
p = chimera_params(overrides);

%% exp init
check_dynamic_helpers(p.dynamic_fcn_dir);
if p.use_daq
    daq = daqInit;
else
    daq = 0;                                   % daqOut(0, x) only prints "-> x"
end
whichScreen = p.which_screen;
KbName('UnifyKeyNames');
kb_mode(p.kb_mode);
ev = TaskCodes.EVENTS;                         % event codes, see functions/TaskCodes.m

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% stimulus initialization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

stim_dir = p.stim_dir;
if isempty(stim_dir)
    stim_dir = fullfile(base_dir, 'stimuli', sprintf('%d', patient_id), sprintf('%d_%d', patient_id, session_nr));
end
log_dir = prepare_log_dir(fullfile(base_dir, 'logs', sprintf('%d', patient_id), ...
    sprintf('%d_%d', patient_id, session_nr)), p.task_name, p.allow_overwrite);

if isempty(p.rng_seed), rng('shuffle'); else, rng(p.rng_seed); end
rng_state = rng;

disp("Preparing chimera stimuli....");
[plan, practice, stim] = prep_chimera_trials(patient_id, session_nr, p, stim_dir, log_dir);
n_min_trials = numel(stim) * p.min_reps;

% INIT variables for collecting exp data (paradigm-level daq events)
paradigm_times_daq = [];
paradigm_events_daq = {};
stop_reason = 'plan_complete';

session_cfg = struct('patient_id', patient_id, 'session_nr', session_nr, ...
    'task_name', p.task_name, 'task_type', p.task_type, 'params', p, ...
    'stim_dir', stim_dir, 'log_dir', log_dir, 'n_images', numel(stim), ...
    'n_trials_planned', numel(plan), 'n_min_trials', n_min_trials, ...
    'daq_found', daq ~= 0, 'protocol_version', TaskCodes.PROTOCOL_VERSION, ...
    'protocol', TaskCodes.snapshot(), 'rng_state', rng_state, ...
    'created', datestr(now), 'screen', [], 'audio_fs', NaN, ...
    'n_trials_run', 0, 'stop_reason', '', 'minutes_run', NaN);
save(fullfile(log_dir, [p.task_name '_session_cfg.mat']), 'session_cfg', '-v7');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% eyetracker initialization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if p.use_eyetracking
    settings = Titta.getDefaults("Tobii Pro Spark");
    settings.debugMode = false;

    % calibration settings
    calViz = AnimatedCalibrationDisplay;
    settings.cal.drawFunction = @calViz.doDraw;

    EThndl = Titta(settings);
    EThndl.init();
else
    EThndl = [];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% microphone initialization (naming trials)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[pa, audio_fs] = audio_open(p);
session_cfg.audio_fs = audio_fs;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PARADIGM START
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp("Stimuli loaded. Press ESC to begin.");
keypressed = 0;
while keypressed ~= KbName('Escape')
    [~, keyCode] = KbWait;
    keypressed = find(keyCode == 1);
end

try
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% screen initialization
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    Screen('Preference', 'Verbosity', 4);
    Screen('Preference', 'VBLTimestampingMode', 3);
    Screen('Preference', 'ConserveVRAM', 0);

    PsychDefaultSetup(2);
    Screen('Preference', 'SkipSyncTests', p.skip_sync_tests);
    PsychTweak('UseGPUIndex', 0);
    InitializeMatlabOpenGL;

    if p.windowed_mode
        [window, windowRect] = Screen('OpenWindow', whichScreen, 0, p.window_rect);
    else
        [window, windowRect] = Screen('OpenWindow', whichScreen, 0);
    end

    Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
    Screen(window, 'FillRect', [0, 0, 0]);
    white = WhiteIndex(window);

    % everything the trial helpers need
    hw = struct('window', window, 'windowRect', windowRect, 'white', white, ...
        'ifi', Screen('GetFlipInterval', window), ...
        'pd_rect', photodiode_rect(windowRect, p.photodiode_size, p.photodiode_corner), ...
        'daq', daq, 'EThndl', EThndl, 'pa', pa, 'fs', audio_fs, 'log_dir', log_dir);
    session_cfg.screen = struct('windowRect', windowRect, 'ifi', hw.ifi, ...
        'nominal_hz', Screen('NominalFrameRate', window), 'pd_rect', hw.pd_rect);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Tobii calibration
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if p.use_eyetracking
        Screen('TextSize', window, 30);
        DrawFormattedText(window, ['Wir werden den Eye-Tracker schnell kalibrieren.\n' ...
            'Auf dem nächsten Bildschirm richten Sie bitte Ihr Gesicht am Kreis aus. \n' ...
            'Dann schauen Sie bitte auf die sich bewegenden Punkte\n'...
            'und folgen Sie ihnen so genau wie möglich. \n' ...
            'Drücken Sie zum Starten die Leertaste. '], 'center', 'center', white);

        Screen('Flip', window);

        % Press space to move on
        [~, ~, keyCode] = KbCheck;
        while ~keyCode(KbName('Space'))
            [~, ~, keyCode] = KbCheck;
        end

        EThndl.calibrate(window);
        WaitSecs(1);

        EThndl.buffer.start('gaze');
        paradigm_times_daq(end+1) = daqOut(daq, ev.eye);
        paradigm_events_daq{end+1} = "gaze_on";

        msg = sprintf("%i_gaze_on", ev.eye);
        EThndl.sendMessage(msg, GetSecs);

        WaitSecs(1);
    else
        paradigm_times_daq(end+1) = NaN;
        paradigm_events_daq{end+1} = "gaze_on_skipped_no_eyetracking";
    end

    % session marker + train: task, patient, session, protocol version
    paradigm_times_daq(end+1) = send_train(hw, ev.session_start, ...
        TaskCodes.session_train(p.task_type, patient_id, session_nr), 'session');
    paradigm_events_daq{end+1} = "session_start";

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% instruction screen
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    [ts_instructOn_daq, ts_instructOff_daq] = task_instruction_screen_eye(window, white, p.instructions, ...
        daq, ev.start_of_paradigm, ev.response, ...
        EThndl);

    paradigm_times_daq(end+1) = ts_instructOn_daq;
    paradigm_events_daq{end+1} = "instructions_on";

    paradigm_times_daq(end+1) = ts_instructOff_daq;
    paradigm_events_daq{end+1} = "instructions_off";

    %%%%%%%%%%%%%%%%%%%%%
    %% practice (block 0, concepts that are not in the session)
    %%%%%%%%%%%%%%%%%%%%%

    aborted = false;
    blank_onset = Screen('Flip', window);
    if ~isempty(practice)
        paradigm_times_daq(end+1) = send_train(hw, ev.start_of_block, TaskCodes.block_train(0), 'block-0_practice');
        paradigm_events_daq{end+1} = "practice";
        for k = 1:numel(practice)
            [practice(k), blank_onset, aborted] = run_task_trial(practice(k), blank_onset, hw, p, log_dir, @chimera_trial_eye);
            if aborted, break; end
        end
        if ~aborted
            Screen('TextSize', window, p.text_size_prompt);
            DrawFormattedText(window, p.practice_end_text, 'center', 'center', white);
            Screen('Flip', window);
            WaitSecs(1.5);
            blank_onset = Screen('Flip', window);
        end
    end

    %%%%%%%%%%%%%%%%%%%%%
    %% trials (segments between pauses = blocks)
    %%%%%%%%%%%%%%%%%%%%%

    t_start = GetSecs;
    n_run = 0;
    if aborted
        stop_reason = 'abort_practice';
    else
        for trial_idx = 1:numel(plan)
            cfg = plan(trial_idx);

            % stop once the minimum is reached and the time is up
            if trial_idx > n_min_trials && (GetSecs - t_start) / 60 >= p.max_minutes
                stop_reason = 'max_time';
                break
            end

            % new block: pause screen (not before the first), then the block marker
            if trial_idx == 1 || cfg.block_id ~= plan(trial_idx - 1).block_id
                if trial_idx > 1
                    [go_on, blank_onset] = pause_screen(window, white, p, ...
                        sprintf('--- %d trials done (minimum %d) ---', n_run, n_min_trials));
                    if ~go_on
                        stop_reason = 'experimenter_stop';
                        break
                    end
                end
                paradigm_times_daq(end+1) = send_train(hw, ev.start_of_block, ...
                    TaskCodes.block_train(cfg.block_id), sprintf('block-%i', cfg.block_id));
                paradigm_events_daq{end+1} = sprintf("block_%d", cfg.block_id);
            end

            [plan(trial_idx), blank_onset, aborted] = run_task_trial(cfg, blank_onset, hw, p, log_dir, @chimera_trial_eye);
            n_run = trial_idx;
            if aborted
                stop_reason = 'abort';
                break
            end
        end
    end
    minutes_run = (GetSecs - t_start) / 60;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% end of paradigm
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if p.use_eyetracking
        EThndl.buffer.stop('gaze');
        paradigm_times_daq(end+1) = daqOut(daq, ev.eye);
        paradigm_events_daq{end+1} = "gaze_off";

        msg = sprintf("%i_gaze_off", ev.eye);
        EThndl.sendMessage(msg, GetSecs);
    else
        paradigm_times_daq(end+1) = NaN;
        paradigm_events_daq{end+1} = "gaze_off_skipped_no_eyetracking";
    end

catch ME
    % save what exists, release the hardware, then report the error
    disp("ERROR during the session - saving data collected so far....");
    stop_reason = ['error: ' ME.message];
    if ~exist('n_run', 'var'), n_run = 0; end
    if ~exist('minutes_run', 'var'), minutes_run = NaN; end
    try
        save_task_session(log_dir, p, plan, practice, stim, session_cfg, n_run, stop_reason, minutes_run, ...
            paradigm_times_daq, paradigm_events_daq, EThndl);
    catch ME_save
        warning('run_chimera_eye:save', 'saving after the error failed too: %s', ME_save.message);
    end
    shut_down_task(EThndl, pa);
    rethrow(ME);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% save variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('Session ended (%s) after %d trials (minimum %d), %.1f min. Saving variables....\n', ...
    stop_reason, n_run, n_min_trials, minutes_run);
save_task_session(log_dir, p, plan, practice, stim, session_cfg, n_run, stop_reason, minutes_run, ...
    paradigm_times_daq, paradigm_events_daq, EThndl);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% shut down
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

shut_down_task(EThndl, pa);

end
