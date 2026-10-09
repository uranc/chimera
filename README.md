# Closed-loop visual tasks (Psychtoolbox)

Task scripts for the closed-loop visual paradigms, built on the lab's `run_dynamic_eye.m` /
`run_mini_screening.m` and their helpers (`daqInit`, `daqOut`, `fixation_cross_eye`, Titta).
Design and daq protocol: `DESIGN_behavior.md`.

Experiment: open `run_session.m`, set `patient_id`, `session_nr`, `stimset` and the task settings at
the top, run it (or one task section at a time with Ctrl+Enter). It runs chimera, naming, then the
mini-screening, and saves `logs/<pid>/<pid>_<sess>/session_<time>.mat` (settings, outcome of every
task, code version). Testing / debugging: the `run_<task>_dummy.m` scripts (plain scripts: the rig
code with test settings written out at their top: no daq, no eye tracker, small window, key polling).

| task | rig script | debug script | parameters | task code |
|---|---|---|---|---|
| 1 chimera: 2AFC word choice on generated images | `run_chimera_eye.m` | `run_chimera_dummy.m` | `functions/chimera_params.m` | 2 |
| 2 naming: image stays on, answer beep, spoken answer recorded | `run_naming_eye.m` | `run_naming_dummy.m` | `functions/naming_params.m` | 3 |
| 3 mini-screening: dynamic's run_mini_screening, "one hand?" left/right | `run_miniscreening_eye.m` | `run_miniscreening_dummy.m` | top of the script | 4 |
| SPoSE control: "could you lift it?" | `run_spose_eye.m` | `run_spose_dummy.m` | `functions/spose_params.m` | 1 |
| steering prototypes (test screens only) | | `run_steer_dummy.m`, `run_respmax_dummy.m` | in the script | |

## Stimuli (not in git)
`setup/make_stimset.py` (Linux, reads the production set `/mnt/data/cso_prod/FINAL`) builds
`stimuli/subject<NNN>/`:
- `subject<NNN>_stimset<NN>/` one flat folder per session:
  `a<a>_<axis><dim>_c<c>_<concept><things>_inst<k>_level<L>.jpg`, e.g.
  `a6_outdoors13_c2_boot170_inst0_level2.jpg`: a, c = indices in the set (sent on the daq),
  dim = SPoSE dimension (66-d), things = THINGS number, k = instance, L = level (source L1..L3,
  chosen with `--levels`); `stimset_map.csv` lists source level, frame and steering parameter.
- `originals/` the first 12 THINGS photos per concept (`a0_original0_..._inst0..11_level0.jpg`,
  inst0 = the photo the generated images start from) and the written German name
  (`a0_name0_...jpg`); one copy per concept across stimsets (mini-screening).
- `practice/` max level only, concepts outside the session.

```
python3 setup/make_stimset.py --subject 121 --stimset 1 --concepts 98 170 824 1819 --levels 2 3
python3 setup/make_stimset.py --subject 121 --practice --concepts 937 1691
```
German words (axes and concept names): `functions/chimera_labels.m` (entries marked "check" are unverified).

## Notes
- Every saved file starts with `<task>_<yyyymmdd_HHMMSS>`, so runs never overwrite each other.
- The eye tracker is calibrated once per session (task 1, `eye_calibrate`); later tasks record with it.
- Keys: `wait_for_keys` (KbQueue or polling, new presses only, so keys stuck down on Windows
  laptops are ignored); the F310 gamepad counts as arrow keys (Mode swaps d-pad/stick).
- The dynamic paradigm's `functions` folder must be on the path (or set `dynamic_fcn_dir`).
- Daq protocol (event codes, data trains, decoder): `functions/TaskCodes.m`; data bytes are sent
  as value + 1 (`daqOut` sends no pulse for 0); `TaskCodes.parse_stream` decodes a recorded channel.
- Every trial is saved right after it runs; the full plan is saved before trial 1.

Data (`stimuli/`, `logs/`, `.mat`, `.wav`) is not tracked.
