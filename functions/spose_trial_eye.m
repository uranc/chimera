function [res, aborted] = spose_trial_eye(cfg, img, hw, p)
% SPOSE_TRIAL_EYE  One SPoSE trial (the trial body of run_mini_screening):
%   image + photodiode on                    -> img_on
%   key (p.keys: left = liftable, right = not) -> response
%   image off, blank screen                  -> img_off
%   trial_end + TaskCodes.TRAIN_OUTCOME (also after F10: aborted, response 0)
% cfg, hw, res: see chimera_trial_eye.
res = empty_trial_results();
ev = TaskCodes.EVENTS;
w = hw.window;
lbl = sprintf('block-%i_trial-%i', cfg.block_id, cfg.trial_id);

dest = image_dest_rect(img, hw.windowRect, p.image_scale);
tex = Screen('MakeTexture', w, img);
Screen('DrawTexture', w, tex, [], dest);
Screen('FillRect', w, hw.white, hw.pd_rect);
res.ts_stim_on = Screen('Flip', w);
res.ts_stim_daq = send_event(hw, ev.img_on, sprintf('img_on_%s_%s', lbl, cfg.filename), res.ts_stim_on);

[k, t_key, aborted] = wait_for_keys(p.keys, p.abort_key, p.response_timeout, res.ts_stim_on);
if ~aborted && k > 0
    res.response_key = p.keys{k};
    res.ts_response = t_key;
    res.rt = t_key - res.ts_stim_on;
    res.ts_response_daq = send_event(hw, ev.response, sprintf('response_%s_%s', lbl, p.keys{k}), t_key);
end

Screen('FillRect', w, [0 0 0]);
res.ts_stim_off = Screen('Flip', w);
res.ts_blank = res.ts_stim_off;
res.ts_stim_off_daq = send_event(hw, ev.img_off, ['img_off_' lbl], res.ts_stim_off);
Screen('Close', tex);

res.response = k * ~aborted;
res.correct = TaskCodes.CORRECT.not_applicable;
res.aborted = aborted;
res.completed = ~aborted;
res.daq_outcome_values = TaskCodes.outcome_train(res.response, NaN, res.correct, res.rt, NaN);
res.ts_trial_end_daq = send_train(hw, ev.trial_end, res.daq_outcome_values, ['outcome_' lbl]);
end
