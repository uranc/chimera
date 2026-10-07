function p = miniscreening_params(overrides)
% MINISCREENING_PARAMS  Parameters of the mini-screening (task code 4).
% Per session concept: the original photo (THINGS instance 0), the concept's
% name written on a blank screen, and n_exemplars further THINGS photos
% (instances 1..n). Trial as in the dynamic repo's run_mini_screening: the
% image stays until the patient answers "can it be picked up with one hand?"
% (left arrow = yes, right arrow = no); no words.
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
% response as in dynamic run_mini_screening: response k = keys{k}
p.keys = {'LeftArrow', 'RightArrow'};      % left = can be picked up with one hand, right = not
p.response_timeout = Inf;                  % image stays until a key
p.instructions = ['In dieser Aufgabe wird Ihnen eine Bilderserie gezeigt.\n' ...
    'Wenn der Inhalt des Bildes mit einer Hand aufgenommen werden kann,\n' ...
    'drücken Sie die Pfeiltaste nach links.\n' ...
    'Wenn nicht, drücken Sie die Pfeiltaste nach rechts.\n\n' ...
    'Drücken Sie zum Starten die Leertaste.'];

if nargin >= 1 && ~isempty(overrides)
    p = apply_overrides(p, overrides);
end
end
