function onset = detect_voice_onset(audio, fs, t_capture_start, t_ref, threshold)
% DETECT_VOICE_ONSET  Rough online voice-onset estimate: first 10 ms frame
% after t_ref whose peak amplitude reaches threshold. Returns s after t_ref
% (NaN if none). The offline analysis should recompute onsets from the wav.
onset = NaN;
if isempty(audio) || isnan(t_capture_start), return; end
x = max(abs(audio), [], 1);
frame = max(1, round(0.01 * fs));
n_frames = floor(numel(x) / frame);
if n_frames == 0, return; end
peak = max(reshape(x(1:n_frames * frame), frame, n_frames), [], 1);
first = max(1, floor((t_ref - t_capture_start) * fs / frame) + 1);
idx = find(peak(first:end) >= threshold, 1);
if ~isempty(idx)
    onset = t_capture_start + (first + idx - 2) * frame / fs - t_ref;
end
end
