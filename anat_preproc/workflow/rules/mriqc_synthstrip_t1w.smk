rule mriqc_t1w:
    input:
        mprageise_done= rules.mprageise.output.mprageised_t1w if config['gen_t1'] else inputs.input_path['t1w'],
    params:
        t1w_dir=bids(root="derivatives", suffix="3dmprageise") if config["gen_t1"] else config['bids_dir'],
        mriqc_dir=bids(root="derivatives", suffix="mriqc"),
        # symlink_dir = temp(directory('work/bids_dir')) if (config['gen_t1'] == False) & (config['derivatives'] == False) else 'False'
    output:
        done=temp(touch(
            bids(root="work", suffix="mriqc_t1w.done", **inputs.input_wildcards[zip_list_key_t1w])
        )),
    group:
        "subj"
    container:
        config["singularity"]["graham"]["mriqc"] if config["graham"] else config[
            "singularity"
        ]["docker"]["mriqc"]
    threads: 8
    resources:
        mem_mb=16000,
        time=180,
    log:
        bids(root="logs", suffix="mriqc_t1w.log", **inputs.input_wildcards[zip_list_key_t1w]),
    shell:
        """
        mriqc {params.t1w_dir} {params.mriqc_dir} participant --participant-label {wildcards.subject} --modalities T1w --no-sub --verbose-reports &> {log}
        mriqc {params.t1w_dir} {params.mriqc_dir} group
        """


rule synthstrip_t1w:
    input:
        mriqc_done = rules.mriqc_t1w.output.done,
        t1w=rules.mprageise.output.mprageised_t1w if config['gen_t1'] else inputs.input_path['t1w'],
    params:
        container_path=config["singularity"]["graham"]["synthstrip"]
        if config["graham"]
        else config["singularity"]["docker"]["synthstrip"],
        synthstrip_script=join(
            workflow.basedir, "../workflow/scripts/synthstrip-singularity"
        ),
    output:
        t1w_skstrip=bids(
            root="derivatives/synthstrip",
            datatype="anat",
            desc="synthstrip",
            suffix="T1w.nii.gz",
            **inputs.input_wildcards[zip_list_key_t1w]
        ),
        t1w_mask=bids(
            root="derivatives/synthstrip",
            datatype="anat",
            space="T1w",
            suffix="brainmask.nii.gz",
            **inputs.input_wildcards[zip_list_key_t1w]
        ),
    group:
        "subj"
    threads: 8
    resources:
        mem_mb=16000,
        time=180,
    log:
        bids(root="logs", suffix="synthstrip.log", **inputs.input_wildcards[zip_list_key_t1w]),
    shell:
        """
        python {params.synthstrip_script} {params.container_path} -i {input.t1w} -o {output.t1w_skstrip} -m {output.t1w_mask} &> {log}
        """


'/project/6050199/akhanf/ext-bids/AOMIC/ds002785/sub-{subject}/anat/sub-{subject}_T1w.nii.gz',
'/project/6050199/akhanf/ext-bids/AOMIC/ds002785/sub-{subject}/sub-{subject}/anat/sub-{subject}_T1w.nii.gz'