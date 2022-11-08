rule all_skstrip:
    input:
        expand(
            expand(
                rules.synthstrip_uni.output.uni_skstrip,
                allow_missing=True,
            ),
            zip,
            **inputs.input_zip_lists["uni"]
        ),
        expand(
            expand(
                rules.mriqc_t1w.output.done,
                allow_missing=True,
            ),
            zip,
            **inputs.input_zip_lists["uni"]
        ),
    default_target: True


rule all:
    input:
        expand(
            expand(
                rules.synthstrip_uni.output.uni_skstrip,
                allow_missing=True,
            ),
            zip,
            **inputs.input_zip_lists["uni"]
        ),
        expand(
            expand(
                rules.mriqc_t1w.output.done,
                allow_missing=True,
            ),
            zip,
            **inputs.input_zip_lists["uni"]
        ),
        expand(
            expand(
                rules.fmriprep.output.done,
                allow_missing=True,
            ),
            zip,
            **inputs.input_zip_lists["uni"]
        ),
        expand(
            expand(
                rules.ciftify_recon_all.output.done,
                allow_missing=True,
            ),
            zip,
            **inputs.input_zip_lists["uni"]
        ),
    default_target: True
