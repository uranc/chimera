function o = dummy_overrides(task)
% DUMMY_OVERRIDES  Parameter overrides for a test run of a task (no DAQ, no
% eye tracker, windowed, keyboard polling, test stimuli). Used by the
% run_*_dummy scripts and by run_session(..., 'dummy'), so both test exactly
% the same settings. task: 'chimera' | 'naming' | 'spose'.
here = fileparts(fileparts(mfilename('fullpath')));
o = struct();
o.use_daq         = false;
o.use_eyetracking = false;
o.windowed_mode   = true;
o.window_rect     = [0 0 640 480];     % fits the headless test display; bigger is fine locally
o.skip_sync_tests = 1;
o.kb_mode         = 'poll';            % KbCheck: also works over remote desktop
% the dynamic paradigm's functions folder: first existing candidate is used
o.dynamic_fcn_dir = {fullfile(here, '..', '..', 'dynamic', 'code', 'experiment', 'functions'), ...
                     fullfile(here, '..', 'dynamic', 'code', 'experiment', 'functions'), ...
                     '/home/uranc/Documents/dynamic/code/experiment/functions'};
% stimuli: the default folders for the dummies' patient 99 / session 1:
% stimuli/subject099/subject099_stimset01 and stimuli/subject099/practice
% (setup/make_stimset.py --subject 99 ...)
switch task
    case {'chimera', 'naming'}
        o.text_size_words  = 20;
        o.text_size_prompt = 16;
    case 'spose'
        o.text_size_prompt = 16;
    otherwise
        error('dummy_overrides:task', 'unknown task "%s"', task);
end
end
