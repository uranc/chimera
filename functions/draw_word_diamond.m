function draw_word_diamond(window, windowRect, labels, white, p, chosen)
% DRAW_WORD_DIAMOND  The adjective response screen: prompt at the top and
% the 4 words around the screen centre, where the image was, at the
% positions of the arrow keys: option 1 up, 2 left, 3 right, 4 down
% (p.adj_keys = {'UpArrow','LeftArrow','RightArrow','DownArrow'}).
% A small arrow mark sits between the centre and each word.
% chosen (optional): index of the selected word, drawn in p.highlight_color.
if nargin < 6, chosen = 0; end
W = windowRect(3); H = windowRect(4);
cx = W / 2; cy = H / 2;
dx = p.word_dx * W; dy = p.word_dy * H;
pos   = [cx, cy - dy; cx - dx, cy; cx + dx, cy; cx, cy + dy];
marks = {'^', '<', '>', 'v'};
mark_pos = [cx, cy - dy / 2; cx - dx / 2, cy; cx + dx / 2, cy; cx, cy + dy / 2];

Screen('TextSize', window, p.text_size_prompt);
DrawFormattedText(window, p.adj_prompt, 'center', 0.12 * H, white);
Screen('TextSize', window, p.text_size_words);
draw_fixation_dot(window, windowRect, p);
for k = 1:numel(labels)
    color = white;
    if k == chosen, color = p.highlight_color; end
    draw_centred(window, labels{k}, pos(k, :), color);
    draw_centred(window, marks{k}, mark_pos(k, :), white);
end
end

function draw_centred(window, txt, xy, color)
% one or more lines (split at '|' in the label), each centred on xy
lines = strsplit(txt, '|');
h = Screen('TextBounds', window, 'Xg');
y0 = xy(2) - numel(lines) * h(4) / 2;
for i = 1:numel(lines)
    b = Screen('TextBounds', window, lines{i});
    Screen('DrawText', window, lines{i}, xy(1) - b(3) / 2, y0 + (i - 1) * h(4), color);
end
end
