function check_dynamic_helpers(dynamic_fcn_dir)
% CHECK_DYNAMIC_HELPERS  daqInit, daqOut and fixation_cross_eye come from
% the dynamic paradigm's functions folder (the same "functions" folder on
% the rig, or dynamic_fcn_dir). Fail at the start, not mid-session.
if ~isempty(dynamic_fcn_dir) && isfolder(dynamic_fcn_dir)
    addpath(dynamic_fcn_dir);
end
missing = {'daqInit', 'daqOut', 'fixation_cross_eye'};
missing = missing(cellfun(@(f) exist(f, 'file') ~= 2, missing));
if ~isempty(missing)
    error('check_dynamic_helpers:missing', ['%s not found. Put the dynamic paradigm''s ' ...
        'functions folder on the path or set dynamic_fcn_dir.'], strjoin(missing, ', '));
end
end
