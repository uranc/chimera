% RUN_NAMING_DUMMY  Test run of the naming task: exactly the rig code
% (run_naming_eye) with the test settings below. Every o.<name> overrides the
% default in functions/naming_params.m (unknown names are an error).

%% settings
patient_id = 99;
session_nr = 1;
stimset    = 2;                % subject<NNN>_stimset<NN>

here = fileparts(mfilename('fullpath'));
if isempty(here), here = pwd; end     % section run with Ctrl+Enter: run from the ptb folder
addpath(genpath(fullfile(here, 'functions')));

o = struct();
% hardware off
o.use_daq          = false;         % daqOut only prints the bytes
o.use_eyetracking  = false;         % no Titta, dummy Tobii file
o.windowed_mode    = true;
o.window_rect      = [0 0 640 480]; % small window (headless test display); bigger is fine locally
o.skip_sync_tests  = 1;
o.kb_mode          = 'poll';        % KbCheck: also works over remote desktop
% the dynamic paradigm's functions folder (daqOut, fixation_cross_eye):
% the first existing folder is used; add yours if it lives elsewhere
o.dynamic_fcn_dir  = {fullfile(here, '..', '..', 'dynamic', 'code', 'experiment', 'functions'), ...
                      fullfile(here, '..', 'dynamic', 'code', 'experiment', 'functions'), ...
                      '/home/uranc/Documents/dynamic/code/experiment/functions'};
% display
o.text_size_words  = 20;
o.text_size_prompt = 16;

% stimuli and task (same names as in run_session)
stim_root        = fullfile(here, 'stimuli', sprintf('subject%03d', patient_id));
o.stim_dir       = fullfile(stim_root, sprintf('subject%03d_stimset%02d', patient_id, stimset));
o.practice_dir   = fullfile(stim_root, 'practice');
o.exp_axes       = 8;
o.exp_concepts   = 4;
o.exp_levels     = 1;
o.exp_insts      = 1;
o.step_subset    = 2;          % max level only
o.min_reps       = 1;        % every image once
o.max_reps       = 1;
o.jitter_min     = 0.2;      % prestim blank: 0.2 s + uniform noise < 0.2 s
o.jitter_max     = 0.4;
o.fixation_duration = 0.3;
o.display_time   = 1.5;      % (naming: the image stays until Space; the beep time is tone_delay)
o.tone_delay     = 0.5;      % answer beep, s after image onset (image stays on)
o.use_microphone = true;     % default mic; asks to go on without if none opens

%% run
result_naming = run_naming_eye(patient_id, session_nr, o);
