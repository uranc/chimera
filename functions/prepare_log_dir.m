function log_dir = prepare_log_dir(log_dir, prefix, allow_overwrite)
% PREPARE_LOG_DIR  Create the session log folder (logs/<pid>/<pid>_<sess>,
% as prep_trial_strx). If it already holds a session of this task:
%   allow_overwrite = false : error (use another session number)
%   allow_overwrite = true  : the old <prefix>_* files are MOVED (not deleted)
%                             into <prefix>_old_<yyyymmdd_HHMMSS>
if ~isfolder(log_dir), mkdir(log_dir); end
old = dir(fullfile(log_dir, [prefix '_*']));
old = old(~startsWith({old.name}, [prefix '_old_']));
if isempty(old), return; end
if ~allow_overwrite
    error('prepare_log_dir:exists', ['%s already holds a %s session. Use another session ' ...
        'number (or set allow_overwrite = true to move the old files aside).'], log_dir, prefix);
end
backup = fullfile(log_dir, sprintf('%s_old_%s', prefix, datestr(now, 'yyyymmdd_HHMMSS')));
mkdir(backup);
for k = 1:numel(old)
    movefile(fullfile(log_dir, old(k).name), backup);
end
warning('prepare_log_dir:moved', 'previous %s files moved to %s', prefix, backup);
end
