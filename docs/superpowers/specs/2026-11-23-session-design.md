# Recording session design: first look, main block, odd-one-out

Date: 2026-11-23. Replaces the chimera 2AFC / naming / mini-screening session
(`DESIGN_behavior.md`, `run_session.m`).

## Intent

Separate visual from semantic coding in human MTL neurons, using generated
images that are meant to look similar to a photo but mean something different.
About 30 minutes of recording per session must give (a) neural responses that
can be fitted with a visual model and a semantic model, and (b) behaviour that
says what the patient actually perceived.

The scientific test (PI, 2026-11-23): essentially a test of Cao et al. 2025,
pure semantic coding versus visual feature tuning in MTL neurons.

Decisions by the PI that this design follows:
- Only the edge cases are shown: the original photo and the max-steered image
  per object and axis. Intermediate levels belong to the later steering
  experiment.
- The free spoken report must capture what the patient perceives **before
  seeing any words**.
- The 2AFC on axis words is dropped: it is neither a perceptual-similarity nor
  an odd-one-out measure, so it does not connect to the models being tested.
- Odd-one-out triplets, 32 steered images x 2, are feasible.
- The key behavioural control is the dissociation itself: the patient names a
  steered image as something semantically different, yet judges it
  perceptually similar to the original.

## Goals

- Every image type (steered, original, written name, other photos) is recorded
  under the same task and the same timing, so responses can be compared and
  pooled.
- No axis word is ever shown or spoken to the patient, in any task or
  instruction.
- The first exposure to each steered image yields a free spoken report.
- At least 6 presentations per core image (lab response criterion).
- Behaviour in the same currency as SPoSE (odd-one-out choices), so
  predictions can be fixed before the session.
- The neural recording alone identifies every trial (daq trains, as now).

## Non-goals

- Intermediate steering levels.
- The 2AFC word task (code stays in the repo, not in the session).
- A low-level visual control condition (images with a matched colour/texture
  change but no change in meaning). Raised, not decided; see Open points.
- Matching the judgement format of the PI's PS model exactly. The perceptual
  pass below uses the triplet format; see Open points.

## Anti-goals

- Speech inside the neural analysis window.
- A task whose question changes from trial to trial during recording.
- Any step that teaches the patient which dimensions were manipulated.

## Constraints

- Rig: Windows, Psychtoolbox, daq + Tobii as in the current tasks; the
  dynamic repo's helpers; gamepad or keyboard.
- 4 objects per session, chosen from the screening session; 8 SPoSE axes by
  default (1, 2, 3, 5, 12, 13, 40, 54), more possible; instance 0.
- Existing stimulus folders and file naming stay valid.

## Evidence used

From a literature pass on 2026-11-20 to 23 (three research agents). Items
marked (full text) were opened in full; the others rest on abstracts or search
summaries and should be checked before being cited.

- Task shapes MTL responses: relational responses in concept neurons appeared
  only under a semantic comparison task (Bausch et al. 2021, Nat Commun; full
  text).
- Screening convention: 1 s images, 6 or more presentations, one constant
  simple question, e.g. "liftable?" (Karkowski et al. 2025 preprint; Quian
  Quiroga et al. 2005, Nature; Reber et al. 2019, PLoS Biol; full text).
- MTL neurons respond to a concept across pictures and written names (Quian
  Quiroga et al. 2009, Curr Biol; abstract).
- Offered labels can shift perception and categorisation (Lupyan and
  colleagues 2010 to 2012; Tskhay & Rule 2015; abstracts). No study of a closed
  word set biasing later free naming of hybrid images was found.
- Forced choice gives more categorical results than free naming on morphed
  objects (Hartendorp et al. 2010, Visual Cognition; abstract).
- Picture-naming priming lasts days to weeks (Cave & Squire 1992; Cave 1997;
  abstracts), so a free report is only independent at first exposure.
- Speech can contaminate recordings acoustically (Roussel et al. 2020
  preprint; full text). No MTL single-unit naming study was found.
- Mid-level visual statistics alone can reproduce apparent semantic
  organisation (Long, Yu & Konkle 2018, PNAS; abstract): the reason a visual
  control is listed as an open point.

## Approaches considered

- **A. Keep three blocks, reorder** (naming, 2AFC, mini-screening). Smallest
  change, but steered images and originals are seen under different tasks and
  the main data is recorded under the word task.
- **B. Merged trial**: same image epoch every trial; first presentation ends
  in a spoken answer, later ones in two words. Poolable, but about 190 word
  trials still run during recording.
- **C. One main block with behaviour around it** (chosen). Free report first,
  then all image types under one constant question, then behaviour that needs
  no words. After the PI dropped the 2AFC, its place in C is taken by
  odd-one-out triplets.

## The session

Order: first look, main block, mini-screening, triplets (looks pass, then
odd-one-out pass), steering. About 40 minutes of trials. Eye tracker calibrated once,
before the first look.

The originals, written names and other photos are not shown until the
mini-screening (PI, 2026-11-23), so nothing labels the steered images while
they are named and recorded.

Common trial start, unchanged: blank 0.2 s plus 0 to 0.2 s jitter (trial
train sent here), fixation cross 0.3 s, then the image at 480 x 480 px with
the photodiode patch.

Parts 1 and 2 are one run with two phases (PI, 2026-11-23): one start, one
instruction screen between the phases, one set of log files. They are not
interleaved: the naming phase has a spoken interval and is paced by the
patient, and every free report must come before any repeat of that image.
Presentation 1 (naming phase) is tagged in the data so fits can be run with
and without it.

### Part 1: first look (about 4 to 6 min, paced by the patient)

- Images: the 32 steered images, each once. 32 trials.
- Trial: image on; a soft beep 1.0 s after onset is the cue to speak; the
  image stays on; Space or a gamepad button ends the trial. No time limit.
- Instruction: say aloud what you see. No example that names a property.
- One continuous microphone recording, as in the current naming task.
- Order: random, never the same object twice in a row.
- The first 1.0 s of each trial is speech-free and counts as one presentation
  of that image for the neural data.
- Practice: 2 images of other objects.

### Part 2: main block (about 9 min)

- Task: repeat detection (one-back), as in Cao et al. 2025. The patient
  presses a key when an image is the same as the one just before. No
  judgement about meaning. About 10% extra trials are immediate repeats;
  they are not counted as presentations.
- Images form a 2 x 2 relative to each object's original (PI, 2026-11-23):

  |                         | semantically similar      | semantically dissimilar |
  |-------------------------|---------------------------|-------------------------|
  | perceptually similar    | the original (part 3)     | steered edge image      |
  | perceptually dissimilar | other photo of the object | other session objects   |

- 32 steered images and 16 other photos (4 per object), 6 presentations
  each: 288 trials plus about 29 repeat trials, in 6 blocks; every image once
  per block, random order, never the same object twice in a row except for
  the repeat trials.
- The 4 other photos per object are the ones the PI's PS model rates least
  similar to the original (instance 0), among instances 1 to 11.
- Trial: image on for exactly 1.0 s, then the usual blank and fixation. A key
  press is accepted until the next image.
- With part 1, every steered image has 7 presentations.

### Part 3: mini-screening (about 4 min)

- Same task and timing as the main block.
- Per object: original photo x 8, written name x 8, the remaining 7 other
  photos once each. 92 trials.
- Bridge trials: every steered image once more, spread over the blocks. 32
  trials. Originals are only ever recorded after the steered images, so a
  slow drift in firing over the session would look like a steered-versus-
  original difference; the bridge trials measure that drift.
- 124 trials plus about 12 repeat trials, in 8 blocks.
- This departs from the lab's mini-screening, which uses the one-hand
  question with the image on until the key press.

### Part 4: triplets, two passes (about 14 min)

The same 72 triplets are judged twice, with different instructions:

- **Looks pass (first):** "which picture looks most different from the other
  two?" This is the perceptual-similarity judgement. A steered image that is
  perceptually close to its original leaves the third image as the odd one.
- **Odd-one-out pass (second):** the standard instruction, "which one fits
  least with the other two?", as in THINGS.

The dissociation the study is after shows up when the patient named the
steered image as something else at first look, picks the partner object in
the looks pass, and picks the original in the odd-one-out pass. The looks pass runs
first so the meaning judgement cannot colour it.


- Three images side by side; the patient picks one (left, down, right key).
  No time limit. Images at 360 px.
- Three triplet types run side by side (PI, 2026-11-23):
  - **Axis-driven, 64:** a real member of the axis category, the steered
    image, and its own original. Example: real food, food-like boot, original
    boot. Two different real photos per steered image. Category pairs the
    steered image with the real food; appearance pairs it with its original.
    Real photos: for each axis, THINGS objects loading highest on that SPoSE
    dimension, excluding session and practice objects; 4 per axis, the same
    for every patient.
  - **Same-axis partner, 32:** the steered image, its own original, and the
    steered image of another object on the same axis. Example: food-like
    boot, original boot, food-like battery. Once per steered image.
  - **Fixed conflict, 8:** THINGS photos of objects outside the session, the
    same for every patient, chosen once and frozen: 6 where the semantic
    model (SPoSE) and the PI's PS model predict a different odd one, 2 where
    they agree. They show whether a patient separates the two instructions,
    on common ground across patients. A triplet containing one of a patient's
    session objects is flagged.
- The issue all three address is categorical versus visual perceptual
  similarity.
- 104 trials per pass, a new random order in each pass; consecutive trials
  never share an object; the screen position of each role is balanced.
- Before the session, the SPoSE-predicted choice probabilities for every
  triplet are computed in `setup/make_stimset.py` and saved with the stimset.
  Originals and other photos use their object's row of the 66-d SPoSE matrix
  (`THINGS-database/behavior/variables/spose_embedding_66d_sorted.txt`). A
  steered image has no row of its own: its vector is the image-to-SPoSE
  readout the generation pipeline already uses (`cso/`), applied to the
  steered image. Choice rule: the SPoSE triplet rule of Hebart et al. 2020
  (to be taken from the paper or its code, not from memory).
- Practice: 3 triplets of unrelated photos.

### Part 5: steering (about 8 min)

The intermediate steps of each continuum are shown here, not in the
recording blocks. Two modes (PI, 2026-11-23):

- **Mode A, behavioural closed loop (designed now).** The patient moves an
  image along the axes with the joystick, toward images they like. Images
  are pre-generated frames: for one object at a time, the original at the
  centre and the steps of each axis around it. Steering is step-locked:
  each move shows the new frame for a fixed 1.0 s before the next move is
  accepted, so every visited frame gives the same recording window as a
  main-block trial. Each frame shown is sent on the daq like a trial.
- **Mode B, firing-rate driven (prepared, not runnable yet).** The image
  moves along an axis according to a neuron's firing while the patient uses
  imagery. It needs spikes or firing rates delivered to the task computer
  during the session, which the rig does not do today. The task side takes a
  number per step from an interface that a simulated signal can feed.

What it is for: where the edge images drove a response, test whether the
intermediate steps modulate firing in a graded, roughly linear way along the
axis, in single units and in the population, and whether perceptual or
semantic similarity explains it.

### Optional: the following week (behaviour only)

The same 104 triplets again (both passes), on a laptop, no recording. The agreement with the
in-session choices says how stable the choices are for that patient.

## What the analyses will use

- Timing (PI, 2026-11-23): the triplet part is also when the models are
  fitted on parts 1 and 2, so it stays in the session as long as time allows.
  Fitting data as drafted: about 18 min, 84 distinct images. The main block
  is kept at this length (call made here); it grows with the number of axes.

- Neural fits: the main block and the mini-screening, plus the first 1.0 s
  of first-look trials.
- Semantic invariance: original vs written name vs other photos.
- Steering effect: steered image vs its original, per axis.
- Percept regressors: the spoken report at first look (coded by raters) and
  the odd-one-out choice per steered image.

## Decided by the PI

- (2026-11-23) The patient has already seen the objects in the screening
  session, which is where the 4 objects are chosen. Naming first is the
  cleanest; the main block is accepted as it is.
- Originals are not shown until the mini-screening at the end.
- 4 objects and 8 axes, possibly more axes: the number of axes is a setting,
  not fixed. Each extra axis adds 4 steered images: 4 first-look trials, 24
  main-block trials (about 1 min) and 8 triplets per pass.

- Edge cases only; free report before any words; 2AFC dropped; odd-one-out
  with 32 x 2 triplets.

## Calls made in this document (not yet confirmed by the PI)

- Both triplet passes run inside the recording session, at the end. If time
  is short, the odd-one-out pass is the one to move to the following week.
- The perceptual judgement is a second pass over the same triplets with a
  "looks" instruction, looks pass first.
- Beep moved from 0.5 s to 1.0 s so the first second is speech-free.
- 32 bridge trials (each steered image once) inside the mini-screening, to
  measure drift between the steered block and the originals.
- The triplets come after the mini-screening, because each triplet shows an
  original.
- Parts 2 and 3 use repeat detection with a fixed 1.0 s image, read from the
  PI's "yeah, testing for Cao"; about 10% repeat trials.
- Which other photos enter the main block (PS-least-similar, 4 per object).
- Steering mode A is step-locked with a 1.0 s hold per frame; one object at
  a time.
- At about 40 min the session is over the 30 min target; the odd-one-out
  pass is the first thing to move to the following week.
- Triplet counts per type (64 axis-driven, 32 same-axis partner, 8 fixed
  conflict); selection of the real axis photos and of the fixed conflict
  triplets (by disagreement between SPoSE and the PS model); 360 px images.
- Steered images get their SPoSE vector from the generation pipeline's
  image-to-SPoSE readout; predictions are computed at stimset build time.
- Daq protocol version goes to 6. No patient recording exists under version
  5, so no backward decoding is required; the old tasks stay in the repo but
  leave `run_session.m`.

## Left to the builder

- Task codes and daq train layout for the three parts. Requirement: the
  recording alone identifies task, image or images, their screen positions,
  presentation number, response and reaction time.
- How the triplet list is written by `setup/make_stimset.py`.
- Reuse of existing trial functions versus new ones; settings layout in
  `run_session.m` and the dummy scripts.
- German wording of the two triplet instructions.
- Gamepad key for the middle (down) choice; check the pad mapping on the rig.
- Practice triplets: photos of objects outside the session, from THINGS.

## Open points

- Can the rig deliver spikes or firing rates to the task computer during a
  session? Decides whether steering mode B can run.
- Steering mode A: the instruction ("images they like"), how a run ends, and
  how many steps per axis are offered.
- Low-level visual control images: include, and how to generate them?
- Which judgement format was the PS model fitted on? If it differs from
  triplets, the looks pass may need to change to match it.
- Whether patients can keep the two triplet instructions apart: the conflict
  fixed triplets measure this per patient.
- Scoring scheme for the spoken reports.
