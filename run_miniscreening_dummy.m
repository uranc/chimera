% RUN_MINISCREENING_DUMMY  Test run of the mini-screening: exactly the rig code
% (run_miniscreening_eye) with the test settings below. Every o.<name> overrides the
% default in functions/miniscreening_params.m (unknown names are an error).

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
o.text_size_words  = 20;          % smaller text for the small window
o.text_size_prompt = 16;

% stimuli and task (same names as in run_session)
stim_root        = fullfile(here, 'stimuli', sprintf('subject%03d', patient_id));
o.stim_dir       = fullfile(stim_root, sprintf('subject%03d_stimset%02d', patient_id, stimset));
o.originals_dir  = fullfile(stim_root, 'originals');   % original + exemplar photos
o.exp_axes       = 8;        % the session stimset: its concepts and axes (words)
o.exp_concepts   = 4;
o.exp_levels     = 2;
o.exp_insts      = 1;
o.step_subset    = [1 2];
o.reps_original  = 8;        % original x8
o.reps_name      = 8;        % written name x8
o.n_exemplars    = 11;       % THINGS instances 1..11, once each (8+ trials per condition)
o.reps_exemplar  = 1;
o.jitter_min     = 0.2;      % prestim blank: 0.2 s + uniform noise < 0.2 s
o.jitter_max     = 0.4;
o.fixation_duration = 0.3;   % prestim fixation cross
o.response_timeout = Inf;    % image stays until left (one hand) / right (not), as in dynamic
o.blank_duration = 0.1;      % blank after each trial

%% run
result_miniscreening = run_miniscreening_eye(patient_id, session_nr, o);
