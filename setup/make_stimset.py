#!/usr/bin/env python3
"""Build a task stimulus folder from the generated morph sequences.

Source layout (cso/_pending_stimuli_realvis_cn_preview_all12):
    <axis-name>/c<id>_<concept>_inst<i>/f000.jpg .. f006.jpg  + dense_alphas.npy
    f000 = original (alpha 0); f001..f006 = generated steps (alpha 0.9 .. 5.5)
Output (what load_stimuli.m parses), copied; folders and files carry the
ids and the words, and the morph step instead of the alpha value:
    <out>/a<axis_id>_<axis-name>/a<axis_id>_<axis-name>_c<id>_<concept>_inst<i>_s<step>.jpg
    step 1..3 = generated frames 2, 4, 6 (alpha 1.8, 3.7, 5.5)
    <out>/a0_original/a0_original_c<id>_<concept>_inst<i>_s0.jpg
    step 0 = the original photo (identical on every axis, stored once; mini-screening)
All instances are copied (chimera picks one with inst_subset).
<out>/steps.csv lists step, source frame and alpha.
axis_id = the 66-d SPoSE dimension number (metallic-artificial = 1, food = 2, ...).

Example set (4 random concepts, seeded):
    python3 setup/make_stimset.py --random 4 --seed 1 --out stimuli/example_8ax_4c
Patient set (the 4 screened concepts, ids from the screening):
    python3 setup/make_stimset.py --concepts 8 14 23 54 --out stimuli/<pid>/<pid>_<sess>
"""
import argparse, os, re, shutil, sys
import numpy as np

SRC = os.path.join(os.path.dirname(__file__), '..', '..', 'cso', '_pending_stimuli_realvis_cn_preview_all12')
# 8 axes = the 8 lowest-numbered (most important) SPoSE dimensions of the 12 generated
AXES = {1: 'metallic-artificial', 2: 'food-related', 3: 'animal-related', 5: 'plant-related',
        6: 'house-related-furnishing-related', 9: 'body--people-related',
        12: 'colorful-playful', 13: 'outdoors'}
FRAMES = [2, 4, 6]          # 3 generated steps, evenly spaced, incl. the maximum (alpha 1.8, 3.7, 5.5)

ap = argparse.ArgumentParser()
ap.add_argument('--src', default=SRC)
ap.add_argument('--out', required=True)
ap.add_argument('--concepts', type=int, nargs='*', help='concept ids (default: all)')
ap.add_argument('--random', type=int, help='pick this many random concepts instead')
ap.add_argument('--seed', type=int, default=1)
ap.add_argument('--inst', type=int, nargs='*', help='instances to copy (default: all)')
ap.add_argument('--frames', type=int, nargs='*', default=FRAMES)
a = ap.parse_args()
if a.random:
    all_ids = sorted({int(q.split('_')[0][1:]) for q in os.listdir(os.path.join(a.src, AXES[1]))})
    a.concepts = sorted(np.random.default_rng(a.seed).choice(all_ids, a.random, replace=False).tolist())
    print(f'random concepts (seed {a.seed}): {a.concepts}')

n = 0
step_alpha = {}
for axis_id, axis in AXES.items():
    adir = os.path.join(a.src, axis)
    for seq in sorted(os.listdir(adir)):
        stem, inst = seq.rsplit('_inst', 1)
        cid = int(stem.split('_')[0][1:])
        if (a.inst is not None and int(inst) not in a.inst) or (a.concepts and cid not in a.concepts):
            continue
        alphas = np.load(os.path.join(adir, seq, 'dense_alphas.npy'))
        odir = os.path.join(a.out, f'a{axis_id}_{axis}')
        os.makedirs(odir, exist_ok=True)
        for step, f in enumerate(a.frames, start=1):
            src = os.path.join(adir, seq, f'f{f:03d}.jpg')
            dst = os.path.join(odir, f'a{axis_id}_{axis}_{stem}_inst{inst}_s{step}.jpg')
            shutil.copyfile(src, dst)
            n += 1
            step_alpha[step] = (f, float(alphas[f]))
        # the original (frame 0) once per concept x instance
        orig = os.path.join(a.out, 'a0_original', f'a0_original_{stem}_inst{inst}_s0.jpg')
        if not os.path.exists(orig):
            os.makedirs(os.path.dirname(orig), exist_ok=True)
            shutil.copyfile(os.path.join(adir, seq, 'f000.jpg'), orig)
            n += 1
            step_alpha[0] = (0, float(alphas[0]))
with open(os.path.join(a.out, 'steps.csv'), 'w') as fh:
    fh.write('step,source_frame,alpha\n')
    for st in sorted(step_alpha):
        fh.write(f'{st},{step_alpha[st][0]},{step_alpha[st][1]:.2f}\n')
print(f'{n} images -> {a.out}')
if a.concepts:
    found = {int(m.group(1)) for _, _, fs in os.walk(a.out) for f in fs
             for m in [re.search(r'_c(\d+)_[^_]+_inst', f)] if m}
    missing = sorted(set(a.concepts) - found)
    if missing:
        sys.exit(f'concept ids not found: {missing}')
