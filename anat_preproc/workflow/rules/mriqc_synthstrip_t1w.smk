rule mriqc_t1w:
    input:
        mprageise_done=rules.mprageise.output.mprageised_uni,
    params:
        mprageise_dir=bids(root="derivatives", suffix="3dmprageise"),
        mriqc_dir=bids(root="derivatives/mriqc", suffix="mriqc_mprageise"),
    output:
        done=touch(
            bids(root="work", suffix="mriqc_t1w.done", **inputs.input_wildcards["uni"])
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
        bids(root="logs", suffix="mriqc_t1w.log", **inputs.input_wildcards["uni"]),
    shell:
        """
        mriqc {params.mprageise_dir} {params.mriqc_dir} participant --participant-label {wildcards.subject} &> {log}
        mriqc {params.mprageise_dir} {params.mriqc_dir} group
        """


rule synthstrip_uni:
    input:
        mprageised_uni=rules.mprageise.output.mprageised_uni,
    params:
        container_path=config["singularity"]["graham"]["synthstrip"]
        if config["graham"]
        else config["singularity"]["docker"]["synthstrip"],
        synthstrip_script=join(
            workflow.basedir, "../workflow/scripts/synthstrip-singularity"
        ),
    output:
        uni_skstrip=bids(
            root="derivatives/synthstrip",
            datatype="anat",
            desc="synthstrip",
            suffix="T1w.nii.gz",
            **inputs.input_wildcards["uni"]
        ),
        uni_mask=bids(
            root="derivatives/synthstrip",
            datatype="anat",
            space="T1w",
            suffix="brainmask.nii.gz",
            **inputs.input_wildcards["uni"]
        ),
    group:
        "subj"
    threads: 8
    resources:
        mem_mb=16000,
        time=180,
    log:
        uni=bids(root="logs", suffix="synthstrip.log", **inputs.input_wildcards["uni"]),
    shell:
        """
        python {params.synthstrip_script} {params.container_path} -i {input.mprageised_uni} -o {output.uni_skstrip} -m {output.uni_mask} &> {log}
        """
