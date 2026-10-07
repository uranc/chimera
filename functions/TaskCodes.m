classdef TaskCodes
% TASKCODES  Single source of truth for the daq protocol of the ptb tasks
% (task codes, event codes, data-train layouts, encoding and decoding).
% Used by the run scripts, the plan builders, the trial helpers, and by the
% analysis to decode the recorded digital channel.
%
% WIRE FORMAT
%   daqOut (dynamic/functions/daqOut.m) writes a byte and then 0, so every
%   call is one short pulse, and a byte of 0 produces NO pulse at all.
%   - Event pulses are sent as their raw code (EVENTS).
%   - Data trains are a marker pulse (an EVENTS code) followed by a fixed
%     number of data bytes, TRAIN_GAP s apart. Every data byte is sent as
%     value + 1, so values 0..254 map to 1..255 and no byte is invisible.
%     Data bytes may coincide with event codes; a decoder knows how many
%     bytes follow each marker (see parse_stream), so this is unambiguous.
%   - patient/session/block/trial ids are sent mod ID_MOD; axis and concept
%     are the indices within the stimulus set (SPoSE dim / THINGS number are in
%     the file names and the saved cfg); reaction times (ms) as two
%     base-RT_BASE digits (hi, lo).
%
% SEQUENCE ON THE DIGITAL CHANNEL
%   session : eye (gaze on, if eye tracking)  session_start + TRAIN_SESSION
%             start_of_paradigm (instructions on), response (instructions off)
%   block   : start_of_block + TRAIN_BLOCK  (a block = segment between pauses)
%   trial   : trial_start + TRAIN_TRIAL, fix_cross, img_on, [img_off],
%             question, [response], [img_off], trial_end + TRAIN_OUTCOME
%             adjective/catch: img_on, img_off+question (same flip), response
%             naming         : img_on, question (prompt), response, img_off
%             liftable (spose): img_on, response, img_off
%   end     : eye (gaze off, if eye tracking)
% Every pulse and train is mirrored as a Tobii message "<code>_<label>".

    properties (Constant)
        PROTOCOL_VERSION = 4;   % 4: axis/concept = indices within the stimulus set (1 byte each)

        % task ("stim class") codes
        TASKS = struct('spose', 1, 'chimera', 2, 'naming', 3, 'miniscreening', 4);

        % event codes. 1, 2, 4, 32, 64, 128 as in run_dynamic_eye; 22 and 65 as
        % in run_mini_screening; 3, 16 and 80 are markers that are followed by
        % a data train (16 means "frame" in run_dynamic_eye, a different task).
        EVENTS = struct( ...
            'start_of_paradigm',   1, ...   % 00000001 instruction screen on
            'start_of_block',      2, ...   % 00000010 + TRAIN_BLOCK
            'session_start',       3, ...   % 00000011 + TRAIN_SESSION
            'fix_cross',           4, ...   % 00000100 fixation cross onset
            'trial_start',        16, ...   % 00010000 + TRAIN_TRIAL
            'img_on',             22, ...   % 00010110 image onset
            'eye',                32, ...   % 00100000 Tobii gaze on / off
            'response',           64, ...   % 01000000 key press
            'img_off',            65, ...   % 01000001 image offset
            'trial_end',          80, ...   % 01010000 + TRAIN_OUTCOME
            'question',          128);      % 10000000 response options / prompt on

        % trial types (sent in TRAIN_TRIAL)
        TRIAL_TYPES = struct('adjective', 1, 'catch', 2, 'naming', 3, 'liftable', 4, ...
            'original', 5, 'name', 6, 'exemplar', 7);   % 5..7: mini-screening (one-hand question)

        % correctness codes (sent in TRAIN_OUTCOME)
        CORRECT = struct('wrong', 0, 'right', 1, 'not_applicable', 2);

        TRAIN_GAP = 0.01;   % s between the bytes of a train
        ID_MOD    = 100;    % patient, session, block, trial ids are sent mod ID_MOD
        RT_BASE   = 250;    % times in ms are split into two base-250 digits

        % data-train layouts (logical values, in order; each sent as value+1)
        TRAIN_SESSION = {'task_type', 'patient_id', 'session_nr', 'protocol_version'};
        TRAIN_BLOCK   = {'block_id'};
        TRAIN_TRIAL   = {'task_type', 'patient_id', 'session_nr', 'block_id', 'trial_id', ...
                         'axis_id', 'concept_id', 'inst_id', 'level_id', 'rep_id', ...
                         'trial_type', 'target_pos', 'option_1', 'option_2', 'option_3', 'option_4'};
        TRAIN_OUTCOME = {'response', 'chosen_axis_id', 'correct', 'rt_hi', 'rt_lo', 'voice_hi', 'voice_lo'};
    end

    methods (Static)
        function v = task(name)
            v = TaskCodes.TASKS.(name);
        end

        function name = trial_type_name(code)
            fn = fieldnames(TaskCodes.TRIAL_TYPES);
            for k = 1:numel(fn)
                if TaskCodes.TRIAL_TYPES.(fn{k}) == code, name = fn{k}; return; end
            end
            error('TaskCodes:unknownTrialType', 'unknown trial type code %d', code);
        end

        %% building trains (logical values; send_train adds the +1)
        function values = session_train(task_type, patient_id, session_nr)
            m = TaskCodes.ID_MOD;
            values = [task_type, mod(patient_id, m), mod(session_nr, m), TaskCodes.PROTOCOL_VERSION];
            TaskCodes.check_values(values, 'session');
        end

        function values = block_train(block_id)
            values = mod(block_id, TaskCodes.ID_MOD);
            TaskCodes.check_values(values, 'block');
        end

        function values = trial_train(cfg)
            % cfg: one trial from prep_*_trials (task_type, patient_id, session_nr,
            % block_id, trial_id, axis_id, concept_id, inst_id, level_id, rep_id,
            % trial_type, target_pos, option_axis_ids)
            m = TaskCodes.ID_MOD;
            opts = zeros(1, 4);
            opts(1:numel(cfg.option_axis_ids)) = cfg.option_axis_ids;
            values = [cfg.task_type, mod(cfg.patient_id, m), mod(cfg.session_nr, m), ...
                      mod(cfg.block_id, m), mod(cfg.trial_id, m), ...
                      cfg.axis_id, cfg.concept_id, cfg.inst_id, cfg.level_id, cfg.rep_id, ...
                      cfg.trial_type, cfg.target_pos, opts];
            TaskCodes.check_values(values, 'trial');
        end

        function values = outcome_train(response, chosen_axis_id, correct, rt, voice_onset)
            % response: key index (0 = none / timeout); chosen_axis_id: axis id of
            % the chosen word (0 = not applicable); correct: TaskCodes.CORRECT code;
            % rt, voice_onset: s from image onset (NaN -> 0 = not available)
            [rt_hi, rt_lo] = TaskCodes.split_ms(rt);
            [vo_hi, vo_lo] = TaskCodes.split_ms(voice_onset);
            values = [TaskCodes.nan0(response), TaskCodes.nan0(chosen_axis_id), correct, ...
                      rt_hi, rt_lo, vo_hi, vo_lo];
            TaskCodes.check_values(values, 'outcome');
        end

        %% wire encoding
        function wire = encode(values)
            TaskCodes.check_values(values, 'encode');
            wire = values + 1;
        end

        function values = decode_bytes(wire)
            values = wire - 1;
        end

        function s = decode(wire, which)
            % s = TaskCodes.decode(recorded_bytes, 'trial'|'session'|'block'|'outcome')
            % recorded_bytes = the data bytes as seen on the wire (value + 1).
            layout = TaskCodes.(['TRAIN_' upper(which)]);
            if numel(wire) ~= numel(layout)
                error('TaskCodes:decode', '%s train needs %d bytes, got %d', which, numel(layout), numel(wire));
            end
            values = TaskCodes.decode_bytes(wire);
            s = struct();
            for k = 1:numel(layout)
                s.(layout{k}) = values(k);
            end
            % recombine split times (ms); 0 means "not available"
            if isfield(s, 'rt_hi'),    s.rt_ms    = s.rt_hi    * TaskCodes.RT_BASE + s.rt_lo;    end
            if isfield(s, 'voice_hi'), s.voice_ms = s.voice_hi * TaskCodes.RT_BASE + s.voice_lo; end
            if isfield(s, 'concept_hi'), s.concept_id = s.concept_hi * TaskCodes.RT_BASE + s.concept_lo; end
        end

        function ev = parse_stream(codes, times)
            % ev = TaskCodes.parse_stream(codes, times)
            % codes: vector of every byte recorded on the digital channel (wire
            % values, in order); times: their time stamps. Returns a struct array
            % with fields kind ('event' | 'session' | 'block' | 'trial' | 'outcome'),
            % code, time, and data (decoded train struct, or [] for events).
            if nargin < 2, times = nan(size(codes)); end
            E = TaskCodes.EVENTS;
            train_of = containers.Map('KeyType', 'double', 'ValueType', 'any');
            train_of(E.session_start) = 'session';
            train_of(E.start_of_block) = 'block';
            train_of(E.trial_start) = 'trial';
            train_of(E.trial_end) = 'outcome';
            ev = struct('kind', {}, 'code', {}, 'time', {}, 'data', {});
            k = 1;
            while k <= numel(codes)
                c = codes(k);
                if isKey(train_of, c)
                    which = train_of(c);
                    n = numel(TaskCodes.(['TRAIN_' upper(which)]));
                    if k + n > numel(codes)
                        warning('TaskCodes:truncated', 'truncated %s train at byte %d', which, k);
                        break
                    end
                    ev(end+1) = struct('kind', which, 'code', c, 'time', times(k), ...
                        'data', TaskCodes.decode(codes(k+1:k+n), which)); %#ok<AGROW>
                    k = k + n + 1;
                else
                    ev(end+1) = struct('kind', 'event', 'code', c, 'time', times(k), 'data', []); %#ok<AGROW>
                    k = k + 1;
                end
            end
        end

        function s = snapshot()
            % the protocol definition, saved with every session
            s = struct('version', TaskCodes.PROTOCOL_VERSION, 'events', TaskCodes.EVENTS, ...
                'trial_types', TaskCodes.TRIAL_TYPES, 'correct', TaskCodes.CORRECT, ...
                'train_gap', TaskCodes.TRAIN_GAP, 'id_mod', TaskCodes.ID_MOD, 'rt_base', TaskCodes.RT_BASE, ...
                'train_session', {TaskCodes.TRAIN_SESSION}, 'train_block', {TaskCodes.TRAIN_BLOCK}, ...
                'train_trial', {TaskCodes.TRAIN_TRIAL}, 'train_outcome', {TaskCodes.TRAIN_OUTCOME}, ...
                'wire', 'event codes raw; data bytes sent as value + 1 after their marker');
        end

        %% helpers
        function check_values(values, label)
            if any(~isfinite(values) | values < 0 | values > 254 | values ~= round(values))
                error('TaskCodes:range', '%s train value outside 0..254: %s', label, mat2str(values));
            end
        end

        function [hi, lo] = split_ms(t)
            if isnan(t) || t < 0
                hi = 0; lo = 0; return
            end
            ms = min(round(t * 1000), TaskCodes.RT_BASE^2 - 1);
            hi = floor(ms / TaskCodes.RT_BASE);
            lo = mod(ms, TaskCodes.RT_BASE);
        end

        function [hi, lo] = split_id(v)
            % ids above one byte (THINGS concept numbers) as two base-RT_BASE digits
            hi = floor(v / TaskCodes.RT_BASE);
            lo = mod(v, TaskCodes.RT_BASE);
        end

        function v = nan0(v)
            if isnan(v), v = 0; end
        end
    end
end
