# Closed-loop visual tasks (Psychtoolbox)

Task scripts for the closed-loop visual paradigms, built on the skeleton of the lab's
`run_dynamic_eye.m` / `run_mini_screening.m` and their helpers (`daqInit`, `daqOut`,
`fixation_cross_eye`, Titta).

| task | rig script | debug script | parameters | task code |
|---|---|---|---|---|
| chimera: adjective 4-way choice on generated morphs | `run_chimera_eye.m` | `run_chimera_dummy.m` | `functions/chimera_params.m` | 2 |
| naming block: image stays on, spoken answer recorded | `run_naming_eye.m` | `run_naming_dummy.m` | `functions/naming_params.m` | 3 |
| SPoSE control: "could you lift it?" | `run_spose_eye.m` | `run_spose_dummy.m` | `functions/spose_params.m` | 1 |
| steering prototypes (test screens only) | | `run_steer_dummy.m`, `run_respmax_dummy.m` | in the script | |

- Rig: `run_chimera_eye(patient_id, session_nr)`. Stimuli are read from
  `stimuli/<pid>/<pid>_<sess>/`, logs written to `logs/<pid>/<pid>_<sess>/`.
- The dummy scripts run exactly the rig code with overrides: no DAQ, no eye tracker,
  windowed, test stimuli (`stimuli/stimset120`), keyboard polling for remote testing.
- The dynamic paradigm's `functions` folder must be on the path (or set `dynamic_fcn_dir`).
- Daq protocol (event codes, data trains, decoder): `functions/TaskCodes.m`.
  Data bytes are sent as value + 1, so no byte is lost (`daqOut` sends no pulse for 0).
  `TaskCodes.parse_stream` decodes a recorded digital channel.
- Every trial is saved on its own right after it runs; the full plan is saved before trial 1.

Stimulus file names: `a<axis>_<axisname>_c<concept>_<conceptname>_inst<i>_a<alpha>.jpg`.
Data (`stimuli/`, `logs/`, `.mat`, `.wav`) is not tracked.
