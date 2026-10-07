function r = photodiode_rect(windowRect, sz, corner)
% PHOTODIODE_RECT  Patch of sz pixels in a corner of the window: sz = [width height]
% (or one number for a square); corner 'topleft', 'topright', 'bottomleft', 'bottomright'.
W = windowRect(3); H = windowRect(4);
if isscalar(sz), sz = [sz sz]; end
w = sz(1); h = sz(2);
switch corner
    case 'topleft',     r = [0, 0, w, h];
    case 'topright',    r = [W - w, 0, W, h];
    case 'bottomleft',  r = [0, H - h, w, H];
    case 'bottomright', r = [W - w, H - h, W, H];
    otherwise, error('photodiode_rect:corner', 'unknown corner "%s"', corner);
end
end
