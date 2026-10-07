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
% stimuli: stimuli/subject<NNN>/subject<NNN>_stimset<NN>/ and .../practice/
% (built with setup/make_stimset.py); override here only if needed, e.g.
% overrides.stim_dir = 'D:\stimuli\subject001\subject001_stimset01';
overrides = struct();

here = fileparts(mfilename('fullpath'));
if isempty(here), here = pwd; end     % section run with Ctrl+Enter: run from the ptb folder

%% setup (no need to edit)
addpath(genpath(fullfile(here, 'functions')));
log_dir = fullfile(here, 'logs', sprintf('%d', patient_id), sprintf('%d_%d', patient_id, session_nr));
if ~isfolder(log_dir), mkdir(log_dir); end
session_record = struct('patient_id', patient_id, 'session_nr', session_nr, ...
    'overrides', overrides, 'started', datestr(now), 'code_version', '', 'results', struct());
[git_status, git_out] = system(sprintf('git -C "%s" rev-parse --short HEAD', here));
if git_status == 0, session_record.code_version = strtrim(git_out); end
record_file = fullfile(log_dir, sprintf('session_%s.mat', datestr(now, 'yyyymmdd_HHMMSS')));

%% task 1: chimera (adjective 4AFC, 96 images x 6)
session_record.results.chimera = run_chimera_eye(patient_id, session_nr, overrides);
save(record_file, 'session_record', '-v7');

%% task 2: mini-screening (not implemented yet)

%% task 3: naming (image stays on, spoken answer recorded)
session_record.results.naming = run_naming_eye(patient_id, session_nr, overrides);
save(record_file, 'session_record', '-v7');

%% end of session
session_record.finished = datestr(now);
save(record_file, 'session_record', '-v7');
fprintf('Session record: %s\n', record_file);

