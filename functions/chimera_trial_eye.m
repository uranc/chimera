function [res, aborted] = chimera_trial_eye(cfg, img, hw, p)
% CHIMERA_TRIAL_EYE  One chimera trial from image onset to the outcome train
% (counterpart of static_block_eye + participant_response_eye). The run
% script sends the trial_start train and runs fixation_cross_eye before it.
%
% naming trial
%   image + photodiode on                         -> img_on
%   at display_time: soft answer tone, image stays (no text)
%                                                 -> question (at tone onset)
%   p.naming_end_keys (no time limit by default)  -> response
%   image off, blank screen                       -> img_off
%   voice onset estimated from the continuous session recording
% question trial
%   image + photodiode on, keys (p.question_keys) count from here -> img_on
%   at exactly display_time: image off                -> img_off
%     answered already: blank screen (rt_question < 0)
%     not yet: question + Ja/Nein until the key        -> question, response
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

dest = image_dest_rect(img, hw.windowRect, image_size(p));
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
    %% yes/no question: keys count from image onset; the image stays on for
    %% exactly display_time; if not answered by then, the question screen
    %% (question + Ja/Nein) stays until the key
    [k, t_key, aborted] = wait_for_keys(p.question_keys, p.abort_key, ...
        max(p.display_time - 1.5 * hw.ifi, 0), res.ts_stim_on);
    answered = ~aborted && k > 0;
    if answered
        Screen('FillRect', w, [0 0 0]);      % answered during the image: blank at display_time
    else
        draw_question(w, hw.windowRect, p, hw.white, 0);
    end
    res.ts_stim_off = Screen('Flip', w, t_switch);
    res.ts_question = res.ts_stim_off;
    res.ts_stim_off_daq = send_event(hw, ev.img_off, ['img_off_' lbl], res.ts_stim_off);
    if ~answered && ~aborted
        if p.tone_adjective, tone_play(hw.tone, GetSecs); end
        res.ts_question_daq = send_event(hw, ev.question, ['question_' lbl], res.ts_question);
        [k, t_key, aborted] = wait_for_keys(p.question_keys, p.abort_key, p.response_timeout, res.ts_question);
    end
    res.correct = TaskCodes.CORRECT.not_applicable;
    if ~aborted && k > 0
        res.response_key = p.question_keys{k};
        res.chosen_pos = k;
        res.chosen_label = p.question_labels{k};
        res.ts_response_daq = send_event(hw, ev.response, sprintf('response_%s_%s', lbl, ...
            p.question_labels{k}), t_key);
        if ~answered                          % feedback only on the question screen
            draw_question(w, hw.windowRect, p, hw.white, k);
            t_hl = Screen('Flip', w);
            WaitSecs('UntilTime', t_hl + p.highlight_duration);
        end
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


function draw_question(w, rect, p, white, hl)
% question at the top third, answer 1 on the left half, answer 2 on the right
% half (matches question_keys); hl > 0 draws that answer in the highlight colour
W = rect(3); H = rect(4);
Screen('TextSize', w, p.text_size_prompt);
DrawFormattedText(w, p.question_text, 'center', 0.3 * H, white);
hc = p.highlight_color;
if white <= 1 && max(hc) > 1, hc = hc / 255; end    % PsychDefaultSetup(2): colours 0..1
Screen('TextSize', w, min(p.text_size_words, round(0.12 * H)));
boxes = {[0 0.4*H W/2 0.8*H], [W/2 0.4*H W 0.8*H]};
for k = 1:2
    col = white;
    if k == hl, col = hc; end
    DrawFormattedText(w, p.question_labels{k}, 'center', 'center', col, [], [], [], [], [], boxes{k});
end
draw_fixation_dot(w, rect, p);
end


function sz = image_size(p)
% p.image_size ([w h] px) if set, else p.image_scale
sz = p.image_size;
if isempty(sz), sz = p.image_scale; end
end
