function out = run_naming_dummy(patient_id, session_nr)
% RUN_NAMING_DUMMY  Test run of the naming task: exactly the rig code
% (run_naming_eye) with the test settings below. Every value here overrides
% the default in functions/naming_params.m (unknown names are an error).
%   run_naming_dummy                 patient 99, session 1
%   run_naming_dummy(pid, sess)
%   o = run_naming_dummy('overrides')   only return the settings (run_session test mode)

here = fileparts(mfilename('fullpath'));
addpath(genpath(fullfile(here, 'functions')));

%% test settings
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
% display and stimuli (stimuli/subject099/subject099_stimset01 is the default
% folder for patient 99, session 1)
o.text_size_words  = 20;
o.text_size_prompt = 16;
o.practice_dir     = fullfile(here, 'stimuli', 'subject099', 'practice');
o.use_microphone   = true;          % default mic; asks to go on without if none opens

%% run
if nargin >= 1 && ischar(patient_id) && strcmp(patient_id, 'overrides')
    out = o;
    return
end
if nargin < 1, patient_id = 99; end
if nargin < 2, session_nr = 1; end
out = run_naming_eye(patient_id, session_nr, o);
end
