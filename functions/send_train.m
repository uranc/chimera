function ts_marker = send_train(hw, marker, values, label)
% SEND_TRAIN  Marker pulse followed by a data train (see TaskCodes.m):
% every value is sent as value + 1, TaskCodes.TRAIN_GAP s apart, so that no
% byte is 0 (daqOut sends no pulse for 0). One Tobii message carries the
% marker code, the label and the values: "<marker>_<label>_v1-v2-...".
% Returns the daq time stamp of the marker.
wire = TaskCodes.encode(values);
gap = TaskCodes.TRAIN_GAP;
ts_marker = daqOut(hw.daq, marker);
for k = 1:numel(wire)
    WaitSecs(gap);
    daqOut(hw.daq, wire(k));
end
if ~isempty(hw.EThndl)
    hw.EThndl.sendMessage(sprintf("%i_%s_%s", marker, label, strjoin(string(values), '-')), ts_marker);
end
end
