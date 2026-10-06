function [pa, fs] = audio_open(p)
% AUDIO_OPEN  Open the microphone for the naming trials (PsychPortAudio
% capture, as in BasicSoundInputDemo) and allocate the recording buffer.
% Returns pa = [] if p.use_microphone is false or the device cannot be
% opened; the experimenter then confirms that naming trials run unrecorded.
pa = []; fs = NaN;
if ~p.use_microphone, return; end
try
    InitializePsychSound(1);
    pa = PsychPortAudio('Open', p.mic_device, 2, 1, [], p.mic_channels);
    s = PsychPortAudio('GetStatus', pa);
    fs = s.SampleRate;
    PsychPortAudio('GetAudioData', pa, p.audio_buffer_secs);
    fprintf('Microphone open: %d Hz, %d channel(s).\n', fs, p.mic_channels);
catch ME
    pa = []; fs = NaN;
    warning('audio_open:failed', 'Microphone could not be opened: %s', ME.message);
    input('Naming trials will NOT be recorded. ENTER = continue, Ctrl+C = abort... ', 's');
end
end
