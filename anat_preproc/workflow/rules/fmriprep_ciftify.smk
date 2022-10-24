rule fmriprep:
    input:
        t1w = rules.synthstrip_uni.output.uni_skstrip,
        # t2w = rules.synthstrip_t2w.output.t2w_skstrip,
        fs_license = os.environ['FS_LICENSE'] if config['fs_license'] == False else config['fs_license'],
    params:
        synthstrip_dir =bids(
            root = 'derivatives',
            suffix = 'synthstrip'
        ),
        fmriprep_outdir = bids(
            root = 'derivatives',
            suffix = 'fmriprep'
        ),
        freesurfer_dir = bids(
            root = 'derivatives',
            suffix = 'freesurfer'
        ),
        dataset_description = join(workflow.basedir,'../resources/dataset_description.json'),
        work_directory = bids(
            root = 'work',
            suffix = 'fmriprep',
        ),
        fmriprep_opts = config['fmriprep_opts'],
        container = config['singularity']['graham']['fmriprep'] if config['graham'] else config['singularity']['docker']['fmriprep'],
    output: 
        done = touch(bids(
            root = 'work',
            suffix = 'fmriprep.done',
            **inputs.input_wildcards['uni']
        ))
    group: 'subj'
    threads: 8
    resources:
        mem_mb = 16000,
        time = 1440
    log: bids(root='logs',suffix='fmriprep.log',**inputs.input_wildcards['uni'])
    shell:
        """
        cp -n {params.dataset_description} {params.synthstrip_dir}
        mkdir -p {params.work_directory}
        mkdir -p {params.fmriprep_outdir}

        singularity run --cleanenv \
        -B {params.synthstrip_dir}:/data \
        -B {params.fmriprep_outdir}:/out \
        -B {params.work_directory}:/work \
        -B {input.fs_license}:/opt/freesurfer/license.txt \
        {params.container} /data {params.fmriprep_outdir} participant \
        --participant_label {wildcards.subject} --skip_bids_validation --skull-strip-t1w skip -w /work \
        {params.fmriprep_opts} &> {log}
        """

rule ciftify_recon_all:
    input: 
        fmriprep_done =  rules.fmriprep.output.done,
        fs_license = os.environ['FS_LICENSE'] if config['fs_license'] == False else config['fs_license'],
    params:
        freesurfer_dir = bids(
            root = 'derivatives/fmriprep/sourcedata',
            suffix = 'freesurfer'
        ),
        ciftify_outdir = bids(
            root = 'derivatives',
            suffix = 'ciftify'
        ),
        ciftify_opts = config['ciftify_opts'],
    output: 
        done = touch(bids(
            root = 'work',
            suffix = 'ciftify.done',
            **inputs.input_wildcards['uni']
        )),
    container: config['singularity']['graham']['ciftify'] if config['graham'] else config['singularity']['docker']['ciftify'] 
    group: 'subj'
    threads: 8
    resources:
        mem_mb = 16000,
        time = 1440
    log: bids(root='logs',suffix='ciftifyreconall.log',**inputs.input_wildcards['uni'])
    shell:
        """
        ciftify_recon_all {params.ciftify_opts} --ciftify-work-dir '{params.ciftify_outdir}' --fs-subjects-dir '{params.freesurfer_dir}' --fs-license '{input.fs_license}' --n_cpus '{threads}' 'sub-{wildcards.subject}' &> {log}
        cifti_vis_recon_all subject --ciftify-work-dir '{params.ciftify_outdir}' 'sub-{wildcards.subject}' &> {log}
        cifti_vis_recon_all index --ciftify-work-dir '{params.ciftify_outdir}' &> {log}
        """