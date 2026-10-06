function label = chimera_labels(name)
% CHIMERA_LABELS  German on-screen word for a concept or axis token from the
% stimulus file names. Unknown tokens return the token itself;
% prep_chimera_trials warns about them before the session starts.
% Add the session's concepts and all 8 axis adjectives here.
persistent map
if isempty(map)
    map = containers.Map();
    % concepts (c<id>_<name>)
    map('lipstick')  = 'Lippenstift';
    map('hamburger') = 'Hamburger';
    map('onion')     = 'Zwiebel';
    map('banana')    = 'Banane';
    map('teapot')    = 'Teekanne';
    map('owl')       = 'Eule';
    map('cactus')    = 'Kaktus';
    map('snail')     = 'Schnecke';
    map('peacock')   = 'Pfau';
    map('pineapple') = 'Ananas';
    % axes (a<id>_<name>) as adjectives
    map('metallic-artificial') = 'metallisch';
    map('food-related')        = 'essbar';
    map('animal-related')      = 'tierisch';
    map('plant-related')       = 'pflanzlich';
end
if isKey(map, name)
    label = map(name);
else
    label = name;
end
end
