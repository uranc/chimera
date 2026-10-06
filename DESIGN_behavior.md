# Behavioral design (ptb/)

Two tasks share the stimulus set (`stimuli/stimset120`, 4 axes x 10 concepts x 11 alphas),
the plan builder, the daq/Tobii scheme and the per-trial cfg logging.

## Task 1 - SPoSE mapping block (`run_spose_eye.m`, task_type 1)
Neural mapping with an orthogonal engagement task, after Karkowski et al. 2025 (Bonn closed loop):
blank 200-400 ms -> fixation 300 ms -> image until key. Question: "could you lift it?"
left arrow = yes, right = no. Participants stay blind to the axis/alpha manipulation.
All 440 images per block by default; restrict with `alpha_subset`, `concept_subset`, `axis_subset`.

## Task 2 - press-based naming, design A (`run_chimera_eye.m`, task_type 2, question_type 'naming4')
blank 200-400 ms -> fixation 300 ms -> image 500 ms (+ photodiode) -> image OFF -> four words in a
diamond (up/left/right/down arrows) until key. Words mix object names and axis adjectives.
Per image, over its 6 presentations the schedule cycles:
  both (true object + true adjective), concept (object only), axis (adjective only),
  catch (four unrelated words, forced guess = guessing baseline), both, axis.
Instruction: pick the object if present, otherwise the word that best describes what it looks like.
Controls:
- identical 500 ms image epoch on every trial; the question appears only after image offset
- distractors never the true object/adjective; counters keep every word equally used as
  distractor and equally often in each position (response-set membership uniform)
- >= 20 trials between presentations of the same image, across block boundaries;
  never the same concept on consecutive trials
- target position balanced per word; no feedback; 8 practice trials on anchors
- all parameters predetermined and saved before trial 1; cfg per trial saved after every trial
Observables per image (Rajalingham-style image-level residuals + image x distractor matrix,
split-half reliability): P(object | object offered), P(adjective | adjective offered, object absent)
= ambiguity, P(adjective | both offered) = conflict, all against the catch-trial object/adjective
choice rates and against the alpha-0 original. chosen_type (object vs adjective) logged per trial.

## Trial budget (design: 4 concepts x 8 axes x 3 levels (level 1 = shared original), >= 6 presentations per image)
4 concepts x 8 axes x 3 samples = 96 images x 6 reps = 576 trials, ~24 min; 6 blocks of 96.
Use `concept_subset` from the screening to cut continua rather than levels.

## daq trains (one byte per pulse, `daq_train_gap` apart)
gaze on (32): [task, patient, session]      block start (2): [block]
trial start (16): [task, patient, session, block, trial, axis, concept, inst, level]
fixation 4, image on 22, image off 65, question 128, response 64: single pulses as in dynamic
after image off: [response, chosen_type, correct, rt_hi, rt_lo]  (rt in ms from image onset)
layouts live in functions/TaskCodes.m

## Open points
- alpha 0 images are presumably identical across axes; fine for the 2AFC (they are the anchor),
  but the SPoSE block shows 4 copies of each original per rep.
- key names on the rig keypad (UnifyKeyNames) still to be confirmed.
