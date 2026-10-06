function out = run_chimera_dummy(patient_id, session_nr)
% RUN_CHIMERA_DUMMY  Test run of the chimera task: exactly the rig code
% (run_chimera_eye) with the test overrides from functions/dummy_overrides.m:
% no DAQ (bytes are printed), no eye tracker, windowed, keyboard polling,
% test stimuli (stimuli/stimset_8ax, 4 concepts). Edit dummy_overrides.m to
% change the test settings for all dummies and run_session(..., 'dummy').
if nargin < 1, patient_id = 99; end
if nargin < 2, session_nr = 1; end
here = fileparts(mfilename('fullpath'));
addpath(genpath(fullfile(here, 'functions')));
out = run_chimera_eye(patient_id, session_nr, dummy_overrides('chimera'));
end
