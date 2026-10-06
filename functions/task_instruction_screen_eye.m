function [ts_instructOn_daq, ts_instructOff_daq] = task_instruction_screen_eye(window, white, txt, ...
                                daq, daq_start_of_paradigm, daq_response, ...
                                EThndl)
% TASK_INSTRUCTION_SCREEN_EYE  instruction_screen_eye (dynamic) with the
% instruction text as an argument: shows txt, start_of_paradigm pulse,
% waits for Space (KbQueue), response pulse; both mirrored to the Tobii.

HideCursor;

Screen('TextSize', window, 30);
DrawFormattedText(window, txt, 'center', 'center', white);

ts_instructOn = Screen('Flip', window);
ts_instructOn_daq = daqOut(daq, daq_start_of_paradigm);

if ~isempty(EThndl)
    msg = sprintf("%i_instructions_on", daq_start_of_paradigm);
    EThndl.sendMessage(msg, ts_instructOn);
end

wait_for_keys({'Space'}, 'F10', Inf);    % KbQueue on Space, as instruction_screen_eye

ts_instructOff_daq = daqOut(daq, daq_response);

if ~isempty(EThndl)
    msg = sprintf("%i_instructions_off", daq_response);
    EThndl.sendMessage(msg, GetSecs);
end

end
