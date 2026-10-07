function draw_word_diamond(window, windowRect, labels, white, p, chosen)
% DRAW_WORD_DIAMOND  The adjective response screen: prompt at the top and
% the 4 words around the screen centre, where the image was, at the
% positions of the arrow keys: option 1 up, 2 left, 3 right, 4 down
% (p.adj_keys = {'UpArrow','LeftArrow','RightArrow','DownArrow'}).
% A filled arrow head points from the centre towards each word.
% chosen (optional): index of the selected word, drawn in p.highlight_color.
if nargin < 6, chosen = 0; end
W = windowRect(3); H = windowRect(4);
cx = W / 2; cy = H / 2;
r   = p.arrow_dist * H;          % centre -> arrow tip
sz  = p.arrow_size * H;          % arrow length
gap = 0.4 * sz;                  % arrow -> word
dirs = [0 -1; -1 0; 1 0; 0 1];   % up, left, right, down (= option 1..4)

Screen('TextSize', window, p.text_size_prompt);
DrawFormattedText(window, p.adj_prompt, 'center', 0.12 * H, white);
Screen('TextSize', window, p.text_size_words);
draw_fixation_dot(window, windowRect, p);
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
