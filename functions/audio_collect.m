function out = audio_collect(cmd, pa)
% AUDIO_COLLECT  Accumulate microphone samples while a naming trial waits
% for the key, so a response can last any length without overflowing the
% capture buffer.
%   audio_collect('reset')        empty the accumulator
%   audio_collect('fetch', pa)    append what was captured since the last fetch
%   s = audio_collect('get')      s.audio (channels x samples), s.t0 (GetSecs
%                                 time of the first sample), s.overflow
persistent buf t0 ovf
out = [];
switch cmd
    case 'reset'
        buf = []; t0 = NaN; ovf = false;
    case 'fetch'
        if isempty(pa), return; end
        [a, ~, o, tcs] = PsychPortAudio('GetAudioData', pa);
        if ~isempty(a)
            if isempty(buf), t0 = tcs; end
            buf = [buf, a];
        end
        ovf = ovf || logical(o);
    case 'get'
        out = struct('audio', buf, 't0', t0, 'overflow', ovf);
end
end
