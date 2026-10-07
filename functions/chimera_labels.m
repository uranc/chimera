function label = chimera_labels(name)
% CHIMERA_LABELS  German on-screen word for a concept or axis token from the
% stimulus file names. Unknown tokens return the token itself;
% prep_chimera_trials warns about them before the session starts.
% Add the session's concepts and all 8 axis adjectives here. Keys are the
% names as in the file names: one block of text, no dashes (gokart, foodrelated).
% Axis words may be longer; '|' starts a new line on the response screen.
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
    map('gokart')   = 'Gokart';
    map('playpen')   = 'Laufstall';
    map('camel')     = 'Kamel';
    map('horse')     = 'Pferd';
    map('sandwich')  = 'Sandwich';
    map('guitar')    = 'Gitarre';
    map('umbrella')  = 'Regenschirm';
    map('helicopter') = 'Hubschrauber';
    map('shoe')      = 'Schuh';
    map('pretzel')   = 'Brezel';
    map('lantern')   = 'Laterne';
    map('wheelchair') = 'Rollstuhl';
    map('trumpet')   = 'Trompete';
    map('anchor')    = 'Anker';
    map('kite')      = 'Drachen';
    map('sword')     = 'Schwert';
    map('jellyfish') = 'Qualle';
    map('waffle')    = 'Waffel';
    map('telescope') = 'Teleskop';
    map('saddle')    = 'Sattel';
    map('airplane')  = 'Flugzeug';
    map('apple')     = 'Apfel';
    map('backpack')  = 'Rucksack';
    map('candle')    = 'Kerze';
    map('clock')     = 'Uhr';
    map('drum')      = 'Trommel';
    map('fork')      = 'Gabel';
    map('glove')     = 'Handschuh';
    map('hat')       = 'Hut';
    map('kettle')    = 'Wasserkocher';
    map('ladder')    = 'Leiter';
    map('microphone') = 'Mikrofon';
    map('necklace')  = 'Halskette';
    map('envelope')  = 'Briefumschlag';
    map('balloon')   = 'Luftballon';
    map('basket')    = 'Korb';
    map('bell')      = 'Glocke';
    map('bowl')      = 'Schüssel';
    map('broom')     = 'Besen';
    map('brush')     = 'Bürste';
    map('bucket')    = 'Eimer';
    map('calculator') = 'Taschenrechner';
    map('can')       = 'Dose';
    map('canoe')     = 'Kanu';
    map('cap')       = 'Mütze';
    map('carrot')    = 'Karotte';
    map('chain')     = 'Kette';
    map('chair')     = 'Stuhl';
    map('cheese')    = 'Käse';
    map('cherry')    = 'Kirsche';
    map('chocolate') = 'Schokolade';
    map('cigar')     = 'Zigarre';
    map('coin')      = 'Münze';
    map('comb')      = 'Kamm';
    map('compass')   = 'Kompass';
    map('cookie')    = 'Keks';
    map('corn')      = 'Mais';
    map('crab')      = 'Krabbe';
    map('crayon')    = 'Wachsmalstift';
    map('crown')     = 'Krone';
    map('cucumber')  = 'Gurke';
    map('cup')       = 'Tasse';
    map('doll')      = 'Puppe';
    map('domino')    = 'Dominostein';
    map('earring')   = 'Ohrring';
    map('egg')       = 'Ei';
    map('fan')       = 'Ventilator';
    map('feather')   = 'Feder';
    map('flag')      = 'Flagge';
    map('flashlight') = 'Taschenlampe';
    map('flute')     = 'Flöte';
    map('frog')      = 'Frosch';
    % axes (a<id>_<name>) as adjectives
    map('metallicartificial') = 'metallisch|künstlich';   % check
    map('foodrelated')        = 'Essen';   % check
    map('animalrelated')      = 'Tier';   % check
    map('plantrelated')       = 'Pflanze';   % check
    map('colorfulplayful')                 = 'bunt|verspielt';   % check
    map('outdoors')                         = 'draußen|Außenbereich';   % check
    map('bugrelatednonmammaliandisgusting') = 'Insekt, Kriechtier|eklig';   % check
    map('childtoyrelatedcute')              = 'Kind, Spielzeug|niedlich';   % check
end
if isKey(map, name)
    label = map(name);
else
    label = name;
end
end
