# Closed-loop visual tasks (Psychtoolbox)

Task scripts for the closed-loop visual paradigms, built on the skeleton of the lab's
`run_dynamic_eye.m` / `run_mini_screening.m` and their helpers (`daqInit`, `daqOut`,
`fixation_cross_eye`, Titta).

Experiment: open `run_session.m`, set `patient_id` and `session_nr` at the top, run it (or one task
section at a time). Testing / debugging: the `run_<task>_dummy.m` scripts. It runs chimera, then naming, and saves
`logs/<pid>/<pid>_<sess>/session_<time>.mat` (settings, outcome of every task, code version).

| task | rig script | debug script | parameters | task code |
|---|---|---|---|---|
| chimera: adjective 4-way choice on generated morphs | `run_chimera_eye.m` | `run_chimera_dummy.m` | `functions/chimera_params.m` | 2 |
| naming block: image stays on, spoken answer recorded | `run_naming_eye.m` | `run_naming_dummy.m` | `functions/naming_params.m` | 3 |
| SPoSE control: "could you lift it?" | `run_spose_eye.m` | `run_spose_dummy.m` | `functions/spose_params.m` | 1 |
| steering prototypes (test screens only) | | `run_steer_dummy.m`, `run_respmax_dummy.m` | in the script | |

- Rig: `run_chimera_eye(patient_id, session_nr)`. Stimuli are read from
  `stimuli/subject<NNN>/subject<NNN>_stimset<NN>/`, logs written to `logs/<pid>/<pid>_<sess>/`.
- The dummy scripts (plain scripts) run exactly the rig code with the test settings written out at
  their top: no DAQ, no eye tracker, windowed, keyboard polling.
- Stimuli (not in git): `setup/make_stimset.py` builds `stimuli/subject<NNN>/` with
  `subject<NNN>_stimset<NN>/` (one flat folder per session), `originals/` and `practice/`; files `a<a>_<axis><dim>_c<c>_<concept><things>_inst<k>_level<L>.jpg`,
  e.g. `a8_outdoors13_c1_glove681_inst0_level2.jpg`: a, c = indices in the set (sent on the daq),
  dim = SPoSE dimension (66-d), things = THINGS number (1-1854), k = source instance, levels 1-3
  generated; originals in `originals/a0_original0_c<c>_<concept><things>_inst<k>_level0.jpg` (mini-screening).
  `stimset_map.csv` lists source frame and alpha per file.
  Chimera uses `step_subset = [1 2 3]` (levels) and `inst_subset = 0`.
  Read by default for patient NNN, session NN.
  Patient: `python3 setup/make_stimset.py --subject 1 --stimset 1 --concepts <THINGS numbers>`
  Example (dummies, patient 99): `python3 setup/make_stimset.py --subject 99 --stimset 1 --concepts 681 887 344 575`
  Practice: `python3 setup/make_stimset.py --subject 99 --practice --concepts 1092 117 --inst 0`
- Every saved file starts with `<task>_<yyyymmdd_HHMMSS>`, so runs never overwrite each other.
- Gamepad: read by Psychtoolbox (`functions/gamepad_keys.m`); optional `calibrate_gamepad` saves a mapping.
- The dynamic paradigm's `functions` folder must be on the path (or set `dynamic_fcn_dir`).
- Daq protocol (event codes, data trains, decoder): `functions/TaskCodes.m`.
  Data bytes are sent as value + 1, so no byte is lost (`daqOut` sends no pulse for 0).
  `TaskCodes.parse_stream` decodes a recorded digital channel.
- Every trial is saved on its own right after it runs; the full plan is saved before trial 1.

Stimulus file names: `a<axis>_<axisname>_c<concept>_<conceptname>_inst<i>_a<alpha>.jpg`.
Data (`stimuli/`, `logs/`, `.mat`, `.wav`) is not tracked.
