function draw_word_diamond(window, windowRect, labels, white, p)
% DRAW_WORD_DIAMOND  The adjective response screen: prompt at the top and
% the 4 words around the screen centre, where the image was, at the
% positions of the arrow keys: option 1 up, 2 left, 3 right, 4 down
% (p.adj_keys = {'UpArrow','LeftArrow','RightArrow','DownArrow'}).
% A small arrow mark sits between the centre and each word.
W = windowRect(3); H = windowRect(4);
cx = W / 2; cy = H / 2;
dx = p.word_dx * W; dy = p.word_dy * H;
pos   = [cx, cy - dy; cx - dx, cy; cx + dx, cy; cx, cy + dy];
marks = {'^', '<', '>', 'v'};
mark_pos = [cx, cy - dy / 2; cx - dx / 2, cy; cx + dx / 2, cy; cx, cy + dy / 2];

Screen('TextSize', window, p.text_size_prompt);
DrawFormattedText(window, p.adj_prompt, 'center', 0.12 * H, white);
Screen('TextSize', window, p.text_size_words);
for k = 1:numel(labels)
    draw_centred(window, labels{k}, pos(k, :), white);
    draw_centred(window, marks{k}, mark_pos(k, :), white);
end
end

function draw_centred(window, txt, xy, color)
b = Screen('TextBounds', window, txt);
Screen('DrawText', window, txt, xy(1) - b(3) / 2, xy(2) - b(4) / 2, color);
end
