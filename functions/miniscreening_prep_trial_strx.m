function [jitter_times, ...
    img_names, img_randomization, Images, ...
    Images_mini_screening_filenames, ...
    log_dir, trial_values] = miniscreening_prep_trial_strx(patient_id, session_nr, ...
    nm_blocks, jitter_min, jitter_max, stim_dir, originals_dir, n_exemplars, log_dir, file_prefix)
% MINISCREENING_PREP_TRIAL_STRX  dynamic's mini_screening_prep_trial_strx with
% this task's images and reps. Per concept of the session stimset (stim_dir):
%   original photo  (originals/a0_original0_..._inst0)       in every block
%   written name    (originals/a0_name0_...)                  in every block
%   n_exemplars further photos (originals/..._inst1..n)       once each, spread over the blocks
% so original and name are shown nm_blocks times. Order inside a block is
% random, with no concept twice in a row.
%   img_names         : 1 x n_items dir-like struct (name, folder) of all items
%   img_randomization : nm_blocks x n_slots item index per trial, 0 = no trial
%                       (blocks differ in length by at most 1)
%   Images, Images_mini_screening_filenames : nm_blocks x n_slots, {} = no trial
%   trial_values : nm_blocks x n_slots daq trial train (TaskCodes.trial_train:
%                  task 4, patient, session, block, trial, axis 0, concept =
%                  index in the session stimset, instance, level 0, rep,
%                  trial type original 5 / name 6 / exemplar 7, no options)
% Saved (-v6, as in dynamic) with file_prefix in front of dynamic's names.

disp("  ... generating trial structure ...");

% the session's concepts, by name (the c<n> index in originals/ is that of
% the stimset that wrote the file first)
sess = dir(fullfile(stim_dir, '*.jpg'));
tok = regexp({sess.name}, '_c(\d+)_([a-zA-Z]+?)(\d+)_inst', 'tokens', 'once');
tok = vertcat(tok{:});
[concepts, k] = unique(strcat(tok(:, 2), tok(:, 3)), 'stable');  % e.g. banana64
concept_ids = str2double(tok(k, 1))';                             % c<n> in the session stimset

fixed = {}; extra = {}; extra_concept = []; fixed_concept = [];
fixed_type = []; extra_inst = [];
tt = TaskCodes.TRIAL_TYPES;
for c = 1:numel(concepts)
    f = @(pat) dir(fullfile(originals_dir, sprintf(pat, concepts{c})));
    o = f('a0_original0_c*_%s_inst0_level0.jpg');
    nm = f('a0_name0_c*_%s_inst0_level0.jpg');
    if isempty(o) || isempty(nm)
        error('miniscreening_prep_trial_strx:missing', 'original or name image for %s missing in %s', ...
            concepts{c}, originals_dir);
    end
    fixed = [fixed, {fullfile(o(1).folder, o(1).name), fullfile(nm(1).folder, nm(1).name)}]; %#ok<AGROW>
    fixed_concept = [fixed_concept, c, c]; %#ok<AGROW>
    fixed_type = [fixed_type, tt.original, tt.name]; %#ok<AGROW>
    for k = 1:n_exemplars
        e = f(['a0_original0_c*_%s_inst' num2str(k) '_level0.jpg']);
        if isempty(e)
            warning('miniscreening_prep_trial_strx:exemplar', '%s: exemplar %d missing', concepts{c}, k);
            continue
        end
        extra{end+1} = fullfile(e(1).folder, e(1).name); %#ok<AGROW>
        extra_concept(end+1) = c; %#ok<AGROW>
        extra_inst(end+1) = k; %#ok<AGROW>
    end
end
files = [fixed, extra];
concept_of = [fixed_concept, extra_concept];
type_of = [fixed_type, repmat(tt.exemplar, 1, numel(extra))];
inst_of = [zeros(1, numel(fixed)), extra_inst];
[folders, names, exts] = cellfun(@fileparts, files, 'UniformOutput', false);
img_names = struct('name', strcat(names, exts), 'folder', folders);

% exemplars spread over the blocks (shuffled, round robin)
n_fixed = numel(fixed);
ex_idx = n_fixed + randperm(numel(extra));
block_items = cell(nm_blocks, 1);
for b = 1:nm_blocks
    block_items{b} = [1:n_fixed, ex_idx(b:nm_blocks:end)];
end

n_slots = max(cellfun(@numel, block_items));
img_randomization = zeros(nm_blocks, n_slots);
Images = cell(nm_blocks, n_slots);
Images_mini_screening_filenames = cell(nm_blocks, n_slots);
trial_values = cell(nm_blocks, n_slots);
n_shown = zeros(1, numel(files));
trial_nr = 0;
for i = 1:nm_blocks
    items = block_items{i};
    for attempt = 1:1000                       % random order, no concept twice in a row
        order = items(randperm(numel(items)));
        if ~any(diff(concept_of(order)) == 0), break; end
    end
    img_randomization(i, 1:numel(order)) = order;
    for ci = 1:numel(order)
        img_path = files{order(ci)};
        Images{i, ci} = imread(img_path);
        Images_mini_screening_filenames{i, ci} = img_path;
        it = order(ci);
        n_shown(it) = n_shown(it) + 1;
        trial_nr = trial_nr + 1;
        cfg = struct('task_type', TaskCodes.task('miniscreening'), 'patient_id', patient_id, ...
            'session_nr', session_nr, 'block_id', i, 'trial_id', trial_nr, 'axis_id', 0, ...
            'concept_id', concept_ids(concept_of(it)), 'inst_id', inst_of(it), 'level_id', 0, ...
            'rep_id', n_shown(it), 'trial_type', type_of(it), 'target_pos', 0, 'option_axis_ids', []);
        trial_values{i, ci} = TaskCodes.trial_train(cfg);
    end
end

jitter_times = (randi([jitter_min*1000, jitter_max*1000], nm_blocks, n_slots) / 1000);

disp("  ... saving mini-screening variables as logfiles ...");
if ~isfolder(log_dir), mkdir(log_dir); end
save(fullfile(log_dir, [file_prefix '_jitter_times.mat']), "jitter_times", '-v6');
save(fullfile(log_dir, [file_prefix '_randomization.mat']), "img_randomization", "img_names", '-v6');
save(fullfile(log_dir, [file_prefix '_randomization_filenames.mat']), "Images_mini_screening_filenames", "trial_values", '-v6');

end
