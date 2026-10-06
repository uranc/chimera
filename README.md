# Closed-loop visual tasks (Psychtoolbox)

Task scripts for the closed-loop visual paradigms, built on the skeleton of the lab's
`run_dynamic_eye.m` / `run_mini_screening.m` and their helpers (`daqInit`, `daqOut`,
`fixation_cross_eye`, Titta).

Whole session: `run_session(patient_id, session_nr)` runs the tasks in order (chimera, then naming) and
saves `logs/<pid>/<pid>_<sess>/session_<time>.mat` (tasks, overrides, outcomes, code version).
`run_session(pid, sess, 'dummy')` runs the same with the test settings of `functions/dummy_overrides.m`.

| task | rig script | debug script | parameters | task code |
|---|---|---|---|---|
| chimera: adjective 4-way choice on generated morphs | `run_chimera_eye.m` | `run_chimera_dummy.m` | `functions/chimera_params.m` | 2 |
| naming block: image stays on, spoken answer recorded | `run_naming_eye.m` | `run_naming_dummy.m` | `functions/naming_params.m` | 3 |
| SPoSE control: "could you lift it?" | `run_spose_eye.m` | `run_spose_dummy.m` | `functions/spose_params.m` | 1 |
| steering prototypes (test screens only) | | `run_steer_dummy.m`, `run_respmax_dummy.m` | in the script | |

- Rig: `run_chimera_eye(patient_id, session_nr)`. Stimuli are read from
  `stimuli/<pid>/<pid>_<sess>/`, logs written to `logs/<pid>/<pid>_<sess>/`.
- The dummy scripts run exactly the rig code with the overrides in `functions/dummy_overrides.m`: no DAQ,
  no eye tracker, windowed, keyboard polling, example stimuli.
- Stimuli (not in git): `setup/make_stimset.py` builds task folders from the generated morphs:
  8 axes (SPoSE dims 1,2,3,5,6,9,12,13), steps s1-s3 (frames 2/4/6, alpha 1.8/3.7/5.5), the
  originals as s0 in `a0_original/`, all instances; `steps.csv` maps step -> alpha. Chimera uses
  `step_subset = [1 2 3]`, `inst_subset = 0`.
  Example (dummies): `python3 setup/make_stimset.py --concepts 38 41 62 78 --out stimuli/example_8ax_4c`
  Practice (dummies): `python3 setup/make_stimset.py --concepts 10 47 --inst 0 --out stimuli/practice_8ax`
  Patient: `python3 setup/make_stimset.py --concepts <4 ids> --out stimuli/<pid>/<pid>_<sess>`
- Every saved file starts with `<task>_<yyyymmdd_HHMMSS>`, so runs never overwrite each other.
- Gamepad: read by Psychtoolbox (`functions/gamepad_keys.m`); optional `calibrate_gamepad` saves a mapping.
- The dynamic paradigm's `functions` folder must be on the path (or set `dynamic_fcn_dir`).
- Daq protocol (event codes, data trains, decoder): `functions/TaskCodes.m`.
  Data bytes are sent as value + 1, so no byte is lost (`daqOut` sends no pulse for 0).
  `TaskCodes.parse_stream` decodes a recorded digital channel.
- Every trial is saved on its own right after it runs; the full plan is saved before trial 1.

Stimulus file names: `a<axis>_<axisname>_c<concept>_<conceptname>_inst<i>_a<alpha>.jpg`.
Data (`stimuli/`, `logs/`, `.mat`, `.wav`) is not tracked.
