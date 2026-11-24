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

## Framework the session has to fit (PI, 2026-11-24)

1. Perceptual and semantic differences are quantified for every image before
   the session: perceptual distance to its original (the PI's PS model) and
   semantic position and shift (SPoSE).
2. Models are fitted directly on the firing rates of all patients, pooled.
3. Combining the perceptual measure, the semantic measure and the fitted
   neural models gives the informative axes, and perhaps extrapolation
   beyond the images shown.

Consequences for the task:
- Every image a patient sees carries its quantification in the stimset
  (PS distance to the original, SPoSE vector and shift along its axis, and
  the image features the neural models use), written by
  `setup/make_stimset.py` and saved with the plan.
- Patients see different objects, so pooling works through the shared
  feature spaces, not through shared images. Every recorded trial therefore
  has the same format in all recording parts: 1.0 s image, same question.
- The steering images for a session are chosen where the three sources are
  informative: where the perceptual and the semantic account predict
  different firing under the pooled neural model, and where the model
  extrapolates. The pooled model exists before the session; data from the
  same session can refine the choice if it is available in time.

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

Structure set by the PI on 2026-11-24. Before any session, the axes are
pre-selected offline on all 200 objects of the generation study: which axes
give a usable steered image for which object. A session then uses 4 objects
(from the patient's screening) and 8 of those axes: 32 steered images.

Order: naming, main block, mini-screening, steering. About 20 minutes for
the first three, then steering, which is the actual test (PI, 2026-11-24).
The odd-one-out part is out of the session in favour of steering time and
moves to the following week. Eye tracker calibrated
once, before the naming. Originals are not shown before the mini-screening.
No axis word is shown or spoken anywhere.

Common trial start, unchanged: blank 0.2 s plus 0 to 0.2 s jitter (trial
train sent here), fixation cross 0.3 s, then the image at 480 x 480 px with
the photodiode patch.

Parts 1 and 2 are one run with two phases: one start, one instruction screen
between the phases, one set of log files. Presentation 1 (naming phase) is
tagged in the data so fits can be run with and without it.

### Part 1: naming (about 4 to 6 min, paced by the patient)

- Images: the 32 steered images, each once, random order, never the same
  object twice in a row.
- Trial: image on; a soft beep 1.0 s after onset is the cue to speak; the
  image stays on; Space or a gamepad button ends the trial. No time limit.
- Instruction: say aloud what you see. No example that names a property.
- One continuous microphone recording.
- The first 1.0 s of each trial is speech-free and counts as one presentation
  of that image for the neural data.
- Practice: 2 images of other objects.

### Part 2: main block (about 8 min)

- Question on every trial (PI): "would it fit in a suitcase?" Left = yes,
  right = no. One constant question, unrelated to the axes.
- Images: the 32 steered images, 6 presentations each. 192 trials in 6
  blocks, every image once per block, random order, never the same object
  twice in a row.
- Trial: image on for exactly 1.0 s, then black screen. A key press is
  accepted from image onset. If it came during the image, the trial ends at
  image offset; otherwise the screen stays black until the key press. A late
  answer is valid, with its reaction time; no maximum wait, no repeats.
- With part 1, every steered image has 7 presentations.

### Odd-one-out (not in the session; following week, behaviour only)

- Removed from the session by the PI on 2026-11-24 to give its time to
  steering.
- Three images side by side; the patient picks the one that fits least with
  the other two (left, down, right key). No time limit. Images at 360 px.
- Triplet (PI): two steered images of the same axis from different objects,
  and another photo of the object of one of them. Example: food-like boot,
  food-like battery, another boot photo. The original itself is not used,
  because the triplets were designed to run before the originals are shown.
- Reading: choosing the boot photo means the shared axis binds the two
  steered images; choosing the food-like battery means the steered boot is
  still a boot.
- Each steered image is the "own" image in 2 triplets with different
  partners: 64 trials, random order, screen positions balanced.
- SPoSE-predicted choice probabilities for every triplet are computed in
  `setup/make_stimset.py` and saved with the stimset. Photos use their
  object's row of the 66-d SPoSE matrix; a steered image uses the
  image-to-SPoSE readout of the generation pipeline (`cso/`). Choice rule:
  the SPoSE triplet rule of Hebart et al. 2020, taken from the paper or its
  code.
- Practice: 3 triplets of unrelated photos.

### Part 3: mini-screening (about 6 min)

- Per object: original photo x 8, written name x 8, the 11 other photos once
  each. 108 trials in 8 blocks, as in the current mini-screening.
- Bridge trials: every steered image once more, spread over the blocks. 32
  trials. Originals are only ever recorded after the steered images, so a
  slow drift in firing would look like a steered-versus-original difference;
  the bridge trials measure that drift.
- Same question and timing as the main block (call made here), so originals
  and steered images are recorded under one task. This departs from the
  lab's mini-screening (one-hand question, image until key press).

### Part 4: steering (10 min or more)

- Selection: by the framework above. For the first patients, before a pooled
  neural model exists, by disagreement between the PS and SPoSE measures.
- About 6 presentations per image (PI), random order, presented like
  main-block trials (call made here: this keeps one trial format for the
  pooled fits). Against boredom: short rounds with a progress counter, and
  about one new, once-shown image in every four trials.
- Free exploration with the joystick and imagery are the later stage of this
  part (PI): a "collection" variant, in which the patient steers and every
  image must be visited six times, is the bridge to it.

What it is for (PI): where units responded to the edge images, show the
intermediate points of those axes and test whether firing is modulated
parametrically along the axis; extend to other axes, predicted from which
axes worked for the cells during the session; or show the predicted maximum
and minimum stimuli for a given unit.

- The images shown here are chosen from the session's own recordings, so
  this part needs unit responses during the session. How they reach the task
  computer is an open point; until that exists, the selection can only be
  made from a simulated signal or before the session.
- Presentation as in the main block (1.0 s image, same question), so the
  intermediate points are analysed like main-block trials.
- Two further modes were named by the PI on 2026-11-23 and are not designed
  in detail here: the patient steering with the joystick toward images they
  like, and firing-rate-driven steering through imagery.

### Optional: the following week (behaviour only)

The odd-one-out triplets again, and a "which looks most different" pass over
the same triplets, on a laptop, no recording.

## What the analyses will use

- Timing (PI, 2026-11-23): the triplet part is also when the models are
  fitted on parts 1 and 2, so it stays in the session as long as time allows.
  Fitting data as drafted: about 18 min, 84 distinct images. The main block
  is kept at this length (call made here); it grows with the number of axes.

- Neural fits: the main block and the mini-screening, plus the first 1.0 s
  of naming trials.
- Semantic invariance: original vs written name vs other photos.
- Steering effect: steered image vs its original, per axis.
- Percept regressors: the spoken report (coded by raters) and, if part 3
  runs, the odd-one-out choice per steered image.

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

- Beep at 1.0 s so the first second of naming trials is speech-free.
- Main block and mini-screening use a fixed 1.0 s image; late answers valid.
- The mini-screening uses the suitcase question, not the lab's one-hand
  question.
- 32 bridge trials inside the mini-screening.
- Odd-one-out: 2 triplets per steered image; 360 px images; steered images
  get their SPoSE vector from the generation pipeline's readout.
- Steering trials are presented like main-block trials.
- Daq protocol version goes to 6; the old tasks stay in the repo but leave
  `run_session.m`.

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

- How unit responses reach the task computer during the session (part 4).
- Steering: how many presentations per image (PI: about 6) against how many
  intermediate points and axes; how to keep the patient engaged.
- Axis pre-selection: are the 8 axes the same for all 4 objects of a session,
  or chosen per object?
- Low-level visual control images: include, and how to generate them?
- Scoring scheme for the spoken reports.
