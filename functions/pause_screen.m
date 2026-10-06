function [go_on, ts_blank] = pause_screen(window, white, p, msg)
% PAUSE_SCREEN  Pause between segments: shows the pause text and waits for
% p.continue_key (go_on = true) or p.abort_key (go_on = false).
% ts_blank: flip time of the blank screen shown after the key.
Screen('TextSize', window, p.text_size_prompt);
DrawFormattedText(window, p.pause_text, 'center', 'center', white);
Screen('Flip', window);
fprintf('%s  [%s = continue, %s = end]\n', msg, p.continue_key, p.abort_key);
[k, ~, aborted] = wait_for_keys({p.continue_key}, p.abort_key, Inf);
go_on = ~aborted && k == 1;
Screen('FillRect', window, [0 0 0]);
ts_blank = Screen('Flip', window);
end
