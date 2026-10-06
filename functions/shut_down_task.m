function shut_down_task(EThndl, pa)
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
audio_close(pa);
ShowCursor;
Screen('CloseAll');
end
