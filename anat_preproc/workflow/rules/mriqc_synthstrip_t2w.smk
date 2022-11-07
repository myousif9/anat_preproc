rule mriqc_t2w:
    input:
        init_file = inputs.input_path["t2w"] if config["grad_coef"] == False else rules.grad_correction.output.done,
    params:
        bids_dir = config['bids_dir'],
        mriqc_dir=bids(root="derivatives/mriqc", suffix="mriqc_mprageise"),
    output:
        done=touch(
            bids(root="work", suffix="mriqc_t2w.done", **inputs.input_wildcards["t2w"])
        ),
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
        bids(root="logs", suffix="mriqc_t2w.log", **inputs.input_wildcards["t2w"]),
    shell:
        """
        mriqc {params.bids_dir} {params.mriqc_dir} participant --participant-label {wildcards.subject} --modalities T2w &> {log}
        mriqc {params.bids_dir} {params.mriqc_dir} group
        """

rule synthstrip_t2w:
    input:
        init_file = inputs.input_path["t2w"] if config["grad_coef"] == False else rules.grad_correction.output.done,
    params:
        t2w= inputs.input_path["t2w"] if config['grad_coef'] == False  else join("derivatives","gradcorrect",get_path(inputs.input_path['t2w'])),
        container_path=config["singularity"]["graham"]["synthstrip"] if config["graham"] else config["singularity"]["docker"]["synthstrip"],
        synthstrip_script=join(
            workflow.basedir, "../workflow/scripts/synthstrip-singularity"
        ),
    output:
        t2w_skstrip=bids(
            root="derivatives/synthstrip",
            datatype="anat",
            desc="synthstrip",
            suffix="T2w.nii.gz",
            **inputs.input_wildcards["t2w"]
        ),
        t2w_mask=bids(
            root="derivatives/synthstrip",
            datatype="anat",
            space="T2w",
            suffix="brainmask.nii.gz",
            **inputs.input_wildcards["t2w"]
        ),
    group:
        "subj"
    threads: 8
    resources:
        mem_mb=16000,
        time=180,
    log:
        bids(root="logs", suffix="synthstrip.log", **inputs.input_wildcards["t2w"]),
    shell:
        """
        python {params.synthstrip_script} {params.container_path} -i {params.t2w} -o {output.t2w_skstrip} -m {output.t2w_mask} &> {log}
        """
