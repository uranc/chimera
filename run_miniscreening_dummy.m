% RUN_MINISCREENING_DUMMY  Test run of the mini-screening: exactly the rig code
% (run_miniscreening_eye, the dynamic repo's run_mini_screening with this
% task's images and reps) with the test settings below. Every o.<name>
% overrides the setting at the top of run_miniscreening_eye.

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
o.window_rect      = [0 0 640 480];
o.skip_sync_tests  = 1;
o.kb_mode_name     = 'poll';        % KbCheck: also works over remote desktop
o.image_size       = [480 480];   % image on screen, px [width height]
% the dynamic paradigm's functions folder (daqOut, fixation_cross_eye,
% mini_screening_instruction_screen_eye): the first existing folder is used
o.dynamic_fcn_dir  = {fullfile(here, '..', '..', 'dynamic', 'code', 'experiment', 'functions'), ...
                      fullfile(here, '..', 'dynamic', 'code', 'experiment', 'functions'), ...
                      '/home/uranc/Documents/dynamic/code/experiment/functions'};

% stimuli and task (same names as in run_session)
stim_root          = fullfile(here, 'stimuli', sprintf('subject%03d', patient_id));
o.stim_dir         = fullfile(stim_root, sprintf('subject%03d_stimset%02d', patient_id, stimset));
o.originals_dir    = fullfile(stim_root, 'originals');   % originals, names, exemplars
o.nm_blocks        = 8;        % original + name once per block -> 8 reps each
o.n_exemplars      = 11;       % THINGS instances 1..11, once each (spread over the blocks)
o.jitter_min       = 0.2;      % prestim blank: 0.2 s + uniform noise < 0.2 s
o.jitter_max       = 0.4;
o.fixation_duration = 0.3;
o.blank_duration   = 0.1;      % image stays until left (one hand) / right (not)

%% run
result_miniscreening = run_miniscreening_eye(patient_id, session_nr, o);
