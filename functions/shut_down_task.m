function shut_down_task(EThndl, pa, tone)
% SHUT_DOWN_TASK  Release Tobii, microphone, cursor and screen (end of
% run_dynamic_eye, plus the microphone and ShowCursor). Safe to call after
% an error.
if ~isempty(EThndl)
    try
        EThndl.deInit();
    catch ME
        warning('shut_down_task:deInit', '%s', ME.message);
    end
end
if session_audio('active'), session_audio('stop'); end   % closes the wav cleanly after an error too
audio_close(pa);
if nargin >= 3, tone_close(tone); end
ShowCursor;
Screen('CloseAll');
end
