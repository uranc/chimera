% RUN_CHIMERA_DUMMY  Test run of the chimera task: exactly the rig code
% (run_chimera_eye) with the test settings below. Every o.<name> overrides the
% default in functions/chimera_params.m (unknown names are an error).

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
o.text_size_words  = 80;          % answer words, px (shrunk to fit the window if needed)
o.image_size       = [480 480];   % image on screen, px [width height]
o.text_size_prompt = 16;

% stimuli and task (same names as in run_session)
stim_root        = fullfile(here, 'stimuli', sprintf('subject%03d', patient_id));
o.stim_dir       = fullfile(stim_root, sprintf('subject%03d_stimset%02d', patient_id, stimset));
o.practice_dir   = fullfile(stim_root, 'practice');
o.exp_axes       = 8;        % axes in the set (a1..a8)
o.exp_concepts   = 4;        % concepts (c1..c4)
o.exp_levels     = 2;        % generated levels 1..2
o.exp_insts      = 1;
o.step_subset    = [1 2];
o.axis_subset    = [];       % [] = all
o.concept_subset = [];       % [] = all
o.min_reps       = 6;        % reps per image (64 images x 6 = 384 trials)
o.max_reps       = 6;
o.jitter_min     = 0.2;      % prestim blank: 0.2 s + uniform noise < 0.2 s
o.jitter_max     = 0.4;
o.fixation_duration = 0.3;   % prestim fixation cross
o.display_time   = 1.5;      % stimulus period, then the words
o.n_options      = 2;        % 2AFC: target + 1 other axis word
o.adj_keys       = {'LeftArrow', 'RightArrow'};   % option k on key k
o.blank_duration = 0.1;      % blank after each trial

%% run
result_chimera = run_chimera_eye(patient_id, session_nr, o);
