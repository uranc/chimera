function p = naming_params(overrides)
% NAMING_PARAMS  Parameters of the naming block (task code 3): every image
% once, the image stays on with the prompt "what is this?", the spoken
% answer is recorded, and the patient (or experimenter) presses Space to go
% on. Runs after the mini-screening.
% Built on chimera_params (same stimuli handling, timing, display, keys,
% hardware) with the naming-specific values below; overrides work the same
% way (unknown names are an error).
%   p = naming_params()  /  p = naming_params(overrides)

n.task_name = 'naming';
n.task_type = TaskCodes.task('naming');

% one presentation per image, in random order (no concept twice in a row)
n.min_reps      = 1;
n.max_reps      = 1;
n.max_minutes   = Inf;
n.min_image_gap = 1;
n.naming_spread = 0;
n.spacing_floor = 0;

% every trial is a naming trial, no adjective trials
n.use_naming        = true;
n.catch_every       = 0;
n.n_practice_naming = 1;
n.n_practice_adj    = 0;

% microphone on; Space ends each answer, or naming_max_duration (s)
n.use_microphone      = true;
n.naming_max_duration = 15;
n.audio_buffer_secs   = 30;

n.instructions = ['Sie sehen gleich eine Reihe von Bildern.\n' ...
    'Schauen Sie zuerst auf das Kreuz in der Mitte des Bildschirms.\n\n' ...
    'Wenn unter dem Bild die Frage erscheint, sagen Sie laut, was Sie sehen:\n' ...
    'nennen Sie das Objekt, oder beschreiben Sie das Bild.\n' ...
    'Drücken Sie danach die Leertaste.\n\n' ...
    'Drücken Sie zum Starten die Leertaste.'];
n.instructions_naming = n.instructions;
n.naming_prompt = 'Was ist das?';

p = chimera_params(n);
if nargin >= 1 && ~isempty(overrides)
    p = apply_overrides(p, overrides);
end
end
