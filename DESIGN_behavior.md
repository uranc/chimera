# Behavioral design (ptb/)

One session = three tasks on the same 4 concepts (`run_session.m`), each a separate run with its own
logs. Every trial: blank 0.2 s + uniform 0-0.2 s jitter -> fixation cross 0.3 s -> image (480x480 px,
photodiode patch 90x75 px top right while the image is on). The eye tracker is calibrated once, in task 1.

## Task 1 - chimera (`run_chimera_eye.m`, task code 2)
4 concepts x 8 axes x 2 levels (mid, max) = 64 generated images x 6 reps = 384 trials.
Image 1.5 s -> image off, two words left/right (2AFC: the manipulated axis's word + 1 other axis
word) until an arrow key; the chosen word is highlighted 0.3 s. No catch trials, no time limit.
- target side balanced per image; distractor = the least-used other axis word for that image
  (7 possible, 6 reps: not every distractor per image)
- repeats spaced in time, never the same concept twice in a row; short practice on other concepts
- words: SPoSE axes 1 metallic (künstlich), 2 food (essensähnlich), 3 animal (tierähnlich),
  5 plant (pflanzenähnlich), 12 colorful (bunt), 13 outdoors (draußen), 40 bug (insektenähnlich),
  54 toy (spielzeugähnlich)

## Task 2 - naming (`run_naming_eye.m`, task code 3)
Every max-level image once (32 trials). The image stays on; a soft beep 0.5 s after onset (sync
pulse at its onset) cues the spoken answer; Space / gamepad button ends the trial. One continuous
microphone recording per run (wav); voice onset estimated per trial.

## Task 3 - mini-screening (`run_miniscreening_eye.m`, task code 4)
dynamic's run_mini_screening: image until left (can be picked up with one hand) / right (not).
8 blocks; every block has each concept's original photo and written name, the 11 further THINGS
photos (instances 1-11) are spread over the blocks once each: original x8, name x8, exemplars x1
= 108 trials.

## Daq (functions/TaskCodes.m, protocol 5)
Single pulses as in dynamic: start of paradigm 1, block 2, session 3, fixation 4, trial start 16,
image on 22, eye 32, response 64, image off 65, trial end 80, question/beep 128.
Data trains follow a marker, one byte per pulse (value + 1), so the neural data alone identifies
every trial:
- session (3): task, patient, session, protocol version
- block (2): block number
- trial (16): task, patient, session, block, trial, image id, axis, SPoSE dim, concept,
  THINGS number (hi, lo), instance, level, rep, trial type, target position, options 1-4
- outcome (80): response, chosen axis, correct, rt (hi, lo, ms from image onset), voice onset (hi, lo)
Patient, session, block and trial numbers are sent mod 100.
