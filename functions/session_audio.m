function out = session_audio(cmd, varargin)
% SESSION_AUDIO  One continuous microphone recording for the whole session,
% streamed to a single 16-bit wav file (not chopped into trials).
%   session_audio('start', pa, fs, channels, wav_file)  start capture + file
%   session_audio('fetch')        move captured samples to disk (called from
%                                 every key wait, so no buffer overflow)
%   s = session_audio('since', t) samples recorded since GetSecs time t
%                                 (from a rolling 30 s buffer): s.audio, s.t0
%   info = session_audio('stop')  stop, close the file; info.file, info.fs,
%                                 info.channels, info.t_first_sample (GetSecs
%                                 time of sample 1), info.n_samples, info.overflow
%   tf = session_audio('active');  t = session_audio('t0')  (first-sample time)
% Any moment of the file maps to the trial time stamps:
%   sample index = round((t - t_first_sample) * fs) + 1
persistent S
out = [];
switch cmd
    case 'start'
        [pa, fs, ch, f] = varargin{:};
        S = struct('pa', pa, 'fs', fs, 'ch', ch, 'file', f, 'fid', fopen(f, 'w'), ...
            't0', NaN, 'n', 0, 'overflow', false, 'ring', zeros(ch, 0), 'ring_t0', NaN);
        write_header(S.fid, fs, ch, 0);
        PsychPortAudio('Start', pa, 0, 0, 1);
    case 't0'
        out = NaN;
        if ~isempty(S), out = S.t0; end
    case 'active'
        out = ~isempty(S) && isfield(S, 'fid') && S.fid > 0;
    case 'fetch'
        if isempty(S) || S.fid <= 0, return; end
        [a, ~, ovf, tcs] = PsychPortAudio('GetAudioData', S.pa);
        if isempty(a), return; end
        if isnan(S.t0), S.t0 = tcs; end
        S.overflow = S.overflow || logical(ovf);
        fwrite(S.fid, int16(max(-1, min(1, a(:))) * 32767), 'int16');
        S.n = S.n + size(a, 2);
        S.ring = [S.ring, a];
        keep = round(30 * S.fs);
        if size(S.ring, 2) > keep, S.ring = S.ring(:, end - keep + 1:end); end
        S.ring_t0 = S.t0 + (S.n - size(S.ring, 2)) / S.fs;
    case 'since'
        session_audio('fetch');
        out = struct('audio', [], 't0', NaN);
        if isempty(S) || isnan(S.ring_t0), return; end
        first = max(1, floor((varargin{1} - S.ring_t0) * S.fs) + 1);
        out.audio = S.ring(:, first:end);
        out.t0 = S.ring_t0 + (first - 1) / S.fs;
    case 'stop'
        if isempty(S) || S.fid <= 0, return; end
        PsychPortAudio('Stop', S.pa);
        session_audio('fetch');
        write_header(S.fid, S.fs, S.ch, S.n);       % patch the sizes
        fclose(S.fid);
        out = struct('file', S.file, 'fs', S.fs, 'channels', S.ch, 't_first_sample', S.t0, ...
            'n_samples', S.n, 'overflow', S.overflow);
        S.fid = -1;
end
end

function write_header(fid, fs, ch, n)
% 44-byte PCM wav header; called again at the end with the final size
data_bytes = n * ch * 2;
frewind(fid);
fwrite(fid, 'RIFF', 'char'); fwrite(fid, 36 + data_bytes, 'uint32');
fwrite(fid, 'WAVEfmt ', 'char'); fwrite(fid, 16, 'uint32');
fwrite(fid, 1, 'uint16'); fwrite(fid, ch, 'uint16'); fwrite(fid, fs, 'uint32');
fwrite(fid, fs * ch * 2, 'uint32'); fwrite(fid, ch * 2, 'uint16'); fwrite(fid, 16, 'uint16');
fwrite(fid, 'data', 'char'); fwrite(fid, data_bytes, 'uint32');
fseek(fid, 0, 'eof');
end
