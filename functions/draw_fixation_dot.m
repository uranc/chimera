function draw_fixation_dot(window, windowRect, p)
% DRAW_FIXATION_DOT  Small fixation point at the screen centre, drawn on top
% of the image and on the response screen (p.fixation_dot = true), so the
% patient always has a point to fixate. Black rim for contrast on any image.
if ~isfield(p, 'fixation_dot') || ~p.fixation_dot, return; end
c = [windowRect(3) / 2, windowRect(4) / 2];
Screen('DrawDots', window, c', p.fixation_dot_size + 4, [0 0 0], [], 2);
Screen('DrawDots', window, c', p.fixation_dot_size, p.fixation_dot_color, [], 2);
end
