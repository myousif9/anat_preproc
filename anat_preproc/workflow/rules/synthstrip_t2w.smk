rule synthstrip_t2w:
    input:
        t2w = inputs.input_path['t2w'],
    params:
        container_path = config['singularity']['synthstrip'],
        synthstrip_script = join(workflow.basedir,'../workflow/scripts/synthstrip-singularity')
    output: 
        t2w_skstrip = bids(
            root = 'derivatives/synthstrip',
            datatype = 'anat',
            desc = 'synthstrip',
            suffix = 'T2w.nii.gz',
            **inputs.input_wildcards['t2w']
        ),
        t2w_mask = bids(
            root = 'derivatives/synthstrip',
            datatype = 'anat',
            space = 'T2w',
            suffix = 'brainmask.nii.gz',
            **inputs.input_wildcards['t2w']
        ),
    group: 'subj'
    threads: 8
    resources:
        mem_mb = 16000,
        time = 180 
    log: 
        bids(root='logs',suffix='synthstrip.log',**inputs.input_wildcards['t2w'])
    shell:
        """
        python {params.synthstrip_script} {params.container_path} -i {input.t2w} -o {output.t2w_skstrip} -m {output.t2w_mask} &> {log}
        """ 