function draw_word_diamond(window, windowRect, labels, white, p, chosen)
% DRAW_WORD_DIAMOND  The adjective response screen: prompt at the top and
% the words around the screen centre, where the image was, each at the
% position of its arrow key (p.adj_keys; 4 options: up, left, right, down;
% 2 options: left, right).
% A filled arrow head points from the centre towards each word.
% chosen (optional): index of the selected word, drawn in p.highlight_color.
if nargin < 6, chosen = 0; end
W = windowRect(3); H = windowRect(4);
cx = W / 2; cy = H / 2;
r   = p.arrow_dist * H;          % centre -> arrow tip
sz  = p.arrow_size * H;          % arrow length
gap = 0.4 * sz;                  % arrow -> word
key_dirs = struct('UpArrow', [0 -1], 'LeftArrow', [-1 0], 'RightArrow', [1 0], 'DownArrow', [0 1]);
dirs = cell2mat(cellfun(@(k) key_dirs.(k), p.adj_keys(:), 'UniformOutput', false));   % option k sits at its key

Screen('TextSize', window, p.text_size_prompt);
DrawFormattedText(window, p.adj_prompt, 'center', 0.12 * H, white);
draw_fixation_dot(window, windowRect, p);
% word size: p.text_size_words, smaller if a word would leave the screen
ts = p.text_size_words;
while ts > 10                                    % space from the arrow to the screen edge
    Screen('TextSize', window, ts);
    fits = true;
    for k = 1:numel(labels)
        b = Screen('TextBounds', window, strrep(labels{k}, '|', ''));
        if dirs(k, 1) ~= 0
            fits = fits && b(3) <= W / 2 - r - gap - 5 && b(4) <= H;
        else
            fits = fits && b(4) <= H / 2 - r - gap - 5 && b(3) <= W;
        end
    end
    if fits, break; end
    ts = floor(ts * 0.9);
end
for k = 1:numel(labels)
    color = white;
    if k == chosen, color = p.highlight_color; end
    d = dirs(k, :);
    % filled arrow head pointing outwards, tip at r from the centre
    tip  = [cx, cy] + d * r;
    base = [cx, cy] + d * (r - sz);
    side = [-d(2), d(1)] * sz * 0.6;
    Screen('FillPoly', window, white, [tip; base + side; base - side], 1);
    % word just beyond the arrow: its inner edge faces the arrow
    draw_word(window, labels{k}, [cx, cy] + d * (r + gap), d, color);
end
end

function draw_word(window, txt, xy, d, color)
% one or more lines (split at '|'); the block's edge nearest the centre sits at xy
lines = strsplit(txt, '|');
h = Screen('TextBounds', window, 'Xg'); lh = h(4);
w = 0;
for i = 1:numel(lines)
    b = Screen('TextBounds', window, lines{i}); w = max(w, b(3));
end
bh = numel(lines) * lh;
x0 = xy(1) - w / 2 + d(1) * w / 2;      % left/right: shift the block outwards
y0 = xy(2) - bh / 2 + d(2) * bh / 2;    % up/down: shift the block outwards
for i = 1:numel(lines)
    b = Screen('TextBounds', window, lines{i});
    Screen('DrawText', window, lines{i}, x0 + (w - b(3)) / 2, y0 + (i - 1) * lh, color);
end
end
