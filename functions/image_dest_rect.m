function r = image_dest_rect(img, windowRect, scale)
% IMAGE_DEST_RECT  Screen rect for img: height = scale * window height,
% aspect ratio kept, centred on the window.
[h, w, ~] = size(img);
s = scale * windowRect(4) / h;
r = CenterRectOnPoint([0, 0, round(w * s), round(h * s)], windowRect(3) / 2, windowRect(4) / 2);
end
