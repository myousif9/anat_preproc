if config["grad_coef"] == False:

    rule synthstrip_t2w:
        input:
            t2w=inputs.input_path["t2w"],
        params:
            container_path=config["singularity"]["graham"]["synthstrip"]
            if config["graham"]
            else config["singularity"]["docker"]["synthstrip"],
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
            python {params.synthstrip_script} {params.container_path} -i {input.t2w} -o {output.t2w_skstrip} -m {output.t2w_mask} &> {log}
            """


else:

    rule synthstrip_t2w:
        input:
            gradcorr_done=rules.grad_correction.output.done,
        params:
            t2w=join(
                "derivatives",
                "gradcorrect",
                *inputs.input_path["t2w"].replace(config["bids_dir"], "").split(os.sep)
            ),
            container_path=config["singularity"]["graham"]["synthstrip"]
            if config["graham"]
            else config["singularity"]["docker"]["synthstrip"],
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
