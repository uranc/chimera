function audio_close(pa)
% AUDIO_CLOSE  Release the microphone.
if isempty(pa), return; end
try
    PsychPortAudio('Close', pa);
catch ME
    warning('audio_close:failed', '%s', ME.message);
end
end
