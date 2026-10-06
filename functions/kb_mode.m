function m = kb_mode(new_mode)
% KB_MODE  How wait_for_keys reads the keyboard, set once per session.
%   'queue' (default, rig): KbQueue, as in run_mini_screening (precise times)
%   'poll'  (remote test) : KbCheck polling; works with keys injected over
%                           VNC, which a KbQueue does not see
%   kb_mode('poll') sets it; kb_mode() returns it.
persistent mode
if isempty(mode), mode = 'queue'; end
if nargin > 0, mode = new_mode; end
m = mode;
end
