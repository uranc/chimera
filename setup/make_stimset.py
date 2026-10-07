#!/usr/bin/env python3
"""Build one session's stimulus folder from the generated morph sequences.

Source (cso/_pending_stimuli_realvis_cn_preview_all12):
    <axis-name>/c<things_id>_<concept>_inst<i>/f000.jpg .. f006.jpg + dense_alphas.npy
    f000 = original (alpha 0); f001..f006 = generated (alpha 0.9 .. 5.5)

Output: one folder per subject, stimuli/subject<NNN>/, holding
    subject<NNN>_stimset<NN>/   the session's generated images (flat):
    a<a>_<axisname><dim>_c<c>_<conceptname><things>_inst<k>_level<L>.jpg
        a      = axis index in this set (1..8, in SPoSE order; sent on the daq)
        dim    = SPoSE dimension number (1..66, 66-d embedding)
        c      = concept index in this set (1..n, in THINGS order; sent on the daq)
        things = THINGS concept number (1..1854, unique_id.txt order)
        k      = source instance, L = 1..3 generated level (frames 2, 4, 6)
        e.g. a8_outdoors13_c1_glove681_inst0_level2.jpg (names without dashes: metallicartificial1)
        stimset_map.csv   per file: indices, SPoSE dim, THINGS number, instance, frame, alpha
    originals/a0_original0_c<c>_<conceptname><things>_inst<k>_level0.jpg
        the original photos (identical on every axis, stored once; mini-screening)
    practice/   practice images (--practice), concepts outside the sessions
Concept names must not end in a digit (the THINGS number follows directly).

Patient session (THINGS numbers of the screened concepts):
    python3 setup/make_stimset.py --subject 1 --stimset 1 --concepts 681 887 344 575
    -> stimuli/subject001/subject001_stimset01/ + stimuli/subject001/originals/
       (run_chimera_eye(1, 1) reads them by default)
Practice images for that subject (other concepts, one instance):
    python3 setup/make_stimset.py --subject 1 --practice --concepts 1092 117 --inst 0
Any other folder: --out <dir> (originals then go to <dir>/originals)
"""
import argparse, glob, os, shutil, sys
from PIL import Image
import numpy as np

SRC = os.path.join(os.path.dirname(__file__), '..', '..', 'cso', '_pending_stimuli_realvis_cn_preview_all12')
# 8 axes (of the 12 generated; water, weapon, body/people, house left out),
# in SPoSE order -> a1..a8
AXES = [(1, 'metallic-artificial'), (2, 'food-related'), (3, 'animal-related'), (5, 'plant-related'),
        (12, 'colorful-playful'), (13, 'outdoors'), (40, 'bug-related-non-mammalian-disgusting'),
        (54, 'child--toy-related-cute')]
def word(name):
    """one block of text for file names: drop dashes and anything non-alphanumeric"""
    return ''.join(ch for ch in name if ch.isalnum())

FRAMES = [2, 4, 6]          # levels 1..3: evenly spaced generated frames incl. the maximum
THINGS_IMAGES = os.path.expanduser('~/Documents/THINGS-database/osfstorage/images_THINGS/object_images')
RES = 1024                  # generated image size; originals are resized to it
LABELS = os.path.join(os.path.dirname(__file__), '..', 'functions', 'chimera_labels.m')
FONTS = ['/usr/share/fonts/truetype/liberation/LiberationSans-Regular.ttf', 'C:/Windows/Fonts/arial.ttf',
         '/Library/Fonts/Arial.ttf', '/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf']


def german_label(key):
    """on-screen German word for a file-name key, from functions/chimera_labels.m"""
    import re
    for k, v in re.findall(r"map\('(\w+)'\)\s*=\s*'([^']*)'", open(LABELS, encoding='utf-8').read()):
        if k == key:
            return v
    sys.exit(f'no German label for {key} in chimera_labels.m')


def name_image(text, path):
    """the written name, white on black, RES x RES (mini-screening name trials)"""
    from PIL import ImageDraw, ImageFont
    font = ImageFont.truetype(next(f for f in FONTS if os.path.exists(f)), 110)
    im = Image.new('RGB', (RES, RES), 0)
    d = ImageDraw.Draw(im)
    x0, y0, x1, y1 = d.textbbox((0, 0), text, font=font)
    d.text(((RES - (x1 - x0)) / 2 - x0, (RES - (y1 - y0)) / 2 - y0), text, fill=(255, 255, 255), font=font)
    im.save(path, quality=95)
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
ap.add_argument('--frames', type=int, nargs='*', help='generated frames used as levels 1..n (default 2 4 6; practice: 6 = max only)')
ap.add_argument('--things-images', default=THINGS_IMAGES)
ap.add_argument('--n-originals', type=int, default=12, help='THINGS photos per concept in originals/ (default 12)')
ap.add_argument('--seed', type=int, default=1)
ap.add_argument('--inst', type=int, nargs='*', default=[0], help='source instances to copy (default: 0; one instance per stimset)')
a = ap.parse_args()
if a.frames is None:
    a.frames = [FRAMES[-1]] if a.practice else FRAMES
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
concepts = sorted(a.concepts or names)   # c1..cn in THINGS order (axes a1..a8 in SPoSE order)
missing = [c for c in concepts if c not in names]
if missing:
    sys.exit(f'THINGS numbers not among the generated concepts: {missing}')

os.makedirs(a.out, exist_ok=True)
rows, n = [], 0
bad = [names[t] for t in concepts if word(names[t])[-1].isdigit()]
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
            for lev, f in enumerate(a.frames, start=1):
                fn = f'a{ai}_{word(axis)}{dim}_c{ci}_{word(cname)}{tid}_inst{src_inst}_level{lev}.jpg'
                shutil.copyfile(os.path.join(sdir, f'f{f:03d}.jpg'), os.path.join(a.out, fn))
                rows.append((fn, ai, word(axis), dim, ci, word(cname), tid, src_inst, lev, f, alphas[f]))
                n += 1
    if orig_dir:
        # originals: the first n THINGS photos of the concept (sorted, as the generator indexes
        # them: inst k = photo k, so inst0 is the photo the chimera images were made from),
        # resized to the generated resolution; mini-screening = original + exemplars
        photos = sorted(glob.glob(os.path.join(a.things_images, cname, f'{cname}_*.jpg')))[:a.n_originals]
        if len(photos) < a.n_originals:
            print(f'warning: only {len(photos)} THINGS photos for {cname}')
        for src_inst, ph in enumerate(photos):
            orig = f'a0_original0_c{ci}_{word(cname)}{tid}_inst{src_inst}_level0.jpg'
            # one copy per concept: skip if an earlier stimset already wrote it (under its own c index)
            if not glob.glob(os.path.join(orig_dir, f'a0_original0_c*_{word(cname)}{tid}_inst{src_inst}_level0.jpg')):
                os.makedirs(orig_dir, exist_ok=True)
                Image.open(ph).convert('RGB').resize((RES, RES), Image.LANCZOS).save(os.path.join(orig_dir, orig), quality=95)
                rows.append(('../originals/' + orig, 0, 'original', 0, ci, word(cname), tid, src_inst, 0, 0, 0.0))
                n += 1
        # the written name (mini-screening), one per concept
        nm = f'a0_name0_c{ci}_{word(cname)}{tid}_inst0_level0.jpg'
        if not glob.glob(os.path.join(orig_dir, f'a0_name0_c*_{word(cname)}{tid}_inst0_level0.jpg')):
            name_image(german_label(word(cname)), os.path.join(orig_dir, nm))
            rows.append(('../originals/' + nm, 0, 'name', 0, ci, word(cname), tid, 0, 0, 0, 0.0))
            n += 1

with open(os.path.join(a.out, 'stimset_map.csv'), 'w') as fh:
    fh.write('file,axis_idx,axis_name,spose_dim,concept_idx,concept_name,things_id,inst,level,source_frame,alpha\n')
    for r in rows:
        fh.write(','.join(map(str, r[:-1])) + f',{r[-1]:.2f}\n')
print(f'{n} images -> {a.out}')
