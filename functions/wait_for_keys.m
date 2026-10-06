function [k, t_key, aborted] = wait_for_keys(key_names, abort_key, timeout, t_ref, poll_fn)
% WAIT_FOR_KEYS  Wait for one of key_names (or the abort key) with a
% KbQueue, as in run_mini_screening.
%   key_names : cell of KbName names; k = index of the key pressed first
%   abort_key : KbName name (e.g. 'F10'); aborted = true if it was pressed
%   timeout   : s after t_ref (Inf = wait forever); on timeout k = 0
%   t_key     : KbQueue time stamp of the press (GetSecs clock), NaN on timeout
%   poll_fn   : optional function called on every polling cycle (e.g. to fetch audio)
% kb_mode('poll') switches to KbCheck polling (remote testing over VNC).
% The gamepad (gamepad_keys) counts as keys in both modes; only new presses.
if nargin < 3 || isempty(timeout), timeout = Inf; end
if nargin < 4 || isempty(t_ref), t_ref = GetSecs; end
if nargin < 5, poll_fn = []; end
codes = cellfun(@KbName, key_names);
abort_code = KbName(abort_key);
if strcmp(kb_mode(), 'poll')
    [k, t_key, aborted] = poll_keys(codes, abort_code, timeout, t_ref, poll_fn);
    return
end
keys = zeros(1, 256);
keys([codes, abort_code]) = 1;
KbQueueCreate([], keys);
KbQueueStart;
k = 0; t_key = NaN; aborted = false;
pad_prev = gamepad_keys();                 % buttons held on entry do not count
while true
    [pressed, firstPress] = KbQueueCheck;
    if pressed
        if firstPress(abort_code) > 0
            aborted = true; t_key = firstPress(abort_code);
            break
        end
        t = firstPress(codes);
        if any(t > 0)
            t(t == 0) = Inf;
            [t_key, k] = min(t);
            break
        end
    end
    [pad, t_pad] = gamepad_keys();
    new = pad & ~pad_prev; pad_prev = pad;
    if new(abort_code), aborted = true; t_key = t_pad; break; end
    j = find(new(codes), 1);
    if ~isempty(j), k = j; t_key = t_pad; break; end
    if GetSecs - t_ref >= timeout, break; end
    if ~isempty(poll_fn), poll_fn(); end
    session_audio('fetch');           % keep the continuous recording flowing
    WaitSecs(0.001);     % small yield so this does not spin the CPU at 100%
end
KbQueueStop;
KbQueueRelease;
end


function [k, t_key, aborted] = poll_keys(codes, abort_code, timeout, t_ref, poll_fn)
% KbCheck polling that reacts only to NEW presses of the keys asked for:
% keys already down on entry (or reported as permanently down, which some
% Windows laptops do) are ignored, so no "release all keys" wait is needed.
watch = [codes, abort_code];
[~, ~, kc] = KbCheck;
prev = logical(kc(watch)) | gamepad_keys_at(watch);
k = 0; t_key = NaN; aborted = false;
while GetSecs - t_ref < timeout
    [~, t, kc] = KbCheck;
    now_down = logical(kc(watch)) | gamepad_keys_at(watch);
    new = now_down & ~prev;
    prev = now_down;
    if new(end), aborted = true; t_key = t; return; end
    j = find(new(1:end-1), 1);
    if ~isempty(j), k = j; t_key = t; return; end
    if ~isempty(poll_fn), poll_fn(); end
    session_audio('fetch');
    WaitSecs(0.001);
end
end

function d = gamepad_keys_at(codes)
pad = gamepad_keys();
d = pad(codes);
end
