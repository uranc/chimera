function tone_close(tone)
% TONE_CLOSE  Release the answer tone device.
if isempty(tone), return; end
try
    PsychPortAudio('Close', tone.pah);
catch ME
    warning('tone_close:failed', '%s', ME.message);
end
end
