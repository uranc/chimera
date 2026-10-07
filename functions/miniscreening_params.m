function p = miniscreening_params(overrides)
% MINISCREENING_PARAMS  Parameters of the mini-screening (task code 4).
% Per session concept: the original photo (THINGS instance 0), the concept's
% name written on a blank screen, and n_exemplars further THINGS photos
% (instances 1..n). Every trial is a word choice like chimera (image for
% display_time, then 4 axis words of the session, no target).
% Built on chimera_params (same timing, display, keys, hardware) with the
% values below; overrides work the same way (unknown names are an error).
%   p = miniscreening_params()  /  p = miniscreening_params(overrides)

n.task_name = 'miniscreening';
n.task_type = TaskCodes.task('miniscreening');

% the plan is complete when every presentation ran (no extra reps, no time limit)
n.min_reps    = 1;
n.max_reps    = 1;
n.max_minutes = Inf;
n.use_naming        = false;
n.catch_every       = 0;
n.n_practice_naming = 0;
n.n_practice_adj    = 0;

p = chimera_params(n);
% mini-screening only
p.originals_dir  = '';      % '' -> stimuli/subject<NNN>/originals
p.reps_original  = 1;       % presentations of each concept's original (full design: 6)
p.reps_name      = 1;       % presentations of each concept's written name (full design: 6)
p.n_exemplars    = 11;      % further photos per concept (instances 1..n), once each
p.reps_exemplar  = 1;
p.text_size_name = 110;     % written name, px on the 1024 x 1024 name image

if nargin >= 1 && ~isempty(overrides)
    p = apply_overrides(p, overrides);
end
end
