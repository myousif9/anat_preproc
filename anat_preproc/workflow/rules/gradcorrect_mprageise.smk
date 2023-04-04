
if config["grad_coef"] != False:
    rule grad_correction:
        input:
            bids_dir=config["bids_dir"],
            grad_coef_file=config["grad_coef"],
        params:
            grad_corr_dir=bids(root="derivatives", suffix="gradcorrect"),
            gradcorrect_script=join(
                workflow.basedir, "../workflow/scripts/gradcorrect/run.sh"
            ),
        output:
            done=temp(touch(bids(root="work", suffix="gradcorr.done", **inputs.subj_wildcards))),
        container:
            config["singularity"]["graham"]["gradcorrect"] if config["graham"] else config[
                "singularity"
            ]["docker"]["gradcorrect"]
        group:
            "subj"
        threads: 8
        resources:
            mem_mb=16000,
            time=1440,
        log:
            bids(root="logs", suffix="gradcorrect.log", **inputs.subj_wildcards),
        shell:
            """
            {params.gradcorrect_script} {input.bids_dir} {params.grad_corr_dir} participant --grad_coeff_file {input.grad_coef_file} --participant_label {wildcards.subject} &> {log}
            """

if config["gen_t1"]:
    rule mprageise:
        input:
            rule_init= inputs.input_path["uni"] if config['grad_coef'] == False else rules.grad_correction.output.done,
        params:
            uni=inputs.input_path["uni"] if config['grad_coef'] == False else join("derivatives","gradcorrect", get_path(inputs.input_path["uni"])),
            inv2=inputs.input_path["inv2"] if config['grad_coef'] == False else join("derivatives","gradcorrect", get_path(inputs.input_path["inv2"])),
            mprageise_script=join(
                workflow.basedir, "../workflow/scripts/3dMPRAGEise/3dMPRAGEise"
            ),
        output:
            mprageised_t1w=bids(
                root="derivatives/3dmprageise",
                datatype="anat",
                desc="mprageise",
                suffix="T1w.nii.gz",
                **inputs.input_wildcards["uni"]
            ),
        container:
            config["singularity"]["graham"]["afni"] if config["graham"] else config[
                "singularity"
            ]["docker"]["afni"]
        group:
            "subj"
        threads: 8
        resources:
            mem_mb=16000,
            time=180,
        log:
            bids(root="logs", suffix="3dmprageise.log", **inputs.input_wildcards["uni"]),
        shell:
            """
            bash {params.mprageise_script} -i {params.inv2} -u {params.uni} -f {output.mprageised_t1w} &> {log}
            """
