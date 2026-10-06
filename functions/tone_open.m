function tone = tone_open(p)
% TONE_OPEN  Prepare the answer tone: a short, soft sine beep (p.tone_freq Hz,
% p.tone_dur s, 10 ms on/off ramps, p.tone_volume) on its own PsychPortAudio
% playback device. It tells the patient that it is time to answer and its
% measured onset is sent to the daq (question pulse) for synchronisation.
% Returns [] if p.use_tone is false or no playback device opens (the trial
% then runs silently and the pulse is sent at the planned time).
tone = [];
if ~p.use_tone, return; end
try
    InitializePsychSound(1);
    pah = PsychPortAudio('Open', p.tone_device, 1, 1, [], 2);
    s = PsychPortAudio('GetStatus', pah);
    fs = s.SampleRate;
    t = (0:round(p.tone_dur * fs) - 1) / fs;
    ramp = min(1, min(t, p.tone_dur - t) / 0.01);          % 10 ms raised edges
    y = p.tone_volume * sin(2 * pi * p.tone_freq * t) .* ramp;
    PsychPortAudio('FillBuffer', pah, [y; y]);
    tone = struct('pah', pah, 'fs', fs);
    fprintf('Answer tone ready: %d Hz, %.0f ms, volume %.2f.\n', p.tone_freq, p.tone_dur * 1000, p.tone_volume);
catch ME
    warning('tone_open:failed', 'No playback device for the answer tone (%s); trials run silently.', ME.message);
end
end
