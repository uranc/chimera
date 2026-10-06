function check_dynamic_helpers(dynamic_fcn_dir)
% CHECK_DYNAMIC_HELPERS  daqInit, daqOut and fixation_cross_eye come from
% the dynamic paradigm's functions folder (the same "functions" folder on
% the rig, or dynamic_fcn_dir). Fail at the start, not mid-session.
% dynamic_fcn_dir: a folder, or a cell of candidate folders (first existing
% one is used), so one setting works on Windows and Linux
if ischar(dynamic_fcn_dir) || isstring(dynamic_fcn_dir), dynamic_fcn_dir = {char(dynamic_fcn_dir)}; end
for k = 1:numel(dynamic_fcn_dir)
    if ~isempty(dynamic_fcn_dir{k}) && isfolder(dynamic_fcn_dir{k})
        addpath(dynamic_fcn_dir{k});
        break
    end
end
missing = {'daqInit', 'daqOut', 'fixation_cross_eye'};
missing = missing(cellfun(@(f) exist(f, 'file') ~= 2, missing));
if ~isempty(missing)
    error('check_dynamic_helpers:missing', ['%s not found. Put the dynamic paradigm''s ' ...
        'functions folder on the path or set dynamic_fcn_dir.'], strjoin(missing, ', '));
end
end
