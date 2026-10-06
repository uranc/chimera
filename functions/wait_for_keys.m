function [k, t_key, aborted] = wait_for_keys(key_names, abort_key, timeout, t_ref)
% WAIT_FOR_KEYS  Wait for one of key_names (or the abort key) with a
% KbQueue, as in run_mini_screening.
%   key_names : cell of KbName names; k = index of the key pressed first
%   abort_key : KbName name (e.g. 'F10'); aborted = true if it was pressed
%   timeout   : s after t_ref (Inf = wait forever); on timeout k = 0
%   t_key     : KbQueue time stamp of the press (GetSecs clock), NaN on timeout
% kb_mode('poll') switches to KbCheck polling (remote testing over VNC).
if nargin < 3 || isempty(timeout), timeout = Inf; end
if nargin < 4 || isempty(t_ref), t_ref = GetSecs; end
codes = cellfun(@KbName, key_names);
abort_code = KbName(abort_key);
if strcmp(kb_mode(), 'poll')
    [k, t_key, aborted] = poll_keys(codes, abort_code, timeout, t_ref);
    return
end
keys = zeros(1, 256);
keys([codes, abort_code]) = 1;
KbQueueCreate([], keys);
KbQueueStart;
k = 0; t_key = NaN; aborted = false;
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
    if GetSecs - t_ref >= timeout, break; end
    WaitSecs(0.001);     % small yield so this does not spin the CPU at 100%
end
KbQueueStop;
KbQueueRelease;
end


function [k, t_key, aborted] = poll_keys(codes, abort_code, timeout, t_ref)
KbReleaseWait;
k = 0; t_key = NaN; aborted = false;
while GetSecs - t_ref < timeout
    [down, t, kc] = KbCheck;
    if down
        if kc(abort_code), aborted = true; t_key = t; return; end
        j = find(kc(codes), 1);
        if ~isempty(j), k = j; t_key = t; return; end
    end
    WaitSecs(0.001);
end
end
