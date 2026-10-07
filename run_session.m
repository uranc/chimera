% RUN_SESSION  One recording session: set the parameters, then run the task
% sections in order (Run the whole script, or a single section with
% Ctrl+Enter). Each task waits for ESC to start and saves everything with its
% own <task>_<time> prefix; F10 ends the task.
% A session record (settings, outcome of every task, code version) is saved as
% logs/<pid>/<pid>_<sess>/session_<time>.mat after every task.

%% settings
patient_id = 99;
session_nr = 1;
test_mode  = true;     % true: no DAQ / eye tracker, windowed, keyboard polling
                       %       (functions/dummy_overrides.m); false: rig

% stimuli: stimuli/subject<NNN>/subject<NNN>_stimset<NN>/ and .../practice/
% (built with setup/make_stimset.py); override here only if needed, e.g.
% overrides.stim_dir = 'D:\stimuli\subject001\subject001_stimset01';
overrides = struct();

%% setup (no need to edit)
here = fileparts(mfilename('fullpath'));
addpath(genpath(fullfile(here, 'functions')));
log_dir = fullfile(here, 'logs', sprintf('%d', patient_id), sprintf('%d_%d', patient_id, session_nr));
if ~isfolder(log_dir), mkdir(log_dir); end
session_record = struct('patient_id', patient_id, 'session_nr', session_nr, 'test_mode', test_mode, ...
    'overrides', overrides, 'started', datestr(now), 'code_version', '', 'results', struct());
[git_status, git_out] = system(sprintf('git -C "%s" rev-parse --short HEAD', here));
if git_status == 0, session_record.code_version = strtrim(git_out); end
record_file = fullfile(log_dir, sprintf('session_%s.mat', datestr(now, 'yyyymmdd_HHMMSS')));

%% task 1: chimera (adjective 4AFC, 96 images x 6)
o = overrides;
if test_mode, o = apply_test_overrides(dummy_overrides('chimera'), o); end
session_record.results.chimera = run_chimera_eye(patient_id, session_nr, o);
save(record_file, 'session_record', '-v7');

%% task 2: mini-screening (not implemented yet)

%% task 3: naming (image stays on, spoken answer recorded)
o = overrides;
if test_mode, o = apply_test_overrides(dummy_overrides('naming'), o); end
session_record.results.naming = run_naming_eye(patient_id, session_nr, o);
save(record_file, 'session_record', '-v7');

%% end of session
session_record.finished = datestr(now);
save(record_file, 'session_record', '-v7');
fprintf('Session record: %s\n', record_file);


function o = apply_test_overrides(o, extra)
% the test settings, with the session's own overrides on top
fn = fieldnames(extra);
for k = 1:numel(fn), o.(fn{k}) = extra.(fn{k}); end
end
