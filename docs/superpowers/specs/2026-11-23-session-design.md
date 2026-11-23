# Recording session design: first look, main block, odd-one-out

Date: 2026-11-23. Replaces the chimera 2AFC / naming / mini-screening session
(`DESIGN_behavior.md`, `run_session.m`).

## Intent

Separate visual from semantic coding in human MTL neurons, using generated
images that are meant to look similar to a photo but mean something different.
About 30 minutes of recording per session must give (a) neural responses that
can be fitted with a visual model and a semantic model, and (b) behaviour that
says what the patient actually perceived.

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
- 4 objects per session, 8 SPoSE axes (1, 2, 3, 5, 12, 13, 40, 54), instance 0.
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

Order: first look, main block, triplets (looks pass, then odd-one-out pass).
About 26 minutes of trials. Eye
tracker calibrated once, before the first look.

Common trial start, unchanged: blank 0.2 s plus 0 to 0.2 s jitter (trial
train sent here), fixation cross 0.3 s, then the image at 480 x 480 px with
the photodiode patch.

### Part 1: first look (about 4 min)

- Images: the 32 steered images, then the 4 originals. Each once. 36 trials.
- Trial: image on; a soft beep 1.0 s after onset is the cue to speak; the
  image stays on; Space or a gamepad button ends the trial. No time limit.
- Instruction: say aloud what you see. No example that names a property.
- One continuous microphone recording, as in the current naming task.
- Order: steered images in random order, never the same object twice in a
  row; the 4 originals at the end.
- The first 1.0 s of each trial is speech-free and counts as one presentation
  of that image for the neural data.
- Practice: 2 images of other objects.

### Part 2: main block (about 12 min)

- Question on every trial: "can it be picked up with one hand?" Left = yes,
  right = no. Same instruction text as the current mini-screening.
- Core images, 6 presentations each: 32 steered, 4 originals, 4 written
  names. 240 trials.
- Other photos of each object (instances 1 to 11), once each: 44 trials.
- 284 trials in 6 blocks; every core image once per block, the other photos
  spread over the blocks; random order within a block, never the same object
  twice in a row.
- Trial: image on for exactly 1.0 s, then black screen. A key press is
  accepted from image onset. If it came during the image, the trial ends at
  image offset; otherwise the screen stays black until the key press. A late
  answer is a valid trial with its reaction time; no maximum wait, no repeats.
- With part 1, every steered image and original has 7 presentations.

### Part 3: triplets, two passes (about 10 min)

The same 72 triplets are judged twice, with different instructions:

- **Looks pass (first):** "which picture looks most different from the other
  two?" This is the perceptual-similarity judgement. A steered image that is
  perceptually close to its original leaves the anchor as the odd one.
- **Odd-one-out pass (second):** the standard instruction, "which one fits
  least with the other two?", as in THINGS.

The dissociation the study is after shows up when the patient named the
steered image as something else at first look, picks the anchor in the looks
pass, and picks the original in the odd-one-out pass. The looks pass runs
first so the meaning judgement cannot colour it.


- Three images side by side; the patient picks the one that fits least with
  the other two (left, down, right key). No time limit. Images at 360 px.
- Steered triplets: steered image, its own original, and an anchor photo.
  Each steered image appears in 2 triplets with different anchors. 64 trials.
- Baseline triplets: original, another photo of the same object, and an
  anchor. 2 per object, 8 trials. The expected answer is the anchor.
- 72 trials per pass, a new random order in each pass, never the same object in consecutive trials;
  the screen position of each role is balanced.
- Anchor photos: for each axis, the 4 THINGS objects with the highest
  loading on that SPoSE dimension, excluding the session and practice
  objects; the first photo (sorted) of each, from the full THINGS image tree
  (`THINGS-database/osfstorage/images_THINGS/object_images`), resized like
  the originals. 32 photos, shown nowhere else in the session. The same
  anchors are used for every patient unless one is a session object.
- Reading: choosing the original as odd means the steered image moved toward
  the anchor's meaning; choosing the anchor means it stayed the object.
- Before the session, the SPoSE-predicted choice probabilities for every
  triplet are computed in `setup/make_stimset.py` and saved with the stimset.
  Originals and anchors use their object's row of the 66-d SPoSE matrix
  (`THINGS-database/behavior/variables/spose_embedding_66d_sorted.txt`). A
  steered image has no row of its own: its vector is the image-to-SPoSE
  readout the generation pipeline already uses (`cso/`), applied to the
  steered image. Choice rule: the SPoSE triplet rule of Hebart et al. 2020
  (to be taken from the paper or its code, not from memory).
- Practice: 3 triplets of unrelated photos.

### Optional: the following week (behaviour only)

The same 72 triplets again (both passes), on a laptop, no recording. The agreement with the
in-session choices says how stable the choices are for that patient.

## What the analyses will use

- Timing (PI, 2026-11-23): the triplet part is also when the models are
  fitted on parts 1 and 2, so it stays in the session as long as time allows.
  Fitting data as drafted: about 16 min, 84 distinct images. Whether the main
  block should be extended toward 30 min is an open point.

- Neural fits: the main block, plus the first 1.0 s of first-look trials.
- Semantic invariance: original vs written name vs other photos.
- Steering effect: steered image vs its original, per axis.
- Percept regressors: the spoken report at first look (coded by raters) and
  the odd-one-out choice per steered image.

## Decided by the PI

- Edge cases only; free report before any words; 2AFC dropped; odd-one-out
  with 32 x 2 triplets.

## Calls made in this document (not yet confirmed by the PI)

- Both triplet passes run inside the recording session, at the end. If time
  is short, the odd-one-out pass is the one to move to the following week.
- The perceptual judgement is a second pass over the same triplets with a
  "looks" instruction, looks pass first.
- Beep moved from 0.5 s to 1.0 s so the first second is speech-free.
- Originals shown at the end of the first look, so they do not label the
  steered images.
- Main block uses a fixed 1.0 s image instead of "until key press" as in the
  dynamic mini-screening, to give every trial the same window.
- 8 baseline triplets added; anchor selection rule (fixed across patients);
  360 px triplet images.
- Steered images get their SPoSE vector from the generation pipeline's
  image-to-SPoSE readout; predictions are computed at stimset build time.
- Late answers in the main block are valid; no maximum wait.
- Daq protocol version goes to 6. No patient recording exists under version
  5, so no backward decoding is required; the old tasks stay in the repo but
  leave `run_session.m`.
- The steered image's triplet partner is always its own original.

## Left to the builder

- Task codes and daq train layout for the three parts. Requirement: the
  recording alone identifies task, image or images, their screen positions,
  presentation number, response and reaction time.
- How anchors are added to `setup/make_stimset.py` and where they are stored.
- Reuse of existing trial functions versus new ones; settings layout in
  `run_session.m` and the dummy scripts.
- German wording of the two triplet instructions.
- Gamepad key for the middle (down) choice; check the pad mapping on the rig.
- Practice triplets: photos of objects outside the session, from THINGS.

## Open points

- Low-level visual control images: include, and how to generate them?
- Which judgement format was the PS model fitted on? If it differs from
  triplets, the looks pass may need to change to match it.
- Whether patients can keep the two triplet instructions apart; check in the
  first pilot.
- Scoring scheme for the spoken reports.
