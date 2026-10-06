function [seq, rep, n_violations] = make_session_order(group_of, min_reps, max_reps, min_gap, first_spread, spacing_floor)
% MAKE_SESSION_ORDER  Presentation order for a whole session.
%   [seq, rep] = make_session_order(group_of, min_reps, max_reps, min_gap, first_spread)
%   group_of     : 1 x n group (concept) id of every image
%   min_reps     : presentations every image gets within the first n*min_reps trials
%   max_reps     : total presentations planned per image (rounds after the minimum)
%   min_gap      : minimum number of trials between two presentations of one image
%   first_spread : 0..1, the first presentation of each image is spread over this
%                  fraction of the minimum part (0 = introduce as early as possible)
%   spacing_floor: 0..1, within the minimum part an image is not repeated sooner
%                  than spacing_floor * (n*min_reps/min_reps) trials (default 0.5),
%                  so early images are not repeated densely while others are
%                  still being introduced (wins over first_spread when they conflict)
%   seq          : 1 x n*max_reps image index per trial
%   rep          : 1 x n*max_reps presentation number of that image (1..max_reps)
%
% Constraints over the whole sequence: two presentations of one image are at
% least min_gap trials apart, and consecutive trials never share a group.
%
% Minimum part (trials 1..n*min_reps), filled trial by trial: a new image is
% introduced (its first presentation) while the number introduced so far is
% below the quota n*pos/(first_spread*n*min_reps), so first presentations are
% spread evenly over that fraction of the minimum part; otherwise the next
% presentation is the eligible repeat with the earliest target. After every
% placement an image's remaining presentations are re-spaced evenly over the
% trials left in the minimum part. Early trials are necessarily mostly first
% presentations (nothing has been seen yet and repeats need min_gap). Extra rounds (min_reps+1..max_reps): every image once per
% round, random order under the same constraints. Up to 500 restarts; the
% order with the fewest violations is kept (a warning reports any left).

if nargin < 6, spacing_floor = 0.5; end
n = numel(group_of);
best = []; best_rep = []; n_violations = Inf;
for attempt = 1:500
    [s, r, v] = one_attempt(group_of, n, min_reps, max_reps, min_gap, first_spread, spacing_floor);
    if v < n_violations
        best = s; best_rep = r; n_violations = v;
    end
    if v == 0, break; end
end
seq = best; rep = best_rep;
if n_violations > 0
    warning('make_session_order:violations', ...
        '%d gap/adjacency violations remain (min_gap = %d)', n_violations, min_gap);
end
end


function [seq, rep, viol] = one_attempt(group_of, n, min_reps, max_reps, min_gap, first_spread, spacing_floor)
N_min = n * min_reps;
seq = zeros(1, n * max_reps);
rep = zeros(1, n * max_reps);
last_pos = -Inf(1, n);
viol = 0;

%% minimum part: introduce images at the quota rate, re-space their repeats
span = max(1, first_spread * N_min);      % first presentations end by this trial
min_space = max(min_gap, round(spacing_floor * N_min / min_reps));   % repeat spacing floor
introduced = false(1, n);
remaining = min_reps * ones(1, n);        % presentations still to place per image
target = inf(1, n);                       % target trial of each image's next repeat
for pos = 1:N_min
    if first_spread > 0
        quota = min(n, ceil(n * pos / span));   % images that should be introduced by now
    else
        quota = n;                              % introduce as early as possible
    end
    prev_group = NaN;
    if pos > 1, prev_group = group_of(seq(pos - 1)); end
    is_new = ~introduced;
    is_rep = introduced & remaining > 0;
    group_ok = group_of ~= prev_group;
    gap_ok = (pos - last_pos) >= min_space;
    cand_new = find(is_new & group_ok);
    cand_rep = find(is_rep & group_ok & gap_ok);
    if sum(introduced) < quota && ~isempty(cand_new)
        pick = cand_new(randi(numel(cand_new)));
    elseif ~isempty(cand_rep)
        [~, j] = min(target(cand_rep) + rand(size(cand_rep)) * 1e-3);
        pick = cand_rep(j);
    elseif ~isempty(cand_new)
        pick = cand_new(randi(numel(cand_new)));
    else
        % nothing satisfies the spacing floor: fall back to min_gap, then relax
        cand = find(is_rep & group_ok & (pos - last_pos) >= min_gap);
        if isempty(cand)
            viol = viol + 1;
            cand = find(is_rep & group_ok);
        end
        if isempty(cand), cand = find(is_rep | is_new); end
        [~, j] = min(target(cand));
        pick = cand(j);
    end
    introduced(pick) = true;
    seq(pos) = pick; rep(pos) = min_reps - remaining(pick) + 1;
    remaining(pick) = remaining(pick) - 1;
    last_pos(pick) = pos;
    if remaining(pick) > 0                % spread the rest evenly over the trials left
        target(pick) = pos + (N_min - pos) / (remaining(pick) + 0.5);
    else
        target(pick) = inf;
    end
end

%% extra rounds: every image once per round
pos = N_min;
for r = min_reps + 1:max_reps
    pool = randperm(n);
    for t = 1:n
        pos = pos + 1;
        ok = (pos - last_pos(pool)) >= min_gap & group_of(pool) ~= group_of(seq(pos - 1));
        if any(ok)
            j = find(ok, 1);
        else
            viol = viol + 1;
            ok2 = group_of(pool) ~= group_of(seq(pos - 1));
            if any(ok2), j = find(ok2, 1); else, j = 1; end
        end
        pick = pool(j); pool(j) = [];
        seq(pos) = pick; rep(pos) = r; last_pos(pick) = pos;
    end
end
end
