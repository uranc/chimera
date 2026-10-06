function run_session(patient_id, session_nr, mode)
% RUN_SESSION  The whole session: runs the tasks one after the other with the
% right parameters and keeps one record of what ran.
%
%   run_session(patient_id, session_nr)            rig
%   run_session(patient_id, session_nr, 'dummy')   test run (dummy_overrides:
%                                                  no DAQ / eye tracker, windowed,
%                                                  example stimuli)
%
% Each task is its own run_<task>_eye (same as running it alone): it waits
% for ESC to start, saves everything with its own <task>_<time> prefix, and
% F10 ends that task (the pipeline then asks whether to go on).
% Session record: logs/<pid>/<pid>_<sess>/session_<time>.mat with the task
% list, the overrides used, each task's outcome (file prefix, stop reason,
% trials, minutes, all parameters) and the git commit of the code.
%
% Edit TASKS / SESSION_OVERRIDES below for the session plan.

if nargin < 3 || isempty(mode), mode = 'rig'; end
here = fileparts(mfilename('fullpath'));
addpath(genpath(fullfile(here, 'functions')));

%% session plan
% order of the tasks (the mini-screening slot goes between chimera and naming
% once it exists)
TASKS = {'chimera', 'naming'};
% overrides applied to every task in rig mode (e.g. stim_dir, concept_subset);
% per-task values go into TASK_OVERRIDES.(task)
SESSION_OVERRIDES = struct();
TASK_OVERRIDES = struct('chimera', struct(), 'naming', struct());

%% record
log_dir = fullfile(here, 'logs', sprintf('%d', patient_id), sprintf('%d_%d', patient_id, session_nr));
if ~isfolder(log_dir), mkdir(log_dir); end
stamp = datestr(now, 'yyyymmdd_HHMMSS');
rec = struct('patient_id', patient_id, 'session_nr', session_nr, 'mode', mode, ...
    'tasks', {TASKS}, 'started', datestr(now), 'code_version', code_version(here), ...
    'results', {cell(1, numel(TASKS))}, 'overrides', {cell(1, numel(TASKS))}, 'finished', '');
rec_file = fullfile(log_dir, sprintf('session_%s.mat', stamp));

for k = 1:numel(TASKS)
    task = TASKS{k};
    o = SESSION_OVERRIDES;
    if strcmp(mode, 'dummy'), o = merge(dummy_overrides(task), o); end
    if isfield(TASK_OVERRIDES, task), o = merge(o, TASK_OVERRIDES.(task)); end
    rec.overrides{k} = o;
    fprintf('\n=============== TASK %d/%d: %s (%s) ===============\n', k, numel(TASKS), task, mode);
    try
        rec.results{k} = feval(['run_' task '_eye'], patient_id, session_nr, o);
    catch ME
        rec.results{k} = struct('task', task, 'error', getReport(ME, 'basic'));
        save(rec_file, 'rec', '-v7');
        fprintf(2, 'Task %s stopped with an error:\n%s\n', task, getReport(ME, 'basic'));
        if ~ask_continue(), break; end
        continue
    end
    save(rec_file, 'rec', '-v7');                 % record after every task
    r = rec.results{k};
    fprintf('Task %s ended (%s), %d trials, %.1f min, files %s_*\n', task, r.stop_reason, ...
        r.n_trials_run, r.minutes_run, r.file_prefix);
    if k < numel(TASKS) && ~strcmp(r.stop_reason, 'plan_complete') && ~ask_continue()
        break
    end
end
rec.finished = datestr(now);
save(rec_file, 'rec', '-v7');
fprintf('\nSession record: %s\n', rec_file);
end


function o = merge(o, extra)
fn = fieldnames(extra);
for k = 1:numel(fn), o.(fn{k}) = extra.(fn{k}); end
end

function go = ask_continue()
a = input('Continue with the next task? [y/n] ', 's');
go = ~isempty(a) && lower(a(1)) == 'y';
end

function v = code_version(here)
% git commit of the task code (empty if git is not available)
v = '';
try
    [st, out] = system(sprintf('git -C "%s" rev-parse --short HEAD', here));
    if st == 0, v = strtrim(out); end
catch
end
end
