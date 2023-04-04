def infunc_all(wildcards, run_all=True):
    target_list = []

    target_list.extend(
        expand(
            expand(
                rules.synthstrip_t1w.output.t1w_skstrip,
                allow_missing=True,
            ),
            zip,
            **inputs.input_zip_lists[zip_list_key_t1w]
        )
    )

    target_list.extend(
        expand(
            expand(
                rules.mriqc_t1w.output.done,
                allow_missing=True,
            ),
            zip,
            **inputs.input_zip_lists[zip_list_key_t1w]
        ),
    )

    if config['use_t2']:
        target_list.extend(
            expand(
                expand(
                    rules.mriqc_t2w.output.done,
                    allow_missing=True,
                ),
                zip,
                **inputs.input_zip_lists["t2w"]
            ),
        )

        target_list.extend(
            expand(
                expand(
                    rules.synthstrip_t2w.output.t2w_skstrip,
                    allow_missing=True,
                ),
                zip,
                **inputs.input_zip_lists["t2w"]
            ),
        )

    if run_all:
        if config['use_t2']:
            target_list.extend(
                expand(
                    expand(
                        rules.reskstripT2w.output.done,
                        allow_missing=True,
                    ),
                    zip,
                    **inputs.input_zip_lists["t2w"]
                ),
            )

        target_list.extend(
            expand(
                expand(
                    rules.fmriprep.output.done,
                    allow_missing=True,
                ),
                zip,
                **inputs.input_zip_lists[zip_list_key_t1w]
            )
        )

        target_list.extend(
            expand(
                expand(
                    rules.ciftify_recon_all.output.done,
                    allow_missing=True,
                ),
                zip,
                **inputs.input_zip_lists[zip_list_key_t1w]
            )
        )

    return target_list


rule all_skstrip:
    input:
        lambda wildcards: infunc_all(wildcards,run_all=False)
    default_target: True

rule all:
    input:
        infunc_all
    default_target: True