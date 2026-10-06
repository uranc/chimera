function t_onset = tone_play(tone, when)
% TONE_PLAY  Play the answer tone at GetSecs time `when` and return the
% estimated onset (PsychPortAudio start time). Without a tone device:
% waits until `when` and returns GetSecs.
if isempty(tone)
    WaitSecs('UntilTime', when);
    t_onset = GetSecs;
    return
end
t_onset = PsychPortAudio('Start', tone.pah, 1, when, 1);
end
