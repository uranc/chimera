# Literature map: generative stimuli x psychophysics x human single neurons (2026-10-01)

## Core set and what each holds
| paper | stimuli | control variable | task | neural | closed loop |
|---|---|---|---|---|---|
| Hu et al. 2026 arXiv 2603.24730 | SD1.5, CLIP text-embedding interpolation | alpha between two prompts, 5 levels x 6 guidance | 2AFC endpoint labels, 500 ms, psignifit | none | no |
| Karkowski/Mormann 2025 bioRxiv | real THINGS photos | THINGS/SPoSE embedding (25-D PCA) | liftable/not, image until key | human MTL single units, 15 pts, 2835 units | yes: next stimuli = neighbours of responsive ones |
| Mathew/Rey 2025 bioRxiv | real photos | none | screening | human MTL units | yes: online add/drop stimuli |
| CoCoG / CoCoG-2 (Liu lab 2024) | diffusion from 42-D concept embedding | SPoSE-like dims | 2AFC similarity (simulated only) | none | no |
| Cao/Liu 2025 arXiv 2507.22067 | CoCoG image/dimension wheels | 2 SPoSE dims on a circle | WM report + similarity, confidence | none | no |
| Pettini/Haynes 2025 BRM | SDXL, prompt fixed, latent interpolated | LPIPS-ordered perceptual continuum | WM, online ratings | none | no |
| Boger & Firestone 2025 Curr Biol | diffusion visual anagrams | orientation flips concept, pixels fixed | size judgments | none | no |
| Quian Quiroga 2014 Neuron | face morphs + adaptor | morph %, adaptation | who is it, forced choice | human MTL units | no |
| Freedman 2001/2002 | cat/dog morphs | 20/40/60/80 % | DMC | macaque PFC/IT | no |
| Mueller/Ponce 2023 PNAS | XDream GAN prototypes from IT | evolved latents | 2AFC saccade "monkey?" | macaque IT | yes (offline evolve), behaviour on result |
| Scott 2025 EJN | CIFAR GAN | 128-D latent, PSO/GA | fixation | macaque V1/V4 | yes, real time |
| Henderson/Wehbe 2026 bioRxiv (BrainDiVE prospective) | diffusion under fMRI-encoder guidance | ROI objective | passive | human fMRI, 12 new subj | no (prospective) |
| BrainACTIV 2025 ICLR | IP-Adapter + SDEdit, CLIP slerp | "brain-optimal" direction | none | fMRI encoders in silico | no |
| Lad/Tolias 2026 arXiv | digital twin -> VLM caption -> T2I | language hypotheses | none | macaque V1/V4 twins | loop vs twin |
| MindPilot (Liu lab 2026) | EEG-guided diffusion | black-box brain | retrieval/matching | human EEG | yes |
| Kreiman 2025 bioRxiv | Mooney images | learned vs not | recognition report | human occipital + MTL units | no |
| Kamada 2026 | standard pictures | ECS timing | overt naming, voice onset | ECoG | no |
| Xu 2023 PAQ | generative latent path | slider | adjustment query | none | no |
| Maniquet/Op de Beeck 2026 | photos | category | yes/no membership | fMRI distance-to-bound | no |
| Kramer/Bainbridge 2023 | THINGS photos | 49 dims | memory | none | no |

## Shared backbone (appears in 2+ reference lists of the core set)
Hebart 2020 NHB (SPoSE), Hebart 2023 eLife (THINGS-data), Muttenthaler 2022/2023 (VICE, alignment),
Roads & Love 2021, Feather/McDermott metamers 2019, Geirhos 2018/2020, Kubilius CORnet, Peterson 2019 human
uncertainty, Wichmann & Hill 2001 + psignifit 4, Freedman 2001, Quian Quiroga 2005/2014, Leopold & Logothetis
bistability, Ho & Salimans CFG, Radford CLIP, Rombach LDM, Fu DreamSim 2023, Zhang LPIPS.

## Consistent across all
1. Semantic space = THINGS/SPoSE or CLIP; everybody uses one of these two, often both.
2. Generator = diffusion with CLIP conditioning (SD1.5/SDXL, IP-Adapter, CFG); GANs only in the macaque work.
3. Continuum = linear interpolation of an embedding, 5-11 levels, endpoints as anchors.
4. Behaviour = 2AFC or button press; psychometric fit = logistic (psignifit); no feedback mid-continuum.
5. Single-unit trial = jittered blank 200-400 ms, fixation 300 ms, image until key, orthogonal task.
6. Validation of generators = in silico or held-out encoder; prospective presentation is the exception.
7. Neural readout = sigmoid tuning vs similarity to a peak (Mormann) or MEI/activation (Ponce, Wehbe).

## What differs (axes of variation)
- interpolation axis: prompt-to-prompt (Hu), SPoSE dimension (CoCoG/Cao, you), brain-optimal (BrainACTIV), latent noise (Pettini)
- what is fixed: visuals (your stack, BrainACTIV), semantics (Pettini), pixels (anagrams)
- who closes the loop: neuron (Ponce/Scott/Mormann), fMRI encoder (BrainDiVE), EEG (MindPilot), nobody (psychophysics papers)
- report: 2AFC, rating, slider, one-back, liftable, naming (only in ECoG mapping)
- species/signal: macaque units, human units, fMRI, EEG, behaviour only
- where the dissociation is computed: model vs human (metamers, controversial stimuli), neuron vs monkey report (Mueller), never neuron vs human report on a generative axis

## Empty cells (nobody found)
- generator inside a human single-unit loop (Mormann/Rey loops pick from a fixed bank)
- SPoSE-dimension-conditioned morphs with any neural data
- generated continuum + overt naming + single units
- neural 50 % point vs behavioural 50 % point on the same generative axis (neuron-vs-report dissociation in humans)
- concept cell -> language hypothesis -> generated probe set -> test (Lad et al. do it with macaque twins)

## Code (actively maintained, directly usable)
Psychtoolbox-3, dcnieho/Titta, python-psignifit, hoechenberger/questplus, thingsvision, THINGS-data, DreamSim,
LPIPS, whisperX, Montreal-Forced-Aligner, SpikeInterface, Open Ephys plugin-GUI (+spike-sorter, RT-Stat), LSL,
Bonsai, combinato, Rutishauser NWB releases. Research-grade: CoCoG/CoCoG-2, XDream, VICE/SPoSE, BrainDiVE,
mQUESTPlus. No public code: real-time human-SU sorter wired to a stimulus server; morph-continuum toolkit;
naming scorer (assemble whisperX + MFA).

## Talks worth watching
Wang & Ponce 2026 "When Neurons Generate Images" https://www.youtube.com/watch?v=PVdDCdChSys
Ponce 2019 "Visual Alphabet 2.0" https://cbmm.mit.edu/video/visual-alphabet-20-3257
DiCarlo/Bashivan 2019 population control https://www.youtube.com/watch?v=lUazMZ9jSV8
Hebart THINGS initiative https://www.youtube.com/watch?v=DsVfyyDK4RQ
Quian Quiroga FENS 2016 concept cells https://www.youtube.com/watch?v=Y1ID0FQN9tg
Rutishauser "Neurons Don't Work Alone" https://www.youtube.com/watch?v=ZZJJDhdQSlw
Muttenthaler CoCoNUT 2025 alignment https://www.cbs.mpg.de/cbs-coconut/lukas-muttenthaler
Firestone "Borderlands of Perception" https://manyminds.libsyn.com/the-borderlands-of-perception
CCN 2025 playlist https://www.youtube.com/playlist?list=PLNWftEg2R4s5zcdIhMyPLCKfb92k-XffU
Cosyne 2026 closed-loop workshop https://closed-loop-2026.github.io/

## Key URLs
Karkowski 2025 https://www.biorxiv.org/content/10.1101/2025.10.21.682935v1
Mathew/Rey 2025 https://www.biorxiv.org/content/10.1101/2025.07.07.663330v1
Henderson/Wehbe 2026 https://www.biorxiv.org/content/10.64898/2026.05.12.724119v1
BrainACTIV https://www.biorxiv.org/content/10.1101/2024.10.29.620889v2.full
Lad/Tolias 2026 https://arxiv.org/abs/2605.12485
MindPilot https://arxiv.org/abs/2602.10552
Mueller/Ponce 2023 https://www.pnas.org/doi/10.1073/pnas.2213034120
Kreiman 2025 https://www.biorxiv.org/content/10.1101/2025.08.04.668333v1.full
Blending concepts 2026 https://arxiv.org/abs/2506.23630
TPIPS https://arxiv.org/abs/2607.18237
Whisper naming scoring https://arxiv.org/pdf/2507.17326
CoCoG code https://github.com/ncclab-sustech/CoCoG  XDream https://github.com/willwx/XDream
