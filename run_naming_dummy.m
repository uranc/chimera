% RUN_NAMING_DUMMY  Test run of the naming task: exactly the rig code
% (run_naming_eye) with the test settings below. Every o.<name> overrides the
% default in functions/naming_params.m (unknown names are an error).

%% settings
patient_id = 99;
session_nr = 1;

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
% display and stimuli (stimuli/subject<NNN>/subject<NNN>_stimset<NN> is read
% by default)
o.text_size_words  = 20;
o.text_size_prompt = 16;
o.practice_dir     = fullfile(here, 'stimuli', sprintf('subject%03d', patient_id), 'practice');
o.use_microphone   = true;          % default mic; asks to go on without if none opens

%% run
result_naming = run_naming_eye(patient_id, session_nr, o);
