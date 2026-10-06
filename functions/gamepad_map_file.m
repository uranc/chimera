function f = gamepad_map_file()
% GAMEPAD_MAP_FILE  Where calibrate_gamepad saves the mapping (setup/).
f = fullfile(fileparts(fileparts(mfilename('fullpath'))), 'setup', 'gamepad_map.mat');
end
