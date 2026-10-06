function [audio, t_capture_start, overflow] = audio_stop(pa)
% AUDIO_STOP  Stop recording and fetch the samples.
%   audio           : channels x samples
%   t_capture_start : GetSecs time of the first sample
%   overflow        : true if the buffer overflowed (samples lost)
audio = []; t_capture_start = NaN; overflow = NaN;
if isempty(pa), return; end
PsychPortAudio('Stop', pa);
[audio, ~, overflow, t_capture_start] = PsychPortAudio('GetAudioData', pa);
end
