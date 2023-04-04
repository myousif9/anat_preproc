if config["use_t2"]:

    rule reskstripT2w:
        input:
            t2w_mask=rules.synthstrip_t2w.output.t2w_mask,
        params:
            t2w=inputs.input_path["t2w"]
            if config["grad_coef"] == False
            else join(
                "derivatives",
                "gradcorrect",
                get_path(inputs.input_path["t2w"])
            ),
            t2w_skstrip=bids(
                root="derivatives/synthstrip",
                datatype="anat",
                desc="synthstrip",
                suffix="T2w.nii.gz",
                **inputs.input_wildcards["t2w"]
            ),
        output:
            done=temp(
                touch(
                bids(
                    root="work",
                    suffix="reskstripT2w.done",
                    **inputs.input_wildcards["t2w"]
                )
            )),
        container:
            config["singularity"]["graham"]["fmriprep"] if config["graham"] else config[
                "singularity"
            ]["docker"]["fmriprep"]
        group:
            "subj"
        shell:
            """
            fslmaths {params.t2w} -mul {input.t2w_mask} {params.t2w}
            """


rule reskstripT1w:
    input:
        t1w_mask=rules.synthstrip_t1w.output.t1w_mask,
    params:
        t1w=rules.mprageise.output.mprageised_t1w if config["gen_t1"] else inputs.input_path['t1w'],
        t1w_skstrip=bids(
            root="derivatives/synthstrip",
            datatype="anat",
            desc="synthstrip",
            suffix="T1w.nii.gz",
            **inputs.input_wildcards[zip_list_key_t1w]
        ),
    output:
        done=temp(touch(
            bids(
                root="work",
                suffix="reskstripT1w.done",
                **inputs.input_wildcards[zip_list_key_t1w]
            )
        )),
    container:
        config["singularity"]["graham"]["fmriprep"] if config["graham"] else config[
            "singularity"
        ]["docker"]["fmriprep"]
    group:
        "subj"
    shell:
        """
        fslmaths {params.t1w} -mul {input.t1w_mask} {params.t1w_skstrip}
        """


rule fmriprep:
    input:
        skstrip_T1w_done = rules.reskstripT1w.output.done,
        skstrip_T2w_done = rules.reskstripT2w.output.done if config['use_t2'] else [],
        fs_license=os.environ["FS_LICENSE"]
        if config["fs_license"] == False
        else config["fs_license"],
    params:
        synthstrip_dir=bids(root="derivatives", suffix="synthstrip"),
        fmriprep_outdir=bids(root="derivatives", suffix="fmriprep"),
        freesurfer_dir=bids(root="derivatives", suffix="freesurfer"),
        dataset_description=join(
            workflow.basedir, "../resources/dataset_description.json"
        ),
        work_directory=bids(
            root="work",
            suffix="fmriprep",
        ),
        fmriprep_opts=config["fmriprep_opts"],
        container=config["singularity"]["graham"]["fmriprep"]
        if config["graham"]
        else config["singularity"]["docker"]["fmriprep"],
    output:
        done=temp(touch(
            bids(root="work", suffix="fmriprep.done", **inputs.input_wildcards[zip_list_key_t1w])
        )),
    group:
        "subj"
    threads: 8
    resources:
        mem_mb=16000,
        time=1440,
    log:
        bids(root="logs", suffix="fmriprep.log", **inputs.input_wildcards[zip_list_key_t1w]),
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
        fmriprep_done=rules.fmriprep.output.done,
        fs_license=os.environ["FS_LICENSE"]
        if config["fs_license"] == False
        else config["fs_license"],
    params:
        freesurfer_dir=bids(root="derivatives/fmriprep/sourcedata", suffix="freesurfer"),
        ciftify_outdir=bids(root="derivatives", suffix="ciftify"),
        ciftify_opts=config["ciftify_opts"],
    output:
        done=temp(touch(
            bids(root="work", suffix="ciftify.done", **inputs.input_wildcards[zip_list_key_t1w])
        )),
    container:
        config["singularity"]["graham"]["ciftify"] if config["graham"] else config[
            "singularity"
        ]["docker"]["ciftify"]
    group:
        "subj"
    threads: 8
    resources:
        mem_mb=16000,
        time=1440,
    log:
        bids(root="logs", suffix="ciftifyreconall.log", **inputs.input_wildcards[zip_list_key_t1w]),
    shell:
        """
        ciftify_recon_all {params.ciftify_opts} --ciftify-work-dir '{params.ciftify_outdir}' --fs-subjects-dir '{params.freesurfer_dir}' --fs-license '{input.fs_license}' --n_cpus '{threads}' 'sub-{wildcards.subject}' &> {log}
        cifti_vis_recon_all subject --ciftify-work-dir '{params.ciftify_outdir}' 'sub-{wildcards.subject}' &> {log}
        cifti_vis_recon_all index --ciftify-work-dir '{params.ciftify_outdir}' &> {log}
        """
