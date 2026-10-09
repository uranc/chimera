#!/usr/bin/env python3
"""Build one session's stimulus folder from the generated morph sequences.

Source (production set, /mnt/data/cso_prod/FINAL):
    <concept>/<concept>_i<ii>/<axis-name>/axis_sphere/L0.jpg .. L3.jpg (+ past.jpg)
    <concept>/manifest.csv   per level: source frame and steering parameter
    L0 = start (original), L1..L3 = the calibrated generated levels; concept
    folders are THINGS names (unique_id.txt)

Output: one folder per subject, stimuli/subject<NNN>/, holding
    subject<NNN>_stimset<NN>/   the session's generated images (flat):
    a<a>_<axisname><dim>_c<c>_<conceptname><things>_inst<k>_level<L>.jpg
        a      = axis index in this set (1..8, in SPoSE order; sent on the daq)
        dim    = SPoSE dimension number (1..66, 66-d embedding)
        c      = concept index in this set (1..n, in THINGS order; sent on the daq)
        things = THINGS concept number (1..1854, unique_id.txt order)
        k      = source instance, L = 1..3 generated level (source L1..L3; --levels)
        e.g. a8_outdoors13_c1_glove681_inst0_level2.jpg (names without dashes: metallicartificial1)
        stimset_map.csv   per file: indices, SPoSE dim, THINGS number, instance, source level, frame, parameter
    originals/a0_original0_c<c>_<conceptname><things>_inst<k>_level0.jpg
        the original photos (identical on every axis, stored once; mini-screening)
    practice/   practice images (--practice), concepts outside the sessions
THINGS sense digits are dropped from concept names (baton4 -> baton); the THINGS number follows directly.

Patient session (THINGS numbers of the screened concepts):
    python3 setup/make_stimset.py --subject 1 --stimset 1 --concepts 98 170 824 937
    -> stimuli/subject001/subject001_stimset01/ + stimuli/subject001/originals/
       (run_chimera_eye(1, 1) reads them by default)
Practice images for that subject (other concepts, one instance):
    python3 setup/make_stimset.py --subject 1 --practice --concepts 1504 1691
Two levels (e.g. mid and max): --levels 2 3
Any other folder: --out <dir> (originals then go to <dir>/originals)
"""
import argparse, glob, os, shutil, sys
from PIL import Image
import numpy as np

SRC = '/mnt/data/cso_prod/FINAL'
# 8 axes (of the 12 generated; water, weapon, body/people, house left out),
# in SPoSE order -> a1..a8
AXES = [(1, 'metallic-artificial'), (2, 'food-related'), (3, 'animal-related'), (5, 'plant-related'),
        (12, 'colorful-playful'), (13, 'outdoors'), (40, 'bug-related-non-mammalian-disgusting'),
        (54, 'child--toy-related-cute')]
def word(name):
    """one block of text for file names: drop dashes and anything non-alphanumeric"""
    return ''.join(ch for ch in name if ch.isalnum())


def cword(name):
    """concept name for file names: one block of text without a trailing THINGS sense digit
    (baton4 -> baton, button1 -> button); the THINGS number after it keeps it unique"""
    return word(name).rstrip('0123456789')

LEVELS = [1, 2, 3]          # source levels L1..L3 -> level 1..3 (practice: L3 only)
RAY = 'axis_sphere'
THINGS_IMAGES = os.path.expanduser('~/Documents/THINGS-database/osfstorage/images_THINGS/object_images')
RES = 1024                  # generated image size; originals are resized to it
LABELS = os.path.join(os.path.dirname(__file__), '..', 'functions', 'chimera_labels.m')
# written-name images exactly as dynamic's create_text_stimuli.py (Helvetica, 288 px,
# font size 0.1 x image size, white on black, matplotlib); Helvetica from the dynamic repo
NAME_FONTS = [os.path.join(os.path.dirname(__file__), '..', '..', '..', 'dynamic', 'code', 'stimulus_preparation', 'fonts', 'Helvetica.ttf'),
              os.path.expanduser('~/Documents/dynamic/code/stimulus_preparation/fonts/Helvetica.ttf'),
              '/usr/share/fonts/truetype/liberation/LiberationSans-Regular.ttf']
NAME_IMAGE_SIZE = 288
NAME_FONT_SIZE_RATIO = 0.1


def german_label(key):
    """on-screen German word for a file-name key, from functions/chimera_labels.m"""
    import re
    for k, v in re.findall(r"map\('(\w+)'\)\s*=\s*'([^']*)'", open(LABELS, encoding='utf-8').read()):
        if k == key:
            return v
    sys.exit(f'no German label for {key} in chimera_labels.m')


def name_image(text, path):
    """the written name as in dynamic's create_text_stimuli.py (mini-screening name trials)"""
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    from matplotlib import font_manager as fm
    font_path = next(f for f in NAME_FONTS if os.path.exists(f))
    if 'Helvetica' not in font_path:
        print(f'warning: Helvetica not found, using {font_path}')
    font = fm.FontProperties(fname=font_path)
    dpi = 100
    edge = NAME_IMAGE_SIZE / dpi
    fig = plt.figure(figsize=(edge, edge), dpi=dpi)
    ax = fig.add_axes([0, 0, 1, 1])
    ax.set_aspect('equal', 'box')
    ax.set_facecolor('black')
    ax.text(0.5, 0.5, text, horizontalalignment='center', verticalalignment='center', color='white',
            fontsize=NAME_IMAGE_SIZE * NAME_FONT_SIZE_RATIO, fontproperties=font, transform=ax.transAxes)
    ax.set_xticks([]); ax.set_yticks([]); ax.set_axis_off()
    plt.savefig(path, facecolor='black', format='jpg', dpi=dpi)
    plt.close(fig)


THINGS_IDS = os.path.expanduser('~/Documents/THINGS-database/behavior/variables/unique_id.txt')

ap = argparse.ArgumentParser()
ap.add_argument('--src', default=SRC)
ap.add_argument('--out', help='output folder (default: stimuli/subject<NNN>_stimset<NN>)')
ap.add_argument('--subject', type=int)
ap.add_argument('--stimset', type=int)
ap.add_argument('--practice', action='store_true', help='write the subject practice folder (no originals)')
ap.add_argument('--concepts', type=int, nargs='*', help='THINGS concept numbers (default: all available)')
ap.add_argument('--things', default=THINGS_IDS, help='THINGS unique_id.txt (concept order)')
ap.add_argument('--random', type=int, help='pick this many random concepts instead')
ap.add_argument('--levels', type=int, nargs='*', help='source levels L1..L3 used as levels 1..n (default 1 2 3; practice: 3 = max only)')
ap.add_argument('--things-images', default=THINGS_IMAGES)
ap.add_argument('--n-originals', type=int, default=12, help='THINGS photos per concept in originals/ (default 12)')
ap.add_argument('--seed', type=int, default=1)
ap.add_argument('--inst', type=int, nargs='*', default=[0], help='source instances to copy (default: 0; one instance per stimset)')
a = ap.parse_args()
if a.levels is None:
    a.levels = [LEVELS[-1]] if a.practice else LEVELS
orig_dir = None
if a.out is None:
    if a.subject is None or (a.stimset is None and not a.practice):
        sys.exit('give --subject and --stimset (or --subject --practice, or --out)')
    subj = os.path.join(os.path.dirname(__file__), '..', 'stimuli', f'subject{a.subject:03d}')
    a.out = os.path.join(subj, 'practice') if a.practice else os.path.join(subj, f'subject{a.subject:03d}_stimset{a.stimset:02d}')
    orig_dir = None if a.practice else os.path.join(subj, 'originals')
elif not a.practice:
    orig_dir = os.path.join(a.out, 'originals')

# generated concepts -> THINGS number (1-based line in unique_id.txt)
things = {n.strip(): i + 1 for i, n in enumerate(open(a.things)) if n.strip()}
names = {}
for cname in sorted(os.listdir(a.src)):
    if not os.path.isdir(os.path.join(a.src, cname)):
        continue
    if cname not in things:
        sys.exit(f'{cname} is not a THINGS concept')
    names[things[cname]] = cname


def manifest(cname):
    """(inst, axis, level name) -> (frame, parameter) from <concept>/manifest.csv"""
    import csv
    m = {}
    with open(os.path.join(a.src, cname, 'manifest.csv')) as fh:
        for r in csv.DictReader(fh):
            if r['ray'] == RAY:
                m[(int(r['inst']), r['axis'], r['level'])] = (int(r['frame']), float(r['param']))
    return m


if a.random:
    a.concepts = sorted(np.random.default_rng(a.seed).choice(sorted(names), a.random, replace=False).tolist())
    print(f'random concepts (seed {a.seed}): {a.concepts}')
concepts = sorted(a.concepts or names)   # c1..cn in THINGS order (axes a1..a8 in SPoSE order)
missing = [c for c in concepts if c not in names]
if missing:
    sys.exit(f'THINGS numbers not among the generated concepts: {missing}')

os.makedirs(a.out, exist_ok=True)
rows, n = [], 0
for ci, tid in enumerate(concepts, start=1):
    cname = names[tid]
    man = manifest(cname)
    for ai, (dim, axis) in enumerate(AXES, start=1):
        insts = sorted(int(q.rsplit('_i', 1)[1]) for q in os.listdir(os.path.join(a.src, cname))
                       if q.startswith(f'{cname}_i') and os.path.isdir(os.path.join(a.src, cname, q)))
        if a.inst is not None:
            insts = [i for i in insts if i in a.inst]
        for src_inst in insts:
            sdir = os.path.join(a.src, cname, f'{cname}_i{src_inst:02d}', axis, RAY)
            for lev, L in enumerate(a.levels, start=1):
                src = os.path.join(sdir, f'L{L}.jpg')
                if not os.path.exists(src):
                    sys.exit(f'missing {src}')
                frame, param = man.get((src_inst, axis, f'L{L}'), (-1, float('nan')))
                if param == 0:
                    print(f'warning: {cname} {axis} L{L} is the unsteered start image (parameter 0)')
                fn = f'a{ai}_{word(axis)}{dim}_c{ci}_{cword(cname)}{tid}_inst{src_inst}_level{lev}.jpg'
                shutil.copyfile(src, os.path.join(a.out, fn))
                rows.append((fn, ai, word(axis), dim, ci, cword(cname), tid, src_inst, f'L{L}', frame, param))
                n += 1
    if orig_dir:
        # originals: the first n THINGS photos of the concept (sorted, as the generator indexes
        # them: inst k = photo k, so inst0 is the photo the chimera images were made from),
        # resized to the generated resolution; mini-screening = original + exemplars
        photos = sorted(glob.glob(os.path.join(a.things_images, cname, f'{cname}_*.jpg')))[:a.n_originals]
        if len(photos) < a.n_originals:
            print(f'warning: only {len(photos)} THINGS photos for {cname}')
        for src_inst, ph in enumerate(photos):
            orig = f'a0_original0_c{ci}_{cword(cname)}{tid}_inst{src_inst}_level0.jpg'
            # one copy per concept: skip if an earlier stimset already wrote it (under its own c index)
            if not glob.glob(os.path.join(orig_dir, f'a0_original0_c*_{cword(cname)}{tid}_inst{src_inst}_level0.jpg')):
                os.makedirs(orig_dir, exist_ok=True)
                Image.open(ph).convert('RGB').resize((RES, RES), Image.LANCZOS).save(os.path.join(orig_dir, orig), quality=95)
                rows.append(('../originals/' + orig, 0, 'original', 0, ci, cword(cname), tid, src_inst, 'L0', 0, 0.0))
                n += 1
        # the written name (mini-screening), one per concept
        nm = f'a0_name0_c{ci}_{cword(cname)}{tid}_inst0_level0.jpg'
        if not glob.glob(os.path.join(orig_dir, f'a0_name0_c*_{cword(cname)}{tid}_inst0_level0.jpg')):
            name_image(german_label(cword(cname)), os.path.join(orig_dir, nm))
            rows.append(('../originals/' + nm, 0, 'name', 0, ci, cword(cname), tid, 0, 'name', 0, 0.0))
            n += 1

with open(os.path.join(a.out, 'stimset_map.csv'), 'w') as fh:
    fh.write('file,axis_idx,axis_name,spose_dim,concept_idx,concept_name,things_id,inst,source_level,source_frame,param\n')
    for r in rows:
        fh.write(','.join(map(str, r[:-1])) + f',{r[-1]:.4f}\n')
print(f'{n} images -> {a.out}')
