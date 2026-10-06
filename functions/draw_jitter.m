function j = draw_jitter(p)
% DRAW_JITTER  Jittered blank before the fixation cross, drawn as in
% prep_trial_strx: ms resolution, uniform in [p.jitter_min, p.jitter_max] s.
j = randi([round(p.jitter_min * 1000), round(p.jitter_max * 1000)]) / 1000;
end
