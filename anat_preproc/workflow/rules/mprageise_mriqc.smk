rule mriqc:
    input:
        bids_dir = config['bids_dir'],
    params:
        mriqc_dir = bids(
            root = 'derivatives',
            suffix = 'mriqc'
        ),
    output: 
        done = touch(bids(
            root = 'work',
            suffix = 'mriqc.done',
            **inputs.input_wildcards['uni']
        ))
    group: 'subj'
    container: config['singularity']['graham']['mriqc'] if config['graham'] else config['singularity']['docker']['mriqc'] 
    threads: 8
    resources:
        mem_mb = 16000,
        time = 1440, 
    log: bids(root='logs',suffix='mriqc.log',**inputs.input_wildcards['uni'])  
    shell:
        """
        mriqc {input.bids_dir} {params.mriqc_dir} participant --participant-label {wildcards.subject} &> {log}
        """

rule mprageise:
        input:
            uni = inputs.input_path['uni'],
            inv2 = inputs.input_path['inv2'],
        params:
            mprageise_script = join(workflow.basedir,'../workflow/scripts/3dMPRAGEise/3dMPRAGEise')
        output: 
            mprageised_uni = bids(
                root = 'derivatives/3dmprageise',
                datatype = 'anat',
                desc = 'mprageise',
                suffix = 'T1w.nii.gz',
                **inputs.input_wildcards['uni']
            ),
        container: config['singularity']['graham']['afni'] if config['graham'] else config['singularity']['docker']['afni']
        group: 'subj'
        threads: 8
        resources:
            mem_mb = 16000,
            time = 1440, 
        log: bids(root='logs',suffix='3dmprageise.log',**inputs.input_wildcards['uni'])  
        shell:
            """
            bash {params.mprageise_script} -i {input.inv2} -u {input.uni} -f {output.mprageised_uni} &> {log}
            """