function [down, t, key_code] = check_keys()
% CHECK_KEYS  KbCheck with the gamepad merged in (gamepad_keys), for loops
% that poll the keyboard directly (steering screens).
[down, t, key_code] = KbCheck;
pad = gamepad_keys();
key_code = logical(key_code) | pad;
down = any(key_code);
end
