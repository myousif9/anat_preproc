anat_preproc
============

Snakebids pipeline for anatomical preprocessing with [3dMPRAGEise](10.5281/zenodo.4626825), [synthstrip](https://doi.org/10.1016/j.neuroimage.2022.119474), [fMRIPrep](https://doi.org/10.1038/s41592-018-0235-4) and [ciftify](https://doi.org/10.5281/zenodo.2586104).

![Pipeline desctiption](docs/images/anat_preproc_pipeline.png)

Inputs
=======

- Bids dataset with:
  - MP2RAGE data (uni and inv2)
  - T2w (optional and currently doesn't work)
  - *Note*: it is recommended that inputed data is gradient distortion and B1 field corrected)
- dependencies:
  - python:
    - snakebids: https://github.com/akhanf/snakebids
  - singularity containers:
    - AFNI: https://hub.docker.com/r/afni/afni_make_build
    - Ciftify: https://hub.docker.com/r/tigrlab/fmriprep_ciftify
    - fMRIPrep: https://hub.docker.com/r/nipreps/fmriprep/
    - synthstrip: https://hub.docker.com/r/freesurfer/synthstrip
  