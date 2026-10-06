function p = chimera_params(overrides)
% CHIMERA_PARAMS  All parameters of the chimera task in one place.
%   p = chimera_params()           rig defaults
%   p = chimera_params(overrides)  struct whose fields replace defaults
%                                  (unknown field names are an error)
% run_chimera_eye and run_chimera_dummy both read their parameters here,
% so the rig and the debug run can never drift apart; the dummy only
% passes overrides (hardware off, test stimuli).

%% task
p.task_name = 'chimera';
p.task_type = TaskCodes.task('chimera');
p.file_prefix = '';             % set by the run script: <task>_<yyyymmdd_HHMMSS>, on every saved file

%% stimuli
% '' -> stimuli/<patient_id>/<patient_id>_<session_nr> (as run_dynamic_eye)
p.stim_dir       = '';
% filters on the parsed filenames, [] = keep all
p.alpha_subset   = [];          % e.g. [1.1 3.3 5.5] for stimset120: 3 generated steps, no original
p.concept_subset = [];          % concept ids from the screening
p.axis_subset    = [];          % axis ids
% expected inventory (checked after filtering; a mismatch asks for confirmation)
p.exp_concepts = 4;
p.exp_axes     = 8;
p.exp_insts    = 1;
p.exp_levels   = 3;             % generated steps per axis (the original is not part of chimera)

%% repetitions and stopping
p.min_reps           = 6;       % presentations per image needed for the neural analysis (hard minimum)
p.max_reps           = 11;      % presentations planned per image (extra ones run if time allows)
p.max_minutes        = 40;      % stop once this is exceeded AND every image has min_reps presentations
p.pause_every_trials = 96;      % pause screen (Space = continue, F10 = end) every N trials
p.min_image_gap      = 20;      % minimum trials between two presentations of the same image

%% trial types
% every presentation is an adjective trial (4 adjectives, the manipulated
% axis's adjective + 3 others); one in every catch_every is a catch (target
% absent). use_naming = true makes presentation 1 of every image a naming
% trial (image stays on, spoken response recorded).
p.use_naming    = false;
p.naming_spread = 0.3;          % first presentations (naming) spread over this fraction of the minimum session
p.spacing_floor = 0.7;          % repeats of an image no sooner than this fraction of the ideal spacing
                                % (n_images trials); wins over naming_spread when they conflict
p.catch_every   = 5;            % one catch per 5 adjective presentations of an image (0 = no catch)
p.n_options     = 4;            % adjective words per trial

%% timing (s)
p.jitter_min          = 0.2;    % jittered blank before the fixation cross
p.jitter_max          = 0.4;
p.blank_duration      = 0.1;    % fixed blank after each trial (added to the jitter)
p.fixation_duration   = 0.3;
p.display_time        = 1.5;    % image alone; adjective trials: image off at this time, words on
p.response_timeout    = Inf;    % adjective trials: words stay until a key (Inf = no limit)
p.naming_max_duration = Inf;    % naming trials: wait for the key (Inf = no time limit)

%% display
p.image_scale       = 0.7;      % image height as a fraction of the screen height
p.photodiode_size   = 100;      % px, white while the image is on screen
p.photodiode_corner = 'topright';
p.text_size_words   = 40;       % adjective words
p.text_size_prompt  = 34;       % prompts and messages
p.word_dx           = 0.22;     % word diamond: horizontal offset (fraction of screen width)
p.word_dy           = 0.20;     % word diamond: vertical offset (fraction of screen height)
p.highlight_color   = [255 200 0];  % chosen word after the key press (fixed colour)
p.highlight_duration = 0.3;     % s the highlighted choice stays before the blank
p.fixation_dot      = false;    % extra fixation point on the image and response screen (the pre-stimulus cross is the fixation)
p.fixation_dot_size = 8;        % px
p.fixation_dot_color = [255 0 0];

%% keys (KbName('UnifyKeyNames') names)
% adjective option k is answered with adj_keys{k}; the word diamond places
% option 1 up, 2 left, 3 right, 4 down to match the arrow keys.
p.adj_keys        = {'UpArrow', 'LeftArrow', 'RightArrow', 'DownArrow'};
p.naming_end_keys = {'Space'};  % patient / experimenter ends the spoken response
p.continue_key    = 'Space';
p.abort_key       = 'F10';      % ends the session (data so far is saved)

%% practice (images of concepts that are NOT in the session)
p.practice_dir      = '';       % '' -> concepts in stim_dir that are not in the session
p.n_practice_naming = 1;
p.n_practice_adj    = 3;

%% microphone (naming trials)
p.use_microphone    = false;     % only needed with use_naming
p.mic_device        = [];       % [] = default capture device
p.mic_channels      = 1;
p.audio_buffer_secs = 30;       % capture buffer; emptied continuously while waiting for the key
p.voice_threshold   = 0.1;      % amplitude for the online voice-onset estimate (offline analysis recomputes)

%% answer tone: soft beep when it is time to answer; its onset is sent to the
%% daq as the question pulse (sync). Naming trials: replaces the written prompt.
p.use_tone       = true;
p.tone_naming    = true;        % naming trials: tone at display_time, no text
p.tone_adjective = false;       % adjective trials: also beep when the words appear
p.tone_freq      = 750;         % Hz
p.tone_dur       = 0.12;        % s
p.tone_volume    = 0.2;         % 0..1
p.tone_device    = [];          % [] = default playback device

%% texts (German, patient facing)
p.instructions = ['Bei diesem Experiment sehen Sie eine Reihe von Bildern.\n' ...
    'Schauen Sie zuerst auf das Kreuz in der Mitte des Bildschirms.\n\n' ...
    'Nach jedem Bild erscheinen vier Wörter.\n' ...
    'Wählen Sie mit den Pfeiltasten das Wort, das am besten zum Bild passt.\n\n' ...
    'Drücken Sie zum Starten die Leertaste.'];
p.instructions_naming = ['Bei diesem Experiment sehen Sie eine Reihe von Bildern.\n' ...
    'Schauen Sie zuerst auf das Kreuz in der Mitte des Bildschirms.\n\n' ...
    'Bei manchen Bildern hören Sie einen kurzen Ton, das Bild bleibt stehen:\n' ...
    'Nennen Sie dann laut das Objekt, oder beschreiben Sie, was Sie sehen.\n' ...
    'Drücken Sie eine Taste, wenn Sie fertig sind.\n\n' ...
    'Bei den anderen Bildern verschwindet das Bild, und es erscheinen vier Wörter.\n' ...
    'Wählen Sie mit den Pfeiltasten das Wort, das am besten zum Bild passt.\n\n' ...
    'Drücken Sie zum Starten die Leertaste.'];   % used when use_naming = true
p.adj_prompt      = 'Welches Wort passt am besten zum Bild?';
p.naming_prompt   = 'Was ist das? Nennen Sie das Objekt oder beschreiben Sie das Bild.';
p.pause_text      = 'Kurze Pause.';
p.practice_end_text = 'Ende der Übung.';

%% hardware and debugging (run_chimera_dummy overrides these)
p.use_daq         = true;
p.use_eyetracking = true;
p.which_screen    = 0;
p.windowed_mode   = false;
p.window_rect     = [0 0 800 600];
p.skip_sync_tests = 0;
p.allow_overwrite = false;      % refuse to overwrite an existing chimera session folder
p.dynamic_fcn_dir = '';         % folder with daqInit/daqOut/fixation_cross_eye if not on the path
p.rng_seed        = [];         % [] = seed from the clock (the seed is saved either way)
p.kb_mode         = 'queue';    % 'queue' (KbQueue, rig) | 'poll' (KbCheck, remote test over VNC)

%% apply overrides and check
if nargin >= 1 && ~isempty(overrides)
    p = apply_overrides(p, overrides);
end
if p.use_naming, p.instructions = p.instructions_naming; end
check_params(p);
end


function check_params(p)
if p.max_reps < p.min_reps
    error('chimera_params:reps', 'max_reps (%d) < min_reps (%d)', p.max_reps, p.min_reps);
end
if numel(p.adj_keys) ~= p.n_options
    error('chimera_params:keys', 'need one adj_key per option (%d keys, %d options)', numel(p.adj_keys), p.n_options);
end
if p.n_options ~= 4
    error('chimera_params:options', 'the word diamond and the trial train support exactly 4 options');
end
if p.naming_spread < 0 || p.naming_spread > 1
    error('chimera_params:spread', 'naming_spread must be in [0, 1]');
end
if p.audio_buffer_secs < 5
    error('chimera_params:audio', 'audio_buffer_secs should be at least 5 s');
end
end
