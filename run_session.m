% RUN_SESSION  The experiment script for one recording session (rig): set the
% patient and session, then run the task sections in order (Run the whole
% script, or a single section with Ctrl+Enter). Each task waits for ESC to
% start and saves everything with its own <task>_<time> prefix; F10 ends it.
% For testing and debugging use the run_<task>_dummy scripts.
% A session record (settings, outcome of every task, code version) is saved as
% logs/<pid>/<pid>_<sess>/session_<time>.mat after every task.

%% settings
patient_id = 1;
session_nr = 1;
stimset    = 2;                % subject<NNN>_stimset<NN>
here = fileparts(mfilename('fullpath'));
if isempty(here), here = pwd; end     % section run with Ctrl+Enter: run from the ptb folder
stim_root  = fullfile(here, 'stimuli', sprintf('subject%03d', patient_id));

% task 1: chimera (task class TaskCodes.TASKS.chimera = 2)
chim = struct();
chim.stim_dir       = fullfile(stim_root, sprintf('subject%03d_stimset%02d', patient_id, stimset));
chim.practice_dir   = fullfile(stim_root, 'practice');
chim.exp_axes       = 8;        % axes in the set (a1..a8)
chim.exp_concepts   = 4;        % concepts (c1..c4)
chim.exp_levels     = 2;        % generated levels 1..2
chim.exp_insts      = 1;
chim.step_subset    = [1 2];
chim.axis_subset    = [];       % [] = all
chim.concept_subset = [];       % [] = all
chim.min_reps       = 6;        % reps per image (64 images x 6 = 384 trials)
chim.max_reps       = 6;
chim.jitter_min     = 0.2;      % prestim blank: 0.2 s + uniform noise < 0.2 s
chim.jitter_max     = 0.4;
chim.fixation_duration = 0.3;   % prestim fixation cross
chim.display_time   = 1.5;      % stimulus period, then the words
chim.image_size     = [480 480];  % image on screen, px [width height]
chim.eye_calibrate  = true;       % eye tracker calibration (once per session, here)
chim.text_size_words = 160;     % answer words, px (shrunk to fit the screen if needed)
chim.n_options      = 2;        % 2AFC: target + 1 other axis word
chim.adj_keys       = {'LeftArrow', 'RightArrow'};   % option k on key k
chim.blank_duration = 0.1;      % blank after each trial

% task 2: naming (task class TaskCodes.TASKS.naming = 3)
nam = struct();
nam.stim_dir        = chim.stim_dir;
nam.practice_dir    = chim.practice_dir;
nam.exp_axes        = 8;
nam.exp_concepts    = 4;
nam.exp_levels      = 1;
nam.exp_insts       = 1;
nam.step_subset     = 2;          % max level only
nam.min_reps        = 1;        % every image once
nam.max_reps        = 1;
nam.jitter_min      = 0.2;      % prestim blank: 0.2 s + uniform noise < 0.2 s
nam.jitter_max      = 0.4;
nam.fixation_duration = 0.3;
nam.display_time    = 1.5;      % (naming: the image stays until Space; the beep time is tone_delay)
nam.tone_delay      = 0.5;     % answer beep, s after image onset (image stays on)
nam.image_size      = [480 480];  % image on screen, px [width height]
nam.eye_calibrate   = false;      % eye tracker calibrated once, in task 1
nam.use_microphone  = true;

% task 3: mini-screening (dynamic's run_mini_screening; plain daq events, no trial trains)
mini = struct();
mini.stim_dir       = chim.stim_dir;        % the session's concepts
mini.originals_dir  = fullfile(stim_root, 'originals');   % originals, names, exemplars
mini.nm_blocks      = 8;        % original + name once per block -> 8 reps each
mini.n_exemplars    = 11;       % THINGS instances 1..11, once each (spread over the blocks)
mini.jitter_min     = 0.2;      % prestim blank: 0.2 s + uniform noise < 0.2 s
mini.jitter_max     = 0.4;
mini.fixation_duration = 0.3;
mini.blank_duration = 0.1;      % image stays until left (one hand) / right (not)
mini.use_eyetracking = true;
mini.eye_calibrate  = false;      % eye tracker calibrated once, in task 1
mini.image_size     = chim.image_size;   % same image size as chimera / naming

%% setup (no need to edit)
addpath(genpath(fullfile(here, 'functions')));
log_dir = fullfile(here, 'logs', sprintf('%d', patient_id), sprintf('%d_%d', patient_id, session_nr));
if ~isfolder(log_dir), mkdir(log_dir); end
session_record = struct('patient_id', patient_id, 'session_nr', session_nr, ...
    'chimera_settings', chim, 'naming_settings', nam, 'miniscreening_settings', mini, 'started', datestr(now), 'code_version', '', 'results', struct());
[git_status, git_out] = system(sprintf('git -C "%s" rev-parse --short HEAD', here));
if git_status == 0, session_record.code_version = strtrim(git_out); end
record_file = fullfile(log_dir, sprintf('session_%s.mat', datestr(now, 'yyyymmdd_HHMMSS')));

%% task 1: chimera (2AFC, 64 images x 6)
session_record.results.chimera = run_chimera_eye(patient_id, session_nr, chim);
save(record_file, 'session_record', '-v7');

%% task 2: naming (image stays on, spoken answer recorded)
session_record.results.naming = run_naming_eye(patient_id, session_nr, nam);
save(record_file, 'session_record', '-v7');

%% task 3: mini-screening (as in dynamic: one hand? left = yes / right = no)
session_record.results.miniscreening = run_miniscreening_eye(patient_id, session_nr, mini);
save(record_file, 'session_record', '-v7');

%% end of session
session_record.finished = datestr(now);
save(record_file, 'session_record', '-v7');
fprintf('Session record: %s\n', record_file);

