function r = image_dest_rect(img, windowRect, sz)
% IMAGE_DEST_RECT  Screen rect for img, centred on the window.
%   sz = [width height] in px (p.image_size), or one number = height as a
%   fraction of the window height (aspect ratio kept; p.image_scale).
[h, w, ~] = size(img);
if numel(sz) == 2
    r = CenterRectOnPoint([0, 0, sz(1), sz(2)], windowRect(3) / 2, windowRect(4) / 2);
else
    s = sz * windowRect(4) / h;
    r = CenterRectOnPoint([0, 0, round(w * s), round(h * s)], windowRect(3) / 2, windowRect(4) / 2);
end
end
