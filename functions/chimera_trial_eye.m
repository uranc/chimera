function [res, aborted] = chimera_trial_eye(cfg, img, hw, p)
% CHIMERA_TRIAL_EYE  One chimera trial from image onset to the outcome train
% (counterpart of static_block_eye + participant_response_eye). The run
% script sends the trial_start train and runs fixation_cross_eye before it.
%
% adjective / catch trial
%   image + photodiode on                         -> img_on
%   at display_time: image off and words on (one flip)
%                                                 -> img_off, question
%   arrow key (p.adj_keys)                        -> response
%   chosen word highlighted for p.highlight_duration, then blank screen
% naming trial
%   image + photodiode on                         -> img_on
%   at display_time: soft answer tone, image stays (no text)
%                                                 -> question (at tone onset)
%   p.naming_end_keys (no time limit by default)  -> response
%   image off, blank screen                       -> img_off
%   voice onset estimated from the continuous session recording
% every trial ends with trial_end + TaskCodes.TRAIN_OUTCOME, also after F10
% (aborted = true, response 0).
%
% cfg : one trial of the plan (prep_chimera_trials)
% img : image matrix (read by the run script before the fixation cross)
% hw  : window, windowRect, white, ifi, pd_rect, daq, EThndl, pa, fs, tone, log_dir
% res : empty_trial_results() filled with time stamps and the response

res = empty_trial_results();
ev = TaskCodes.EVENTS;
w = hw.window;
H = hw.windowRect(4);
lbl = sprintf('block-%i_trial-%i', cfg.block_id, cfg.trial_id);
is_naming = strcmp(cfg.trial_type_name, 'naming');

dest = image_dest_rect(img, hw.windowRect, p.image_scale);
tex = Screen('MakeTexture', w, img);

%% image onset
draw_image(w, tex, dest, hw, p);
res.ts_stim_on = Screen('Flip', w);
res.ts_stim_daq = send_event(hw, ev.img_on, sprintf('img_on_%s_%s', lbl, cfg.filename), res.ts_stim_on);
t_switch = res.ts_stim_on + p.display_time - hw.ifi / 2;    % flip at display_time

if is_naming
    %% answer cue at display_time: soft tone (or the written prompt if
    %% tone_naming is off); the image stays until the spoken response ends
    if p.tone_naming
        delay = p.display_time;
        if ~isempty(p.tone_delay), delay = p.tone_delay; end
        res.ts_question = tone_play(hw.tone, res.ts_stim_on + delay);
    else
        draw_image(w, tex, dest, hw, p);
        Screen('TextSize', w, p.text_size_prompt);
        DrawFormattedText(w, p.naming_prompt, 'center', dest(4) + 0.05 * H, hw.white);
        res.ts_question = Screen('Flip', w, t_switch);
    end
    res.ts_question_daq = send_event(hw, ev.question, ['answer_cue_' lbl], res.ts_question);

    [k, t_key, aborted] = wait_for_keys(p.naming_end_keys, p.abort_key, p.naming_max_duration, ...
        res.ts_question);
    if ~aborted && k > 0
        res.response_key = p.naming_end_keys{k};
        res.ts_response_daq = send_event(hw, ev.response, ['response_' lbl], t_key);
    end

    Screen('FillRect', w, [0 0 0]);
    res.ts_stim_off = Screen('Flip', w);
    res.ts_blank = res.ts_stim_off;
    res.ts_stim_off_daq = send_event(hw, ev.img_off, ['img_off_' lbl], res.ts_stim_off);

    % the session recording is continuous (session_audio); this trial only
    % notes where it is in that file and estimates the voice onset
    if session_audio('active')
        rec = session_audio('since', res.ts_stim_on);
        res.audio_file = hw.audio_file;
        res.audio_capture_start = session_audio('t0');
        res.voice_onset = detect_voice_onset(rec.audio, hw.fs, rec.t0, res.ts_stim_on, p.voice_threshold);
    end
    res.correct = TaskCodes.CORRECT.not_applicable;
else
    %% image off and words on in one flip
    draw_word_diamond(w, hw.windowRect, cfg.option_labels, hw.white, p);
    res.ts_stim_off = Screen('Flip', w, t_switch);
    res.ts_question = res.ts_stim_off;
    if p.tone_adjective, tone_play(hw.tone, GetSecs); end
    res.ts_stim_off_daq = send_event(hw, ev.img_off, ['img_off_' lbl], res.ts_stim_off);
    res.ts_question_daq = send_event(hw, ev.question, sprintf('words_%s_%s', lbl, ...
        strjoin(cfg.option_names, '-')), res.ts_question);

    [k, t_key, aborted] = wait_for_keys(p.adj_keys, p.abort_key, p.response_timeout, res.ts_question);
    res.correct = TaskCodes.CORRECT.not_applicable;
    if ~aborted && k > 0
        res.response_key = p.adj_keys{k};
        res.chosen_pos = k;
        res.chosen_axis_id = cfg.option_axis_ids(k);
        res.chosen_label = cfg.option_labels{k};
        if cfg.target_pos > 0
            res.correct = double(k == cfg.target_pos);   % CORRECT.right / .wrong
        end
        res.ts_response_daq = send_event(hw, ev.response, sprintf('response_%s_%s', lbl, ...
            cfg.option_names{k}), t_key);
        % feedback: the chosen word in the highlight colour, then the blank
        draw_word_diamond(w, hw.windowRect, cfg.option_labels, hw.white, p, k);
        t_hl = Screen('Flip', w);
        WaitSecs('UntilTime', t_hl + p.highlight_duration);
    end

    Screen('FillRect', w, [0 0 0]);
    res.ts_blank = Screen('Flip', w);
end
Screen('Close', tex);

%% response bookkeeping
res.response = k;                   % 0 = timeout or abort
if ~aborted && k > 0
    res.ts_response = t_key;
    res.rt = t_key - res.ts_stim_on;
    res.rt_question = t_key - res.ts_question;
end
res.aborted = aborted;
res.completed = ~aborted;

%% outcome train
if aborted, res.response = 0; end
res.daq_outcome_values = TaskCodes.outcome_train(res.response, res.chosen_axis_id, ...
    res.correct, res.rt, res.voice_onset);
res.ts_trial_end_daq = send_train(hw, ev.trial_end, res.daq_outcome_values, ['outcome_' lbl]);
end


function draw_image(w, tex, dest, hw, p)
% image plus the white photodiode square (white exactly while the image is on)
Screen('DrawTexture', w, tex, [], dest);
Screen('FillRect', w, hw.white, hw.pd_rect);
draw_fixation_dot(w, hw.windowRect, p);
end
