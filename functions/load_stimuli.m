function stim = load_stimuli(stim_dir, p, label)
% LOAD_STIMULI  Parse the generated images in stim_dir (subfolders included).
% File name convention (stimset120 and the per-patient sets):
%     a<axis>_<axisname>_c<concept>_<conceptname>_inst<i>_a<alpha>.(jpg|png)
%     e.g. a5_plant-related_c8_banana_inst0_a02.8.jpg
% Keeps images that pass p.alpha_subset / p.concept_subset / p.axis_subset
% ([] = keep all), ranks the remaining alphas into level_id = 1..n_levels,
% prints the inventory and compares it with p.exp_*. On a mismatch the
% experimenter must confirm in the Command Window (or press Ctrl+C).
%   label: text for the printout (default 'STIMULUS'); pass [] for p to skip
%          filtering and the inventory check (used for practice images).

if nargin < 3 || isempty(label), label = 'STIMULUS'; end
if ~isfolder(stim_dir)
    error('load_stimuli:dir', 'Stimulus directory not found: %s', stim_dir);
end

files = [dir(fullfile(stim_dir, '**', '*.png')); dir(fullfile(stim_dir, '**', '*.jpg'))];
pattern = '^a(\d+)_([a-zA-Z0-9\-]+)_c(\d+)_([a-zA-Z0-9\-]+)_inst(\d+)_a(\d+\.?\d*)\.(jpg|png)$';

stim = struct('stim_idx', {}, 'image_file', {}, 'filename', {}, 'axis_id', {}, 'axis_name', {}, ...
    'concept_id', {}, 'concept_name', {}, 'inst_id', {}, 'alpha', {}, 'level_id', {});
for i = 1:numel(files)
    tok = regexp(files(i).name, pattern, 'tokens', 'once');
    if isempty(tok), continue; end
    stim(end+1) = struct( ...
        'stim_idx', NaN, ...
        'image_file', fullfile(files(i).folder, files(i).name), ...
        'filename', files(i).name, ...
        'axis_id', str2double(tok{1}), 'axis_name', tok{2}, ...
        'concept_id', str2double(tok{3}), 'concept_name', tok{4}, ...
        'inst_id', str2double(tok{5}), 'alpha', str2double(tok{6}), ...
        'level_id', NaN); %#ok<AGROW>
end
if isempty(stim)
    error('load_stimuli:none', 'No images in %s match a<axis>_<name>_c<concept>_<name>_inst<i>_a<alpha>.jpg', stim_dir);
end

%% filters
if ~isempty(p)
    if ~isempty(p.alpha_subset)
        stim = stim(ismember(round([stim.alpha] * 10), round(p.alpha_subset * 10)));
    end
    if ~isempty(p.concept_subset)
        stim = stim(ismember([stim.concept_id], p.concept_subset));
    end
    if ~isempty(p.axis_subset)
        stim = stim(ismember([stim.axis_id], p.axis_subset));
    end
    if isempty(stim)
        error('load_stimuli:filtered', 'The alpha/concept/axis subsets removed every image in %s', stim_dir);
    end
end

%% level_id = rank of alpha among the alphas present (1 = smallest); all
%% continua share the same generated steps, the incompleteness check below
%% warns if they do not
alphas = unique([stim.alpha]);
for i = 1:numel(stim)
    stim(i).stim_idx = i;
    stim(i).level_id = find(abs(alphas - stim(i).alpha) < 1e-6, 1);
end

%% inventory
axis_names    = unique({stim.axis_name});
concept_names = unique({stim.concept_name});
insts         = unique([stim.inst_id]);
fprintf('\n========== %s INVENTORY ==========\n', label);
fprintf('Folder    : %s\n', stim_dir);
fprintf('Images    : %d\n', numel(stim));
if ~isempty(p)
    fprintf('Axes      (expected %d | found %d): %s\n', p.exp_axes, numel(axis_names), strjoin(axis_names, ', '));
    fprintf('Concepts  (expected %d | found %d): %s\n', p.exp_concepts, numel(concept_names), strjoin(concept_names, ', '));
    fprintf('Instances (expected %d | found %d): %s\n', p.exp_insts, numel(insts), num2str(insts));
    fprintf('Levels    (expected %d | found %d): alpha = %s\n', p.exp_levels, numel(alphas), num2str(alphas, '%.1f '));
else
    fprintf('Axes: %s | Concepts: %s\n', strjoin(axis_names, ', '), strjoin(concept_names, ', '));
end
fprintf('==========================================\n\n');

% every continuum should be complete (one image per concept x axis x level x instance)
n_expected = numel(axis_names) * numel(concept_names) * numel(alphas) * numel(insts);
if numel(stim) ~= n_expected
    warning('load_stimuli:incomplete', '%d images, but %d axes x %d concepts x %d levels x %d instances = %d', ...
        numel(stim), numel(axis_names), numel(concept_names), numel(alphas), numel(insts), n_expected);
end

if ~isempty(p) && (numel(axis_names) ~= p.exp_axes || numel(concept_names) ~= p.exp_concepts || ...
        numel(insts) ~= p.exp_insts || numel(alphas) ~= p.exp_levels)
    warning('load_stimuli:mismatch', 'The stimulus inventory does not match the expected parameters.');
    input('Press Ctrl+C to abort, or ENTER to continue anyway... ', 's');
end
end
