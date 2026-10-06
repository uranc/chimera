function ts_daq = send_event(hw, code, label, ts_screen)
% SEND_EVENT  One event pulse on the daq plus its Tobii message, as done
% inline throughout run_dynamic_eye / run_mini_screening:
%     ts_daq = daqOut(daq, code);  EThndl.sendMessage("<code>_<label>", ts)
% ts_screen: time stamp for the Tobii message (normally the flip time of the
% screen change); default = the daq time stamp.
ts_daq = daqOut(hw.daq, code);
if ~isempty(hw.EThndl)
    if nargin < 4 || isempty(ts_screen) || isnan(ts_screen), ts_screen = ts_daq; end
    hw.EThndl.sendMessage(sprintf("%i_%s", code, label), ts_screen);
end
end
