function r = photodiode_rect(windowRect, sz, corner)
% PHOTODIODE_RECT  Square of sz pixels in a corner of the window
% ('topleft', 'topright', 'bottomleft', 'bottomright').
W = windowRect(3); H = windowRect(4);
switch corner
    case 'topleft',     r = [0, 0, sz, sz];
    case 'topright',    r = [W - sz, 0, W, sz];
    case 'bottomleft',  r = [0, H - sz, sz, H];
    case 'bottomright', r = [W - sz, H - sz, W, H];
    otherwise, error('photodiode_rect:corner', 'unknown corner "%s"', corner);
end
end
