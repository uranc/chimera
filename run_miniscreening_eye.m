function out = run_miniscreening_eye(patient_id, session_nr, o)
% RUN_MINISCREENING_EYE  The dynamic repo's run_mini_screening.m, unchanged
% except for the images and reps, the daq trains of the other tasks (session,
% block, trial parameters, outcome; TaskCodes.m) and settings passed in o:
% per concept of the session stimset, the original photo and the written
% name in every block (nm_blocks times), plus n_exemplars further photos
% once each, spread over the blocks (miniscreening_prep_trial_strx).
% Images: stimuli/subject<NNN>/originals (setup/make_stimset.py).
%
%   run_miniscreening_eye(patient_id, session_nr)       rig
%   run_miniscreening_eye(patient_id, session_nr, o)    o.<name> overrides the
%       settings at the top (nm_blocks, n_exemplars, stim_dir, originals_dir,
%       use_eyetracking, use_daq, windowed_mode, window_rect, skip_sync_tests,
%       jitter_min/max, fixation_duration, blank_duration, dynamic_fcn_dir)
%
% each image is shown until the patient responds with a L/R key press
%
% press F10 at any point during a trial's response window to abort the
% screening early - all data collected up to that point is still saved

nm_blocks = 8;                  % original + name shown once per block -> 8 reps
n_exemplars = 11;               % further photos per concept (instances 1..11), once each

jitter_min = 0.2;
jitter_max = 0.4;
fixation_duration = 0.3;
blank_duration = 0.1;

use_eyetracking = false;
use_daq = true;
skip_sync_tests = 0;
window_rect = [0, 0, 800, 600];

base_dir = fileparts(mfilename('fullpath'));
stim_dir = fullfile(base_dir, 'stimuli', sprintf('subject%03d', patient_id), sprintf('subject%03d_stimset%02d', patient_id, session_nr));
originals_dir = fullfile(base_dir, 'stimuli', sprintf('subject%03d', patient_id), 'originals');
dynamic_fcn_dir = {fullfile(base_dir, '..', '..', 'dynamic', 'code', 'experiment', 'functions'), ...
    fullfile(base_dir, '..', 'dynamic', 'code', 'experiment', 'functions')};

% debugging params
windowed_mode = false;

% settings passed in (run_session / run_miniscreening_dummy)
if nargin < 3, o = struct(); end
fn = fieldnames(o);
for k = 1:numel(fn)
    eval(sprintf('%s = o.%s;', fn{k}, fn{k}));
end

addpath(genpath(fullfile(base_dir, 'functions')));
check_dynamic_helpers(dynamic_fcn_dir);        % daqInit, daqOut, fixation_cross_eye, instruction screen

if use_daq
    daq=daqInit;
else
    daq = 0;                                   % daqOut(0, x) only prints
end
whichScreen = 0;
KbName('UnifyKeyNames');

% each time a daq event is sent, a message is sent to the Tobii.
daq_start_of_paradigm = 1;      % 00000001  -  instruction screen
daq_start_of_block = 2;         % 00000010  -  start of block (e.g. set of trials)
daq_fix_cross = 4;              % 00000100  -  fixation cross onset

daq_img_on = 22;                % 00010110  -  onset of an image
daq_img_off = 65;               % 01000001  -  offset of an image

daq_eye = 32;                   % 00100000  -  Tobii initialized/deinitialized
daq_response = 64;              % 01000000  -  participant key press
daq_question = 128;             % 10000000  -  participant prompted to respond

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% stimulus initialization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

log_dir = fullfile(base_dir, 'logs', sprintf('%d', patient_id), sprintf('%d_%d', patient_id, session_nr));
file_prefix = sprintf('mini_screening_%s', datestr(now, 'yyyymmdd_HHMMSS'));   % no run overwrites another

% randomization and trial structure preparation
disp("Preparing mini-screening stimuli....");

[jitter_times, ...
    img_names, img_randomization, Images, ...
    Images_mini_screening_filenames, ...
    log_dir, trial_values] = miniscreening_prep_trial_strx(patient_id, session_nr,...
    nm_blocks, jitter_min, jitter_max, stim_dir, originals_dir, n_exemplars, log_dir, file_prefix);

% INIT empty variables for collecting exp data
% paradigm-level daq events / triggers
paradigm_times_daq = NaN(1, 3);       % + session, blocks, gaze_off appended


% within-loop events
fix_times_ts = NaN(size(Images));
fix_times_daq = NaN(size(Images));

miniscr_imgOn_ts  = NaN(size(Images));
miniscr_imgOn_daq = NaN(size(Images));

miniscr_imgOff_ts  = NaN(size(Images));
miniscr_imgOff_daq = NaN(size(Images));

pat_response_values = NaN(size(Images));
pat_response_ts = NaN(size(Images));
pat_response_daq = NaN(size(Images));

% tracks whether the session was aborted early via F10, saved alongside
% the other paradigm-level metadata so it's clear in the data later
abort_early = false;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% eyetracker initialization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if use_eyetracking
    settings = Titta.getDefaults("Tobii Pro Spark");
    settings.debugMode = false;

    % calibration settings
    calViz = AnimatedCalibrationDisplay;
    settings.cal.drawFunction = @calViz.doDraw;

    EThndl = Titta(settings);
    EThndl.init();
else
    % dummy placeholder so EThndl can still be passed to helper
    % functions without error (those functions internally
    % check use_eyetracking / isempty(EThndl) before calling any
    % Titta/Tobii methods on it)
    EThndl = [];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%a%%%%%%%%%
%% PARADIGM START
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp("Stimuli loaded. Press ESC to begin.");
keypressed = 0;
while keypressed ~= KbName('Escape')
    [secs keyCode]=KbWait;
    keypressed = find(keyCode == 1);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% screen initialization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Screen('Preference', 'Verbosity', 4);
Screen('Preference','VBLTimestampingMode', 3);
Screen('Preference','ConserveVRAM', 0);

PsychDefaultSetup(2);
Screen('Preference','SkipSyncTests',skip_sync_tests);
PsychTweak('UseGPUIndex',0);
InitializeMatlabOpenGL;

if windowed_mode
    [window, windowRect] = Screen(whichScreen, 'OpenWindow', [], window_rect); 	% Limit screen to just a window in the top left screen corner.
else
    [window, windowRect] = Screen('OpenWindow', whichScreen, 0); 			                % Creates a black window the size of the screen. Pointer: window, coordinates: windowRect
end

hz = Screen('NominalFrameRate', window);
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
[screenXpixels, screenYpixels] = Screen('WindowSize', window);
Screen(window, 'FillRect', [0, 0, 0]);
white = WhiteIndex(window);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Tobii calibration
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if use_eyetracking
    Screen('TextSize', window, 30);
    DrawFormattedText(window, ['Wir werden den Eye-Tracker schnell kalibrieren.\n' ...
        'Auf dem nächsten Bildschirm richten Sie bitte Ihr Gesicht am Kreis aus. \n' ...
        'Dann schauen Sie bitte auf die sich bewegenden Punkte\n'...
        'und folgen Sie ihnen so genau wie möglich. \n' ...
        'Drücken Sie zum Starten die Leertaste. '], 'center', 'center', white);

    Screen('Flip', window);

    % Press space to move on to the screening
    [touch, secs, keyCode] = KbCheck;
    while ~keyCode(KbName('Space'))
        [touch, secs, keyCode] = KbCheck;
    end

    EThndl.calibrate(window);
    WaitSecs(1);

    EThndl.buffer.start('gaze');
    paradigm_times_daq(1) = daqOut(daq, daq_eye);
    paradigm_events_daq{1} = sprintf("gaze_on");

    msg = sprintf("%i_gaze_on", daq_eye);
    EThndl.sendMessage(msg, GetSecs);

    WaitSecs(1);
else
    % no eye tracker: skip calibration screen, gaze buffer start, and
    % associated WaitSecs pauses entirely (these are eyetracking-only
    % waits and do not affect stimulus/trial timing below)
    paradigm_times_daq(1) = NaN;
    paradigm_events_daq{1} = sprintf("gaze_on_skipped_no_eyetracking");
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% instruction screen
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[ts_instructOn_daq, ts_instructOff_daq] = mini_screening_instruction_screen_eye(window, white, ...
    daq, daq_start_of_paradigm, daq_response, ...
    EThndl);

paradigm_times_daq(2) = ts_instructOn_daq;
paradigm_events_daq{2} = sprintf("instructions_on");

paradigm_times_daq(3) = ts_instructOff_daq;
paradigm_events_daq{3} = sprintf("instructions_off");

% session marker + train (task 4, patient, session, protocol version), as in
% the other tasks, so the neural data can be read without the logs
hw = struct('daq', daq, 'EThndl', EThndl);
ev = TaskCodes.EVENTS;
paradigm_times_daq(end+1) = send_train(hw, ev.session_start, ...
    TaskCodes.session_train(TaskCodes.task('miniscreening'), patient_id, session_nr), 'session');
paradigm_events_daq{end+1} = "session_start";
outcome_values = cell(size(Images));

%%%%%%%%%%%%%%%%%%%%%
%% start of blocks
%%%%%%%%%%%%%%%%%%%%%

for block_id = 1:nm_blocks

    paradigm_times_daq(end+1) = send_train(hw, daq_start_of_block, TaskCodes.block_train(block_id), ...
        sprintf('block-%d', block_id));                        % block marker + block number
    paradigm_events_daq{end+1} = sprintf("block_%d", block_id);

    block_order = Images(block_id,:);

    for trial_id = 1:length(block_order)
        if img_randomization(block_id, trial_id) == 0, continue; end   % blocks differ in length by 1
        %% trial train (all trial parameters), sent inside the jitter
        t_train = GetSecs;
        send_train(hw, ev.trial_start, trial_values{block_id, trial_id}, ...
            sprintf('trial_block-%i_trial-%i', block_id, trial_id));

        %% fixation cross
        jitter_time = max(0, jitter_times(block_id, trial_id) - (GetSecs - t_train));

        [ts_fix, ts_fix_daq] = fixation_cross_eye(jitter_time, fixation_duration, ...
            block_id, trial_id, ...
            window, windowRect, ...
            daq, daq_fix_cross, ...
            EThndl);


        fix_times_ts(block_id, trial_id) = ts_fix;
        fix_times_daq(block_id, trial_id) = ts_fix_daq;

        %% run image

        % grab image
        img_to_show = block_order{trial_id};

        % grab image details to send to eyetracker
        img_to_show_filename = Images_mini_screening_filenames{block_id, trial_id};
        [~, name, ext] = fileparts(img_to_show_filename);
        img_to_show_filename = [name ext];

        % show image

        flip_time = GetSecs;
        texture = Screen('MakeTexture', window, img_to_show);
        Screen('DrawTexture', window, texture)
        miniscr_imgOn_ts(block_id, trial_id) = Screen('Flip', window, flip_time);

        % timestamp outputs
        miniscr_imgOn_daq(block_id, trial_id) = daqOut(daq, daq_img_on);
        if ~isempty(EThndl)
            msg = sprintf("%i_%s", daq_img_on, img_to_show_filename);
            EThndl.sendMessage(msg,miniscr_imgOn_ts(block_id, trial_id));
        end

        % wait for left arrow, right arrow, or F10 (abort) - image stays
        % on screen until one of these is pressed
        arrowKeys = [KbName('LeftArrow'), KbName('RightArrow'), KbName('F10')];
        keysOfInterest = zeros(1, 256);
        keysOfInterest(arrowKeys) = 1;
        KbQueueCreate([], keysOfInterest);
        KbQueueStart;


        pressed = false;
        while ~pressed
            [pressed, firstPress] = KbQueueCheck;
            if ~pressed
                WaitSecs(0.001);   % small yield so this doesn't spin the CPU at 100%
            end
        end

        KbQueueStop;
        KbQueueRelease;


        resp_keyCode = firstPress > 0;

        % F10 -> abort the screening. Close the texture we just made,
        % log the abort, and break out of both loops (block + trial)
        % without recording a response or running the black-screen
        % offset for this trial. Everything collected in previous
        % trials/blocks is left untouched and gets saved below as-is.
        if resp_keyCode(KbName('F10'))
            abort_early = true;
            disp("F10 pressed - aborting mini-screening early. Saving data collected so far....");
            Screen('Close', texture);
            break
        end

        pat_response_ts(block_id, trial_id) = min(firstPress(resp_keyCode));

        % code the response: 1 = left, 2 = right
        if resp_keyCode(KbName('LeftArrow'))
            pat_response_values(block_id, trial_id) = 1;
        else
            pat_response_values(block_id, trial_id) = 2;
        end

        pat_response_daq(block_id, trial_id) = daqOut(daq, daq_response);

        Screen('Close', texture);   % release the texture now that it's no longer needed

        % switch to a black screen immediately on keypress
        Screen('FillRect', window, [0 0 0]);
        miniscr_imgOff_ts(block_id, trial_id) = Screen('Flip', window);

        % timestamp outputs
        miniscr_imgOff_daq(block_id, trial_id) = daqOut(daq, daq_img_off);
        if ~isempty(EThndl)
            msg = sprintf("%i_%s", daq_img_off, img_to_show_filename);
            EThndl.sendMessage(msg, miniscr_imgOff_ts(block_id, trial_id));
        end

        % outcome train: response (1 left, 2 right), rt from image onset
        outcome_values{block_id, trial_id} = TaskCodes.outcome_train(pat_response_values(block_id, trial_id), ...
            0, TaskCodes.CORRECT.not_applicable, ...
            pat_response_ts(block_id, trial_id) - miniscr_imgOn_ts(block_id, trial_id), NaN);
        send_train(hw, ev.trial_end, outcome_values{block_id, trial_id}, ...
            sprintf('outcome_block-%i_trial-%i', block_id, trial_id));

        % hold the black screen for exactly 0.5s, anchored to the actual flip
        % time rather than "now"
        WaitSecs('UntilTime', miniscr_imgOff_ts(block_id, trial_id) + blank_duration);


    end

    if abort_early
        break
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end

if use_eyetracking
    EThndl.buffer.stop('gaze');
    paradigm_times_daq(end+1) = daqOut(daq, daq_eye);
    paradigm_events_daq{end+1} = sprintf("gaze_off");
 
    msg = sprintf("%i_gaze_off", daq_eye);
    EThndl.sendMessage(msg, GetSecs);
else
    paradigm_times_daq(end+1) = NaN;
    paradigm_events_daq{end+1} = sprintf("gaze_off_skipped_no_eyetracking");
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% save variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if abort_early
    disp("Session was aborted early (F10). Saving variables in their current state....");
else
    disp("Saving variables....");
end
 
%% eyetracking info
if use_eyetracking
    dat = EThndl.collectSessionData();
    save(EThndl.getFileName(fullfile(log_dir, [file_prefix '_tobii_data']), true),'-struct','dat');
else
    % dummy placeholder in place of the real Tobii session data so
    % downstream scripts that expect a tobii_data file still find one
    dat = struct(...
        'eyetracking_used', false, ...
        'note', 'Dummy file - eyetracking was disabled for this session (use_eyetracking = false)', ...
        'patient_id', patient_id, ...
        'session_nr', session_nr, ...
        'timestamp', datestr(now));
    save(fullfile(log_dir, [file_prefix '_tobii_data_dummy.mat']), '-struct', 'dat', '-v6');
end

%% image presentation variables
save(fullfile(log_dir, [file_prefix '_imgOnOff.mat']), "miniscr_imgOn_ts", "miniscr_imgOn_daq", "miniscr_imgOff_ts", "miniscr_imgOff_daq", '-v6');

%% general paradigm variables
save(fullfile(log_dir, [file_prefix '_behavioral_responses.mat']), "pat_response_values", "pat_response_ts", "pat_response_daq", "outcome_values", '-v6');
save(fullfile(log_dir, [file_prefix '_paradigm_events.mat']), "paradigm_events_daq", "paradigm_times_daq", "abort_early", '-v6');
save(fullfile(log_dir, [file_prefix '_fixation_events.mat']), "fix_times_ts", "fix_times_daq", "-v6");

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% shut down
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if use_eyetracking
    EThndl.deInit();
end

Screen('CloseAll');

out = struct('task', 'mini_screening', 'file_prefix', file_prefix, 'log_dir', log_dir, ...
    'abort_early', abort_early, 'n_trials_run', sum(~isnan(miniscr_imgOn_ts(:))), ...
    'img_names', {{img_names.name}});

end