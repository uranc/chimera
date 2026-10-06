function run_chimera_dummy(patient_id, session_nr)
% RUN_CHIMERA_DUMMY  Local debug run of the chimera task. Runs exactly the
% rig code (run_chimera_eye) with these overrides:
%   - no DAQ          daqOut only prints the bytes ("-> 22")
%   - no eye tracker  no Titta calls, dummy Tobii file
%   - windowed screen, sync tests skipped
%   - test stimuli    stimuli/stimset120 (4 concepts x 4 axes x 3 steps)
% The keyboard works as on the rig (local keyboard).
% Change any value below to test other settings; names are checked against
% functions/chimera_params.m.

if nargin < 1, patient_id = 99; end
if nargin < 2, session_nr = 1; end

here = fileparts(mfilename('fullpath'));

o = struct();
% hardware
o.use_daq         = false;
o.use_eyetracking = false;
o.windowed_mode   = true;
o.window_rect     = [0 0 640 480];     % fits the headless X server used for remote tests
o.text_size_words  = 20;
o.text_size_prompt = 16;
o.skip_sync_tests = 1;
o.allow_overwrite = true;
o.kb_mode         = 'poll';     % KbCheck: works with keys sent over VNC
% the dynamic paradigm's functions folder: first existing candidate is used
% (add your Windows path here if it lives elsewhere)
o.dynamic_fcn_dir = {fullfile(here, '..', '..', 'dynamic', 'code', 'experiment', 'functions'), ...
                     fullfile(here, '..', 'dynamic', 'code', 'experiment', 'functions'), ...
                     '/home/uranc/Documents/dynamic/code/experiment/functions'};
% test stimuli: stimset120 has 4 axes, so catch trials (target + 4 others) are off
o.stim_dir       = fullfile(here, 'stimuli', 'stimset120');
o.concept_subset = [1 4 5 8];          % lipstick, hamburger, onion, banana
o.alpha_subset   = [1.1 3.3 5.5];      % 3 generated steps, no original
o.exp_axes       = 4;
o.catch_every    = 0;
o.pause_every_trials = 48;             % one pause per round of the 48 test images

run_chimera_eye(patient_id, session_nr, o);
end
