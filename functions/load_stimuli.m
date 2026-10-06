function stim = load_stimuli(stim_dir, p, label)
% LOAD_STIMULI  Parse the generated images in stim_dir (subfolders included).
% File name conventions:
%     a<axis>_<axisname>_c<concept>_<conceptname>_inst<i>_s<step>.(jpg|png)
%         step 1..3 generated, 0 = original (setup/make_stimset.py)
%         e.g. a13_outdoors_c38_glove_inst0_s2.jpg ; level_id = step
%     a<axis>_<axisname>_c<concept>_<conceptname>_inst<i>_a<alpha>.(jpg|png)
%         older sets (stimset120); level_id = rank of alpha
% Keeps images that pass p.step_subset / p.inst_subset / p.alpha_subset /
% p.concept_subset / p.axis_subset ([] = keep all),
% prints the inventory and compares it with p.exp_*. On a mismatch the
% experimenter must confirm in the Command Window (or press Ctrl+C).
%   label: text for the printout (default 'STIMULUS'); pass [] for p to skip
%          filtering and the inventory check (used for practice images).

if nargin < 3 || isempty(label), label = 'STIMULUS'; end
if ~isfolder(stim_dir)
    error('load_stimuli:dir', 'Stimulus directory not found: %s', stim_dir);
end

files = [dir(fullfile(stim_dir, '**', '*.png')); dir(fullfile(stim_dir, '**', '*.jpg'))];
pattern = '^a(\d+)_([a-zA-Z0-9\-]+)_c(\d+)_([a-zA-Z0-9\-]+)_inst(\d+)_([as])(\d+\.?\d*)\.(jpg|png)$';

stim = struct('stim_idx', {}, 'image_file', {}, 'filename', {}, 'axis_id', {}, 'axis_name', {}, ...
    'concept_id', {}, 'concept_name', {}, 'inst_id', {}, 'alpha', {}, 'step', {}, 'level_id', {});
for i = 1:numel(files)
    tok = regexp(files(i).name, pattern, 'tokens', 'once');
    if isempty(tok), continue; end
    stim(end+1) = struct( ...
        'stim_idx', NaN, ...
        'image_file', fullfile(files(i).folder, files(i).name), ...
        'filename', files(i).name, ...
        'axis_id', str2double(tok{1}), 'axis_name', tok{2}, ...
        'concept_id', str2double(tok{3}), 'concept_name', tok{4}, ...
        'inst_id', str2double(tok{5}), ...
        'alpha', ternary(tok{6} == 'a', str2double(tok{7}), NaN), ...
        'step', ternary(tok{6} == 's', str2double(tok{7}), NaN), ...
        'level_id', NaN); %#ok<AGROW>
end
if isempty(stim)
    error('load_stimuli:none', 'No images in %s match a<axis>_<name>_c<concept>_<name>_inst<i>_a<alpha>.jpg', stim_dir);
end

%% filters
if ~isempty(p)
    if isfield(p, 'step_subset') && ~isempty(p.step_subset)
        stim = stim(isnan([stim.step]) | ismember([stim.step], p.step_subset));
    end
    if isfield(p, 'inst_subset') && ~isempty(p.inst_subset)
        stim = stim(ismember([stim.inst_id], p.inst_subset));
    end
    if ~isempty(p.alpha_subset)
        stim = stim(isnan([stim.alpha]) | ismember(round([stim.alpha] * 10), round(p.alpha_subset * 10)));
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

%% level_id: generated step (s1..s3) or, for older alpha-named sets, the rank
%% of alpha among the alphas present; the incompleteness check below
%% warns if they do not
% level_id: the step (new sets) or the rank of alpha (older sets)
alphas = unique([stim(~isnan([stim.alpha])).alpha]);
for i = 1:numel(stim)
    stim(i).stim_idx = i;
    if ~isnan(stim(i).step)
        stim(i).level_id = stim(i).step;
    else
        stim(i).level_id = find(abs(alphas - stim(i).alpha) < 1e-6, 1);
    end
end
levels = unique([stim.level_id]);

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
    fprintf('Levels    (expected %d | found %d): %s\n', p.exp_levels, numel(levels), num2str(levels));
else
    fprintf('Axes: %s | Concepts: %s\n', strjoin(axis_names, ', '), strjoin(concept_names, ', '));
end
fprintf('==========================================\n\n');

% every continuum should be complete (one image per concept x axis x level x instance)
n_expected = numel(axis_names) * numel(concept_names) * numel(levels) * numel(insts);
if numel(stim) ~= n_expected
    warning('load_stimuli:incomplete', '%d images, but %d axes x %d concepts x %d levels x %d instances = %d', ...
        numel(stim), numel(axis_names), numel(concept_names), numel(levels), numel(insts), n_expected);
end

if ~isempty(p) && (numel(axis_names) ~= p.exp_axes || numel(concept_names) ~= p.exp_concepts || ...
        numel(insts) ~= p.exp_insts || numel(levels) ~= p.exp_levels)
    warning('load_stimuli:mismatch', 'The stimulus inventory does not match the expected parameters.');
    input('Press Ctrl+C to abort, or ENTER to continue anyway... ', 's');
end
end


function v = ternary(c, a, b)
if c, v = a; else, v = b; end
end
