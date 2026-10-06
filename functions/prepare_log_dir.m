function log_dir = prepare_log_dir(log_dir)
% PREPARE_LOG_DIR  Create the session log folder (logs/<pid>/<pid>_<sess>,
% as prep_trial_strx). Files of different runs never collide: every file
% name starts with p.file_prefix = <task>_<yyyymmdd_HHMMSS> (run start).
if ~isfolder(log_dir), mkdir(log_dir); end
end
