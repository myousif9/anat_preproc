anat_preproc
============

Snakebids pipeline for anatomical preprocessing with [gradcorrect](https://github.com/myousif9/gradcorrect), [3dMPRAGEise](10.5281/zenodo.4626825), [synthstrip](https://doi.org/10.1016/j.neuroimage.2022.119474), [fMRIPrep](https://doi.org/10.1038/s41592-018-0235-4) and [ciftify](https://doi.org/10.5281/zenodo.2586104).

![Pipeline desctiption](docs/images/anat_preproc_pipeline.png)

Inputs
=======

- Bids dataset with:
  - MP2RAGE data (uni and inv2)
  - T2w (will be added soon)
  
- dependencies:
  - python:
    - snakebids: https://github.com/akhanf/snakebids
  - singularity containers:
    - AFNI: https://hub.docker.com/r/afni/afni_make_build
    - Ciftify: https://hub.docker.com/r/tigrlab/fmriprep_ciftify
    - fMRIPrep: https://hub.docker.com/r/nipreps/fmriprep/
    - gradcorrect: https://hub.docker.com/r/khanlab/gradcorrect
    - synthstrip: https://hub.docker.com/r/freesurfer/synthstrip
  
Usage
======
1. Create and activate virtual environment minimum python version >= 3.7 and install snakebids version == 0.6.2

   - on Compute Canada: 
  
      ```
      module load python/3.8
      virtualenv --no-download your_virtual_env_name_here
      source your_virtual_env_name_here/bin/activate
      pip install snakebids==0.6.2

      ```
2. Change directory to `anat_preproc/anat_preproc` (to be in same directory as `run.py` file).
   - `cd anat_preproc/anat_preproc`
   
3. Use below listed run options to run pipeline. 
   - Skipping gradient distortion correction:
  `python run.py bids_dir out_dir participant`

   - running  gradient correction:  `python run.py bids_dir out_dir participant --grad_coef your_grad_coef_file.grad`
  
   - on Compute Canada you can use https://github.com/khanlab/cc-slurm to submit jobs with SLURM.   `python run.py bids_dir out_dir participant --grad_coef your_grad_coef_file.grad --profile cc-slurm`
  
   - **NOTE**: you are likely going to have to specify inv2 and uni file paths with wildcards in your command given your dataset specific naming conventions.
     - example:
        ```
        python run.py \
        /scratch/myousif9/snsx_inprogress/sourcedata/SNSX_7T/tar2bids_v0.0.5e/bids/ /scratch/myousif9/snsx_inprogress/output/anat_preproc_gradient_corr_test participant  \
        --path-uni /scratch/myousif9/snsx_inprogress/sourcedata/SNSX_7T/tar2bids_v0.0.5e/bids/sub-{subject}/anat/sub-{subject}_acq-UNI_run-01_MP2RAGE.nii.gz \
        --path-inv2 /scratch/myousif9/snsx_inprogress/sourcedata/SNSX_7T/tar2bids_v0.0.5e/bids/sub-{subject}/anat/sub-{subject}_inv-2_run-01_MP2RAGE.nii.gz \
        --participant_label C001 \
        --grad_coef /project/ctb-akhanf/myousif9/gradcorrect_ref_file/coeff_AC84.grad \
        --profile cc-slurm
        ```

### run options:
 ```
(snakemake) [myousif9@gra-login2 anat_preproc]$ python run.py -h
usage: run.py [-h] [--pybidsdb-dir PYBIDSDB_DIR] [--reset-db] [--force-output]
              [--help-snakemake]
              [--participant-label PARTICIPANT_LABEL [PARTICIPANT_LABEL ...]]
              [--exclude_participant_label EXCLUDE_PARTICIPANT_LABEL [EXCLUDE_PARTICIPANT_LABEL ...]]
              [--derivatives DERIVATIVES [DERIVATIVES ...]]
              [--fs_license FS_LICENSE] [--grad_coef GRAD_COEF]
              [--filter-uni FILTER_UNI [FILTER_UNI ...]]
              [--filter-inv2 FILTER_INV2 [FILTER_INV2 ...]]
              [--wildcards-uni WILDCARDS_UNI [WILDCARDS_UNI ...]]
              [--wildcards-inv2 WILDCARDS_INV2 [WILDCARDS_INV2 ...]]
              [--path-uni PATH_UNI] [--path-inv2 PATH_INV2]
              bids_dir output_dir {participant}

Snakebids helps build BIDS Apps with Snakemake

optional arguments:
  -h, --help            show this help message and exit

STANDARD:
  Standard options for all snakebids apps

  --pybidsdb-dir PYBIDSDB_DIR, --pybidsdb_dir PYBIDSDB_DIR
                        Optional path to directory of SQLite databasefile for
                        PyBIDS. If directory is passed and folder exists,
                        indexing is skipped. If reset_db is called, indexing
                        will persist
  --reset-db, --reset_db
                        Reindex existing PyBIDS SQLite database
  --force-output, --force_output
                        Force output in a new directory that already has
                        contents
  --help-snakemake, --help_snakemake
                        Options to Snakemake can also be passed directly at
                        the command-line, use this to print Snakemake usage

SNAKEBIDS:
  Options for snakebids app

  bids_dir              The directory with the input dataset formatted
                        according to the BIDS standard.
  output_dir            The directory where the output files should be stored.
                        If you are running group level analysis this folder
                        should be prepopulated with the results of the
                        participant level analysis.
  {participant}         Level of the analysis that will be performed.
  --participant-label PARTICIPANT_LABEL [PARTICIPANT_LABEL ...], --participant_label PARTICIPANT_LABEL [PARTICIPANT_LABEL ...]
                        The label(s) of the participant(s) that should be
                        analyzed. The label corresponds to
                        sub-<participant_label> from the BIDS spec (so it does
                        not include "sub-"). If this parameter is not provided
                        all subjects should be analyzed. Multiple participants
                        can be specified with a space separated list.
  --exclude_participant_label EXCLUDE_PARTICIPANT_LABEL [EXCLUDE_PARTICIPANT_LABEL ...], --exclude-participant-label EXCLUDE_PARTICIPANT_LABEL [EXCLUDE_PARTICIPANT_LABEL ...]
                        The label(s) of the participant(s) that should be
                        excluded. The label corresponds to
                        sub-<participant_label> from the BIDS spec (so it does
                        not include "sub-"). If this parameter is not provided
                        all subjects should be analyzed. Multiple participants
                        can be specified with a space separated list.
  --derivatives DERIVATIVES [DERIVATIVES ...]
                        Path(s) to a derivatives dataset, for folder(s) that
                        contains multiple derivatives datasets (default:
                        False)
  --fs_license FS_LICENSE, --fs-license FS_LICENSE
                        Provide path to freesurfer license text file.
  --grad_coef GRAD_COEF, --grad-coef GRAD_COEF
                        Provide path to gradient correction coefficient file.
                        Gradient correction dis skipped if file is not
                        specified.

BIDS FILTERS:
  Filters to customize PyBIDS get() as key=value pairs

  --filter-uni FILTER_UNI [FILTER_UNI ...], --filter_uni FILTER_UNI [FILTER_UNI ...]
                        (default: suffix=MP2RAGE extension=.nii.gz
                        datatype=anat acquisition=UNI invalid_filters=allow
                        echo=None)
  --filter-inv2 FILTER_INV2 [FILTER_INV2 ...], --filter_inv2 FILTER_INV2 [FILTER_INV2 ...]
                        (default: suffix=MP2RAGE extension=.nii.gz
                        datatype=anat inv=2 invalid_filters=allow echo=None)

INPUT WILDCARDS:
  File path entities to use as wildcards in snakemake

  --wildcards-uni WILDCARDS_UNI [WILDCARDS_UNI ...], --wildcards_uni WILDCARDS_UNI [WILDCARDS_UNI ...]
                        (default: subject session acquisition task run)
  --wildcards-inv2 WILDCARDS_INV2 [WILDCARDS_INV2 ...], --wildcards_inv2 WILDCARDS_INV2 [WILDCARDS_INV2 ...]
                        (default: subject session acquisition task run)

PATH OVERRIDE:
  Options for overriding BIDS by specifying absolute paths that include
  wildcards, e.g.: /path/to/my_data/{subject}/t1.nii.gz

  --path-uni PATH_UNI, --path_uni PATH_UNI
  --path-inv2 PATH_INV2, --path_inv2 PATH_INV2
 ```
  Outputs
  ========
  ### Directory structure for single subject run:
  ```
  anat_preproc_gradient_corr_test/
├── config
├── derivatives
│   ├── 3dmprageise
│   ├── ciftify
│   ├── fmriprep
│   ├── gradcorrect
│   └── synthstrip
├── logs
│   ├── slurm
│   └── sub-C001
└── work
    ├── fmriprep
    └── sub-C001

  ```

### Directory structure of derivatives:
```
derivatives/
├── 3dmprageise
│   └── sub-C001
│       └── anat
│           └── sub-C001_desc-mprageise_T1w.nii.gz
├── ciftify
│   ├── qc_recon_all
│   │   ├── aseg_Ax.html
│   │   ├── aseg_Cor.html
│   │   ├── aseg_Sag.html
│   │   ├── index.html
│   │   ├── MNI_LM.html
│   │   ├── MNI_LRDV.html
│   │   ├── MNI_surf_Ax.html
│   │   ├── MNI_surf_Cor.html
│   │   ├── MNI_surf_Sag.html
│   │   └── sub-C001
│   │       ├── aparc.png
│   │       ├── aseg_Ax.png
│   │       ├── aseg_Cor.png
│   │       ├── aseg_Sag.png
│   │       ├── curv.png
│   │       ├── MNI_LM.png
│   │       ├── MNI_LRDV.png
│   │       ├── MNI_surf_Ax.png
│   │       ├── MNI_surf_Cor.png
│   │       ├── MNI_surf_Sag.png
│   │       ├── native_LRDV.png
│   │       ├── native_surf_Ax.png
│   │       ├── native_surf_Cor.png
│   │       ├── native_surf_Sag.png
│   │       ├── qc.html
│   │       └── thickness.png
│   ├── sub-C001
│   │   ├── cifti_recon_all.log
│   │   ├── MNINonLinear
│   │   │   ├── aparc.a2009s+aseg.nii.gz
│   │   │   ├── aparc+aseg.nii.gz
│   │   │   ├── brainmask_fs.nii.gz
│   │   │   ├── fsaverage_LR32k
│   │   │   │   ├── sub-C001.32k_fs_LR.wb.spec
│   │   │   │   ├── sub-C001.aparc.32k_fs_LR.dlabel.nii
│   │   │   │   ├── sub-C001.aparc.a2009s.32k_fs_LR.dlabel.nii
│   │   │   │   ├── sub-C001.aparc.DKTatlas.32k_fs_LR.dlabel.nii
│   │   │   │   ├── sub-C001.ArealDistortion_FS.32k_fs_LR.dscalar.nii
│   │   │   │   ├── sub-C001.ArealDistortion_MSMSulc.32k_fs_LR.dscalar.nii
│   │   │   │   ├── sub-C001.BA_exvivo.32k_fs_LR.dlabel.nii
│   │   │   │   ├── sub-C001.curvature.32k_fs_LR.dscalar.nii
│   │   │   │   ├── sub-C001.EdgeDistortion_MSMSulc.32k_fs_LR.dscalar.nii
│   │   │   │   ├── sub-C001.L.atlasroi.32k_fs_LR.shape.gii
│   │   │   │   ├── sub-C001.L.flat.32k_fs_LR.surf.gii
│   │   │   │   ├── sub-C001.L.inflated.32k_fs_LR.surf.gii
│   │   │   │   ├── sub-C001.L.midthickness.32k_fs_LR.surf.gii
│   │   │   │   ├── sub-C001.L.pial.32k_fs_LR.surf.gii
│   │   │   │   ├── sub-C001.L.sphere.32k_fs_LR.surf.gii
│   │   │   │   ├── sub-C001.L.very_inflated.32k_fs_LR.surf.gii
│   │   │   │   ├── sub-C001.L.white.32k_fs_LR.surf.gii
│   │   │   │   ├── sub-C001.R.atlasroi.32k_fs_LR.shape.gii
│   │   │   │   ├── sub-C001.R.flat.32k_fs_LR.surf.gii
│   │   │   │   ├── sub-C001.R.inflated.32k_fs_LR.surf.gii
│   │   │   │   ├── sub-C001.R.midthickness.32k_fs_LR.surf.gii
│   │   │   │   ├── sub-C001.R.pial.32k_fs_LR.surf.gii
│   │   │   │   ├── sub-C001.R.sphere.32k_fs_LR.surf.gii
│   │   │   │   ├── sub-C001.R.very_inflated.32k_fs_LR.surf.gii
│   │   │   │   ├── sub-C001.R.white.32k_fs_LR.surf.gii
│   │   │   │   ├── sub-C001.sulc.32k_fs_LR.dscalar.nii
│   │   │   │   └── sub-C001.thickness.32k_fs_LR.dscalar.nii
│   │   │   ├── Native
│   │   │   │   ├── MSMSulc
│   │   │   │   ├── sub-C001.aparc.a2009s.native.dlabel.nii
│   │   │   │   ├── sub-C001.aparc.DKTatlas.native.dlabel.nii
│   │   │   │   ├── sub-C001.aparc.native.dlabel.nii
│   │   │   │   ├── sub-C001.ArealDistortion_FS.native.dscalar.nii
│   │   │   │   ├── sub-C001.ArealDistortion_MSMSulc.native.dscalar.nii
│   │   │   │   ├── sub-C001.BA_exvivo.native.dlabel.nii
│   │   │   │   ├── sub-C001.curvature.native.dscalar.nii
│   │   │   │   ├── sub-C001.EdgeDistortion_MSMSulc.native.dscalar.nii
│   │   │   │   ├── sub-C001.L.inflated.native.surf.gii
│   │   │   │   ├── sub-C001.L.midthickness.native.surf.gii
│   │   │   │   ├── sub-C001.L.pial.native.surf.gii
│   │   │   │   ├── sub-C001.L.roi.native.shape.gii
│   │   │   │   ├── sub-C001.L.sphere.MSMSulc.native.surf.gii
│   │   │   │   ├── sub-C001.L.sphere.native.surf.gii
│   │   │   │   ├── sub-C001.L.sphere.reg.native.surf.gii
│   │   │   │   ├── sub-C001.L.sphere.reg.reg_LR.native.surf.gii
│   │   │   │   ├── sub-C001.L.sphere.rot.native.surf.gii
│   │   │   │   ├── sub-C001.L.very_inflated.native.surf.gii
│   │   │   │   ├── sub-C001.L.white.native.surf.gii
│   │   │   │   ├── sub-C001.native.wb.spec
│   │   │   │   ├── sub-C001.R.inflated.native.surf.gii
│   │   │   │   ├── sub-C001.R.midthickness.native.surf.gii
│   │   │   │   ├── sub-C001.R.pial.native.surf.gii
│   │   │   │   ├── sub-C001.R.roi.native.shape.gii
│   │   │   │   ├── sub-C001.R.sphere.MSMSulc.native.surf.gii
│   │   │   │   ├── sub-C001.R.sphere.native.surf.gii
│   │   │   │   ├── sub-C001.R.sphere.reg.native.surf.gii
│   │   │   │   ├── sub-C001.R.sphere.reg.reg_LR.native.surf.gii
│   │   │   │   ├── sub-C001.R.sphere.rot.native.surf.gii
│   │   │   │   ├── sub-C001.R.very_inflated.native.surf.gii
│   │   │   │   ├── sub-C001.R.white.native.surf.gii
│   │   │   │   ├── sub-C001.sulc.native.dscalar.nii
│   │   │   │   └── sub-C001.thickness.native.dscalar.nii
│   │   │   ├── Results
│   │   │   ├── ROIs
│   │   │   │   ├── Atlas_ROIs.2.nii.gz
│   │   │   │   └── ROIs.2.nii.gz
│   │   │   ├── sub-C001.164k_fs_LR.wb.spec
│   │   │   ├── sub-C001.aparc.164k_fs_LR.dlabel.nii
│   │   │   ├── sub-C001.aparc.a2009s.164k_fs_LR.dlabel.nii
│   │   │   ├── sub-C001.aparc.DKTatlas.164k_fs_LR.dlabel.nii
│   │   │   ├── sub-C001.ArealDistortion_FS.164k_fs_LR.dscalar.nii
│   │   │   ├── sub-C001.ArealDistortion_MSMSulc.164k_fs_LR.dscalar.nii
│   │   │   ├── sub-C001.BA_exvivo.164k_fs_LR.dlabel.nii
│   │   │   ├── sub-C001.curvature.164k_fs_LR.dscalar.nii
│   │   │   ├── sub-C001.EdgeDistortion_MSMSulc.164k_fs_LR.dscalar.nii
│   │   │   ├── sub-C001.L.atlasroi.164k_fs_LR.shape.gii
│   │   │   ├── sub-C001.L.flat.164k_fs_LR.surf.gii
│   │   │   ├── sub-C001.L.inflated.164k_fs_LR.surf.gii
│   │   │   ├── sub-C001.L.midthickness.164k_fs_LR.surf.gii
│   │   │   ├── sub-C001.L.pial.164k_fs_LR.surf.gii
│   │   │   ├── sub-C001.L.sphere.164k_fs_LR.surf.gii
│   │   │   ├── sub-C001.L.very_inflated.164k_fs_LR.surf.gii
│   │   │   ├── sub-C001.L.white.164k_fs_LR.surf.gii
│   │   │   ├── sub-C001.R.atlasroi.164k_fs_LR.shape.gii
│   │   │   ├── sub-C001.R.flat.164k_fs_LR.surf.gii
│   │   │   ├── sub-C001.R.inflated.164k_fs_LR.surf.gii
│   │   │   ├── sub-C001.R.midthickness.164k_fs_LR.surf.gii
│   │   │   ├── sub-C001.R.pial.164k_fs_LR.surf.gii
│   │   │   ├── sub-C001.R.sphere.164k_fs_LR.surf.gii
│   │   │   ├── sub-C001.R.very_inflated.164k_fs_LR.surf.gii
│   │   │   ├── sub-C001.R.white.164k_fs_LR.surf.gii
│   │   │   ├── sub-C001.sulc.164k_fs_LR.dscalar.nii
│   │   │   ├── sub-C001.thickness.164k_fs_LR.dscalar.nii
│   │   │   ├── T1w.nii.gz
│   │   │   ├── wmparc.nii.gz
│   │   │   └── xfms
│   │   │       ├── NonlinearReg_fromlinear.log
│   │   │       ├── Standard2T1w_warp_noaffine.nii.gz
│   │   │       ├── T1w2StandardLinear.mat
│   │   │       └── T1w2Standard_warp_noaffine.nii.gz
│   │   └── T1w
│   │       ├── aparc.a2009s+aseg.nii.gz
│   │       ├── aparc+aseg.nii.gz
│   │       ├── brainmask_fs.nii.gz
│   │       ├── fsaverage_LR32k
│   │       │   ├── sub-C001.32k_fs_LR.wb.spec
│   │       │   ├── sub-C001.L.inflated.32k_fs_LR.surf.gii
│   │       │   ├── sub-C001.L.midthickness.32k_fs_LR.surf.gii
│   │       │   ├── sub-C001.L.pial.32k_fs_LR.surf.gii
│   │       │   ├── sub-C001.L.sphere.32k_fs_LR.surf.gii
│   │       │   ├── sub-C001.L.very_inflated.32k_fs_LR.surf.gii
│   │       │   ├── sub-C001.L.white.32k_fs_LR.surf.gii
│   │       │   ├── sub-C001.R.inflated.32k_fs_LR.surf.gii
│   │       │   ├── sub-C001.R.midthickness.32k_fs_LR.surf.gii
│   │       │   ├── sub-C001.R.pial.32k_fs_LR.surf.gii
│   │       │   ├── sub-C001.R.sphere.32k_fs_LR.surf.gii
│   │       │   ├── sub-C001.R.very_inflated.32k_fs_LR.surf.gii
│   │       │   └── sub-C001.R.white.32k_fs_LR.surf.gii
│   │       ├── Native
│   │       │   ├── sub-C001.L.inflated.native.surf.gii
│   │       │   ├── sub-C001.L.midthickness.native.surf.gii
│   │       │   ├── sub-C001.L.pial.native.surf.gii
│   │       │   ├── sub-C001.L.very_inflated.native.surf.gii
│   │       │   ├── sub-C001.L.white.native.surf.gii
│   │       │   ├── sub-C001.native.wb.spec
│   │       │   ├── sub-C001.R.inflated.native.surf.gii
│   │       │   ├── sub-C001.R.midthickness.native.surf.gii
│   │       │   ├── sub-C001.R.pial.native.surf.gii
│   │       │   ├── sub-C001.R.very_inflated.native.surf.gii
│   │       │   └── sub-C001.R.white.native.surf.gii
│   │       ├── T1w_brain.nii.gz
│   │       ├── T1w.nii.gz
│   │       └── wmparc.nii.gz
│   └── zz_templates
│       ├── Atlas_ROIs.2.nii.gz
│       ├── colin.cerebral.L.flat.164k_fs_LR.surf.gii
│       ├── colin.cerebral.L.flat.32k_fs_LR.surf.gii
│       ├── colin.cerebral.R.flat.164k_fs_LR.surf.gii
│       ├── colin.cerebral.R.flat.32k_fs_LR.surf.gii
│       ├── fsaverage.L_LR.spherical_std.164k_fs_LR.surf.gii
│       ├── fsaverage.R_LR.spherical_std.164k_fs_LR.surf.gii
│       ├── L.atlasroi.164k_fs_LR.shape.gii
│       ├── L.atlasroi.32k_fs_LR.shape.gii
│       ├── L.sphere.32k_fs_LR.surf.gii
│       ├── R.atlasroi.164k_fs_LR.shape.gii
│       ├── R.atlasroi.32k_fs_LR.shape.gii
│       └── R.sphere.32k_fs_LR.surf.gii
├── fmriprep
│   ├── dataset_description.json
│   ├── desc-aparcaseg_dseg.tsv
│   ├── desc-aseg_dseg.tsv
│   ├── logs
│   │   ├── CITATION.bib
│   │   ├── CITATION.html
│   │   ├── CITATION.md
│   │   └── CITATION.tex
│   ├── sourcedata
│   │   └── freesurfer
│   │       ├── fsaverage
│   │       │   ├── label
│   │       │   ├── mri
│   │       │   ├── mri.2mm
│   │       │   ├── scripts
│   │       │   ├── surf
│   │       │   └── xhemi
│   │       └── sub-C001
│   │           ├── label
│   │           ├── mri
│   │           ├── scripts
│   │           ├── stats
│   │           ├── surf
│   │           ├── tmp
│   │           ├── touch
│   │           └── trash
│   ├── sub-C001
│   │   ├── anat
│   │   │   ├── sub-C001_desc-aparcaseg_dseg.nii.gz
│   │   │   ├── sub-C001_desc-aseg_dseg.nii.gz
│   │   │   ├── sub-C001_desc-brain_mask.json
│   │   │   ├── sub-C001_desc-brain_mask.nii.gz
│   │   │   ├── sub-C001_desc-preproc_T1w.json
│   │   │   ├── sub-C001_desc-preproc_T1w.nii.gz
│   │   │   ├── sub-C001_desc-synthstrip_dseg.nii.gz
│   │   │   ├── sub-C001_from-fsnative_to-T1w_mode-image_xfm.txt
│   │   │   ├── sub-C001_from-MNI152NLin2009cAsym_to-T1w_mode-image_xfm.h5
│   │   │   ├── sub-C001_from-T1w_to-fsnative_mode-image_xfm.txt
│   │   │   ├── sub-C001_from-T1w_to-MNI152NLin2009cAsym_mode-image_xfm.h5
│   │   │   ├── sub-C001_hemi-L_inflated.surf.gii
│   │   │   ├── sub-C001_hemi-L_midthickness.surf.gii
│   │   │   ├── sub-C001_hemi-L_pial.surf.gii
│   │   │   ├── sub-C001_hemi-L_smoothwm.surf.gii
│   │   │   ├── sub-C001_hemi-R_inflated.surf.gii
│   │   │   ├── sub-C001_hemi-R_midthickness.surf.gii
│   │   │   ├── sub-C001_hemi-R_pial.surf.gii
│   │   │   ├── sub-C001_hemi-R_smoothwm.surf.gii
│   │   │   ├── sub-C001_label-CSF_desc-synthstrip_probseg.nii.gz
│   │   │   ├── sub-C001_label-GM_desc-synthstrip_probseg.nii.gz
│   │   │   ├── sub-C001_label-WM_desc-synthstrip_probseg.nii.gz
│   │   │   ├── sub-C001_space-MNI152NLin2009cAsym_desc-brain_mask.json
│   │   │   ├── sub-C001_space-MNI152NLin2009cAsym_desc-brain_mask.nii.gz
│   │   │   ├── sub-C001_space-MNI152NLin2009cAsym_desc-preproc_T1w.json
│   │   │   ├── sub-C001_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
│   │   │   ├── sub-C001_space-MNI152NLin2009cAsym_desc-synthstrip_dseg.nii.gz
│   │   │   ├── sub-C001_space-MNI152NLin2009cAsym_label-CSF_desc-synthstrip_probseg.nii.gz
│   │   │   ├── sub-C001_space-MNI152NLin2009cAsym_label-GM_desc-synthstrip_probseg.nii.gz
│   │   │   └── sub-C001_space-MNI152NLin2009cAsym_label-WM_desc-synthstrip_probseg.nii.gz
│   │   ├── figures
│   │   │   ├── sub-C001_desc-about_T1w.html
│   │   │   ├── sub-C001_desc-conform_T1w.html
│   │   │   ├── sub-C001_desc-reconall_T1w.svg
│   │   │   ├── sub-C001_desc-summary_T1w.html
│   │   │   ├── sub-C001_desc-synthstrip_dseg.svg
│   │   │   └── sub-C001_space-MNI152NLin2009cAsym_desc-synthstrip_T1w.svg
│   │   └── log
│   │       ├── 20221006-235807_a4ffd58c-5176-4f36-9898-65893067fff0
│   │       │   └── fmriprep.toml
│   │       └── 20221007-094420_1844f62d-44eb-474e-b188-8bfab0770b8c
│   │           └── fmriprep.toml
│   └── sub-C001.html
├── gradcorrect
│   ├── dataset_description.json
│   ├── participants.tsv
│   ├── sourcedata
│   │   ├── gradcorrect
│   │   │   └── sub-C001
│   │   │       ├── anat
│   │   │       ├── dwi
│   │   │       └── fmap
│   │   └── scratch
│   │       ├── sub-C001.1591035263.detjac.nii.gz
│   │       ├── sub-C001.1591035263.warp.nii.gz
│   │       ├── sub-C001.1614499974.detjac.nii.gz
│   │       ├── sub-C001.1614499974.warp.nii.gz
│   │       ├── sub-C001.243612401.detjac.nii.gz
│   │       ├── sub-C001.243612401.warp.nii.gz
│   │       ├── sub-C001.2655905243.detjac.nii.gz
│   │       ├── sub-C001.2655905243.warp.nii.gz
│   │       ├── sub-C001.2773381117.detjac.nii.gz
│   │       ├── sub-C001.2773381117.warp.nii.gz
│   │       ├── sub-C001.2955285821.detjac.nii.gz
│   │       ├── sub-C001.2955285821.graddev.nii.gz
│   │       ├── sub-C001.2955285821.warp.nii.gz
│   │       ├── sub-C001.3541686064.detjac.nii.gz
│   │       ├── sub-C001.3541686064.warp.nii.gz
│   │       ├── sub-C001.4173290510.detjac.nii.gz
│   │       ├── sub-C001.4173290510.warp.nii.gz
│   │       ├── sub-C001.702483272.detjac.nii.gz
│   │       ├── sub-C001.702483272.warp.nii.gz
│   │       ├── sub-C001.710399540.detjac.nii.gz
│   │       └── sub-C001.710399540.warp.nii.gz
│   └── sub-C001
│       ├── anat
│       │   ├── sub-C001_acq-MP2RAGE_run-01_T1map.json
│       │   ├── sub-C001_acq-MP2RAGE_run-01_T1map.nii.gz
│       │   ├── sub-C001_acq-MP2RAGE_run-01_T1w.json
│       │   ├── sub-C001_acq-MP2RAGE_run-01_T1w.nii.gz
│       │   ├── sub-C001_acq-SPACE_run-01_T2w.json
│       │   ├── sub-C001_acq-SPACE_run-01_T2w.nii.gz
│       │   ├── sub-C001_acq-TOF_angio.json
│       │   ├── sub-C001_acq-TOF_angio.nii.gz
│       │   ├── sub-C001_acq-TSEcor_run-01_T2w.json
│       │   ├── sub-C001_acq-TSEcor_run-01_T2w.nii.gz
│       │   ├── sub-C001_acq-TSEtra_run-01_T2w.json
│       │   ├── sub-C001_acq-TSEtra_run-01_T2w.nii.gz
│       │   ├── sub-C001_acq-TSEtra_run-02_T2w.json
│       │   ├── sub-C001_acq-TSEtra_run-02_T2w.nii.gz
│       │   ├── sub-C001_acq-UNI_run-01_MP2RAGE.json
│       │   ├── sub-C001_acq-UNI_run-01_MP2RAGE.nii.gz
│       │   ├── sub-C001_inv-1_run-01_MP2RAGE.json
│       │   ├── sub-C001_inv-1_run-01_MP2RAGE.nii.gz
│       │   ├── sub-C001_inv-2_run-01_MP2RAGE.json
│       │   ├── sub-C001_inv-2_run-01_MP2RAGE.nii.gz
│       │   ├── sub-C001_part-mag_echo-1_GRE.json
│       │   ├── sub-C001_part-mag_echo-1_GRE.nii.gz
│       │   ├── sub-C001_part-mag_echo-2_GRE.json
│       │   ├── sub-C001_part-mag_echo-2_GRE.nii.gz
│       │   ├── sub-C001_part-mag_echo-3_GRE.json
│       │   ├── sub-C001_part-mag_echo-3_GRE.nii.gz
│       │   ├── sub-C001_part-mag_echo-4_GRE.json
│       │   ├── sub-C001_part-mag_echo-4_GRE.nii.gz
│       │   ├── sub-C001_part-phase_echo-1_GRE.json
│       │   ├── sub-C001_part-phase_echo-1_GRE.nii.gz
│       │   ├── sub-C001_part-phase_echo-2_GRE.json
│       │   ├── sub-C001_part-phase_echo-2_GRE.nii.gz
│       │   ├── sub-C001_part-phase_echo-3_GRE.json
│       │   ├── sub-C001_part-phase_echo-3_GRE.nii.gz
│       │   ├── sub-C001_part-phase_echo-4_GRE.json
│       │   └── sub-C001_part-phase_echo-4_GRE.nii.gz
│       ├── dwi
│       │   ├── sub-C001_run-01_dwi.bval
│       │   ├── sub-C001_run-01_dwi.bvec
│       │   ├── sub-C001_run-01_dwi.json
│       │   ├── sub-C001_run-01_dwi.nii.gz
│       │   ├── sub-C001_run-02_dwi.bval
│       │   ├── sub-C001_run-02_dwi.bvec
│       │   ├── sub-C001_run-02_dwi.json
│       │   ├── sub-C001_run-02_dwi.nii.gz
│       │   ├── sub-C001_run-03_dwi.bval
│       │   ├── sub-C001_run-03_dwi.bvec
│       │   ├── sub-C001_run-03_dwi.json
│       │   └── sub-C001_run-03_dwi.nii.gz
│       ├── fmap
│       │   ├── sub-C001_acq-b1Div_SA2RAGE.json
│       │   ├── sub-C001_acq-b1Div_SA2RAGE.nii.gz
│       │   ├── sub-C001_acq-b1map_SA2RAGE.json
│       │   ├── sub-C001_acq-b1map_SA2RAGE.nii.gz
│       │   ├── sub-C001_inv-1_SA2RAGE.json
│       │   ├── sub-C001_inv-1_SA2RAGE.nii.gz
│       │   ├── sub-C001_inv-2_SA2RAGE.json
│       │   ├── sub-C001_inv-2_SA2RAGE.nii.gz
│       │   ├── sub-C001_magnitude1.json
│       │   ├── sub-C001_magnitude1.nii.gz
│       │   ├── sub-C001_magnitude2.json
│       │   ├── sub-C001_magnitude2.nii.gz
│       │   ├── sub-C001_phasediff.json
│       │   └── sub-C001_phasediff.nii.gz
│       └── sub-C001_scans.tsv
└── synthstrip
    ├── dataset_description.json
    └── sub-C001
        └── anat
            ├── sub-C001_desc-synthstrip_T1w.nii.gz
            └── sub-C001_space-T1w_brainmask.nii.gz

```
  Citations
  =========
  ### gradcorrect
  https://github.com/khanlab/gradcorrect
  ### 3dMPRAGEise:
  Sriranga Kashyap. (2021). srikash/3dMPRAGEise: ondu (1.0). Zenodo. https://doi.org/10.5281/zenodo.4626825

  ### AFNI:

  Cox RW (1996). AFNI: software for analysis and visualization of functional magnetic resonance neuroimages. Comput Biomed Res 29(3):162-173. doi:10.1006/cbmr.1996.0014 https://pubmed.ncbi.nlm.nih.gov/8812068/
    
  RW Cox, JS Hyde (1997). Software tools for analysis and visualization of FMRI Data. NMR in Biomedicine, 10: 171-178. https://pubmed.ncbi.nlm.nih.gov/9430344/

  ### SynthStrip:
  Hoopes A, Mora JS, Dalca AV, Fischl B, Hoffmann M. SynthStrip: skull-stripping for any brain image. Neuroimage. 2022 Oct 15;260:119474. doi: 10.1016/j.neuroimage.2022.119474. Epub 2022 Jul 13. PMID: 35842095; PMCID: PMC9465771.
  ### Freesurfer:
  Fischl B. FreeSurfer. Neuroimage. 2012 Aug 15;62(2):774-81. doi: 10.1016/j.neuroimage.2012.01.021. Epub 2012 Jan 10. PMID: 22248573; PMCID: PMC3685476.

  ### fMRIPrep:
  Esteban O, Markiewicz CJ, Blair RW, Moodie CA, Isik AI, Erramuzpe A, Kent JD, Goncalves M, DuPre E, Snyder M, Oya H, Ghosh SS, Wright J, Durnez J, Poldrack RA, Gorgolewski KJ. fMRIPrep: a robust preprocessing pipeline for functional MRI. Nat Methods. 2019 Jan;16(1):111-116. doi: 10.1038/s41592-018-0235-4. Epub 2018 Dec 10. PMID: 30532080; PMCID: PMC6319393.

  ### Ciftify:
  Dickie EW, Anticevic A, Smith DE, Coalson TS, Manogaran M, Calarco N, Viviano JD, Glasser MF, Van Essen DC, Voineskos AN. Ciftify: A framework for surface-based analysis of legacy MR acquisitions. Neuroimage. 2019 Aug 15;197:818-826. doi: 10.1016/j.neuroimage.2019.04.078. Epub 2019 May 12. PMID: 31091476; PMCID: PMC6675413.
