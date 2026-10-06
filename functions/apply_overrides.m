function p = apply_overrides(p, overrides)
% APPLY_OVERRIDES  Replace fields of the parameter struct p with the fields
% of overrides. Unknown names are an error, so a typo in a dummy override
% cannot silently fall back to the rig default.
fn = fieldnames(overrides);
for k = 1:numel(fn)
    if ~isfield(p, fn{k})
        error('apply_overrides:unknown', 'unknown parameter "%s"', fn{k});
    end
    p.(fn{k}) = overrides.(fn{k});
end
end
