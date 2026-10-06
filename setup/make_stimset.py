#!/usr/bin/env python3
"""Build one session's stimulus folder from the generated morph sequences.

Source (cso/_pending_stimuli_realvis_cn_preview_all12):
    <axis-name>/c<things_id>_<concept>_inst<i>/f000.jpg .. f006.jpg + dense_alphas.npy
    f000 = original (alpha 0); f001..f006 = generated (alpha 0.9 .. 5.5)

Output: ONE flat folder per session, stimuli/subject<NNN>_stimset<NN>/:
    a<a>_<axisname><dim>_c<c>_<conceptname><things>_inst<k>_level<L>.jpg
        a      = axis index in this set (1..8; sent on the daq)
        dim    = SPoSE dimension number (1..66, 66-d embedding)
        c      = concept index in this set (1..n; sent on the daq)
        things = THINGS concept number (1..1854, unique_id.txt order)
        k      = source instance, L = 1..3 generated level (frames 2, 4, 6)
        e.g. a8_outdoors13_c1_glove681_inst0_level2.jpg
    a0_original0_c<c>_<conceptname><things>_inst<k>_level0.jpg
        the original photo (identical on every axis, stored once; mini-screening)
    stimset_map.csv   per file: indices, SPoSE dim, THINGS number, instance, frame, alpha
Concept names must not end in a digit (the THINGS number follows directly).

Patient session (THINGS numbers of the screened concepts):
    python3 setup/make_stimset.py --subject 1 --stimset 1 --concepts 681 887 344 575
    -> stimuli/subject001_stimset01/   (run_chimera_eye(1, 1) reads it by default)
Example / test (4 random concepts, seeded):
    python3 setup/make_stimset.py --subject 99 --stimset 1 --random 4 --seed 1
Any other folder: --out <dir>
"""
import argparse, os, shutil, sys
import numpy as np

SRC = os.path.join(os.path.dirname(__file__), '..', '..', 'cso', '_pending_stimuli_realvis_cn_preview_all12')
# 8 axes = the 8 lowest-numbered (most important) SPoSE dimensions of the 12 generated,
# in that order -> a1..a8
AXES = [(1, 'metallic-artificial'), (2, 'food-related'), (3, 'animal-related'), (5, 'plant-related'),
        (6, 'house-related-furnishing-related'), (9, 'body--people-related'),
        (12, 'colorful-playful'), (13, 'outdoors')]
FRAMES = [2, 4, 6]          # levels 1..3: evenly spaced generated frames incl. the maximum
THINGS_IDS = os.path.expanduser('~/Documents/THINGS-database/behavior/variables/unique_id.txt')

ap = argparse.ArgumentParser()
ap.add_argument('--src', default=SRC)
ap.add_argument('--out', help='output folder (default: stimuli/subject<NNN>_stimset<NN>)')
ap.add_argument('--subject', type=int)
ap.add_argument('--stimset', type=int)
ap.add_argument('--concepts', type=int, nargs='*', help='THINGS concept numbers (default: all available)')
ap.add_argument('--things', default=THINGS_IDS, help='THINGS unique_id.txt (concept order)')
ap.add_argument('--random', type=int, help='pick this many random concepts instead')
ap.add_argument('--seed', type=int, default=1)
ap.add_argument('--inst', type=int, nargs='*', help='source instances to copy (default: all)')
a = ap.parse_args()
if a.out is None:
    if a.subject is None or a.stimset is None:
        sys.exit('give --subject and --stimset (or --out)')
    a.out = os.path.join(os.path.dirname(__file__), '..', 'stimuli', f'subject{a.subject:03d}_stimset{a.stimset:02d}')

# generated concepts -> THINGS number (1-based line in unique_id.txt)
things = {n.strip(): i + 1 for i, n in enumerate(open(a.things)) if n.strip()}
names, src_stem = {}, {}
for q in os.listdir(os.path.join(a.src, AXES[0][1])):
    stem = q.rsplit('_inst', 1)[0]
    cname = stem.split('_', 1)[1]
    if cname not in things:
        sys.exit(f'{cname} is not a THINGS concept')
    names[things[cname]] = cname
    src_stem[things[cname]] = stem
if a.random:
    a.concepts = sorted(np.random.default_rng(a.seed).choice(sorted(names), a.random, replace=False).tolist())
    print(f'random concepts (seed {a.seed}): {a.concepts}')
concepts = a.concepts or sorted(names)
missing = [c for c in concepts if c not in names]
if missing:
    sys.exit(f'THINGS numbers not among the generated concepts: {missing}')

os.makedirs(a.out, exist_ok=True)
rows, n = [], 0
bad = [names[t] for t in concepts if names[t][-1].isdigit()]
if bad:
    sys.exit(f'concept names ending in a digit would be ambiguous in the file name: {bad}')
for ci, tid in enumerate(concepts, start=1):
    cname = names[tid]
    for ai, (dim, axis) in enumerate(AXES, start=1):
        seqs = sorted(q for q in os.listdir(os.path.join(a.src, axis)) if q.startswith(f'{src_stem[tid]}_inst'))
        insts = sorted(int(q.rsplit('_inst', 1)[1]) for q in seqs)
        if a.inst is not None:
            insts = [i for i in insts if i in a.inst]
        for src_inst in insts:
            sdir = os.path.join(a.src, axis, f'{src_stem[tid]}_inst{src_inst}')
            alphas = np.load(os.path.join(sdir, 'dense_alphas.npy'))
            for lev, f in enumerate(FRAMES, start=1):
                fn = f'a{ai}_{axis}{dim}_c{ci}_{cname}{tid}_inst{src_inst}_level{lev}.jpg'
                shutil.copyfile(os.path.join(sdir, f'f{f:03d}.jpg'), os.path.join(a.out, fn))
                rows.append((fn, ai, axis, dim, ci, cname, tid, src_inst, lev, f, alphas[f]))
                n += 1
            orig = f'a0_original0_c{ci}_{cname}{tid}_inst{src_inst}_level0.jpg'
            if not os.path.exists(os.path.join(a.out, orig)):
                shutil.copyfile(os.path.join(sdir, 'f000.jpg'), os.path.join(a.out, orig))
                rows.append((orig, 0, 'original', 0, ci, cname, tid, src_inst, 0, 0, alphas[0]))
                n += 1

with open(os.path.join(a.out, 'stimset_map.csv'), 'w') as fh:
    fh.write('file,axis_idx,axis_name,spose_dim,concept_idx,concept_name,things_id,inst,level,source_frame,alpha\n')
    for r in rows:
        fh.write(','.join(map(str, r[:-1])) + f',{r[-1]:.2f}\n')
print(f'{n} images -> {a.out}')
