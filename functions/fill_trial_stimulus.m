function c = fill_trial_stimulus(c, s)
% FILL_TRIAL_STIMULUS  Copy the stimulus fields of one load_stimuli entry
% into a trial cfg.
for f = {'stim_idx', 'image_file', 'filename', 'axis_id', 'axis_name', 'spose_dim', ...
         'concept_id', 'concept_name', 'things_id', 'inst_id', 'alpha', 'level_id'}
    c.(f{1}) = s.(f{1});
end
end
