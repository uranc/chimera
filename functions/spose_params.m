function p = spose_params(overrides)
% SPOSE_PARAMS  All parameters of the SPoSE control task ("could you lift
% it?", image until key) in one place; see chimera_params for the layout.
%   p = spose_params()  /  p = spose_params(overrides)

%% task
p.task_name = 'spose';
p.task_type = TaskCodes.task('spose');
p.file_prefix = '';             % set by the run script: <task>_<yyyymmdd_HHMMSS>, on every saved file

%% stimuli
p.stim_dir       = '';          % '' -> stimuli/subject<NNN>_stimset<NN> (patient_id, session_nr)
p.step_subset    = [1 2 3];     % levels: 1..3 generated (0 = original, used by the mini-screening)
p.inst_subset    = 1;           % instance (exemplar) of each concept
p.alpha_subset   = [];
p.concept_subset = [];
p.axis_subset    = [];
p.exp_concepts = 4;
p.exp_axes     = 8;
p.exp_insts    = 1;
p.exp_levels   = 3;

%% repetitions and stopping
p.min_reps           = 6;
p.max_reps           = 6;
p.max_minutes        = Inf;
p.pause_every_trials = 96;
p.min_image_gap      = 20;
p.spacing_floor      = 0.5;

%% timing (s)
p.jitter_min        = 0.2;
p.jitter_max        = 0.4;
p.blank_duration    = 0.1;
p.fixation_duration = 0.3;
p.response_timeout  = Inf;      % image stays until a key

%% display
p.image_scale       = 0.8;
p.photodiode_size   = 100;
p.photodiode_corner = 'topright';
p.text_size_prompt  = 34;

%% keys: response k = keys{k}; left = liftable, right = not liftable
p.keys         = {'LeftArrow', 'RightArrow'};
p.continue_key = 'Space';
p.abort_key    = 'F10';

%% practice / microphone (not used by this task)
p.use_microphone = false;

%% texts
p.instructions = ['Bei diesem Experiment wird Ihnen eine Reihe von Bildern gezeigt.\n' ...
    'Schauen Sie zuerst auf das Kreuz in der Mitte des Bildschirms.\n' ...
    'Entscheiden Sie dann bei jedem Bild so schnell wie möglich:\n' ...
    'Könnte man das Objekt hochheben?  Pfeil links = ja,  Pfeil rechts = nein.\n' ...
    'Das Bild bleibt so lange stehen, bis Sie geantwortet haben.\n\n' ...
    'Drücken Sie zum Starten die Leertaste.'];
p.pause_text = 'Kurze Pause.';

%% hardware and debugging
p.use_daq         = true;
p.use_eyetracking = true;
p.which_screen    = 0;
p.windowed_mode   = false;
p.window_rect     = [0 0 800 600];
p.skip_sync_tests = 0;
p.dynamic_fcn_dir = '';
p.rng_seed        = [];
p.kb_mode         = 'queue';    % 'queue' (KbQueue, rig) | 'poll' (KbCheck, remote test over VNC)

if nargin >= 1 && ~isempty(overrides)
    p = apply_overrides(p, overrides);
end
if p.max_reps < p.min_reps
    error('spose_params:reps', 'max_reps (%d) < min_reps (%d)', p.max_reps, p.min_reps);
end
end
