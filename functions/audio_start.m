function audio_start(pa)
% AUDIO_START  Start recording (until audio_stop); no-op without a microphone.
if isempty(pa), return; end
PsychPortAudio('Start', pa, 0, 0, 1);
end
