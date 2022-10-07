rule grad_correction:
        input: 
            bids_dir = config['bids_dir'],
            grad_coef_file = config['grad_coef'],
        params:
            grad_corr_dir = bids(
                root = 'derivatives',
                suffix = 'gradcorrect'
            ),
            gradcorrect_script = join(workflow.basedir,'../workflow/scripts/gradcorrect/run.sh')
        output: 
            done = touch(bids(
                root='work',
                suffix = 'gradcorr.done',
                **inputs.input_wildcards['uni']
                ))
        container: config['singularity']['gradcorrect']
        group: 'subj'
        threads: 8
        resources:
            mem_mb = 16000,
            time = 1440
        log: bids(root='logs',suffix='gradcorrect.log',**inputs.input_wildcards['uni'])
        shell:
            """
            {params.gradcorrect_script} {input.bids_dir} {params.grad_corr_dir} participant --grad_coeff_file {input.grad_coef_file} --participant_label {wildcards.subject} &> {log}
            """ 

rule mprageise:
    input:
        gradcorrect_done = rules.grad_correction.output.done,
    params:
        mprageise_script = join(workflow.basedir,'../workflow/scripts/3dMPRAGEise/3dMPRAGEise'),
        uni = join(
            'derivatives',
            'gradcorrect',
            *inputs.input_path['uni'].replace(config['bids_dir'],'').split(os.sep)
            ),
        inv2 = join(
            'derivatives',
            'gradcorrect',
            *inputs.input_path['inv2'].replace(config['bids_dir'],'').split(os.sep)
            ),
    output: 
        mprageised_uni = bids(
            root = 'derivatives/3dmprageise',
            datatype = 'anat',
            desc = 'mprageise',
            suffix = 'T1w.nii.gz',
            **inputs.input_wildcards['uni']
        ),
    container: config['singularity']['afni']
    group: 'subj'
    threads: 8
    resources:
        mem_mb = 16000,
        time = 1440, 
    log: bids(root='logs',suffix='3dmprageise.log',**inputs.input_wildcards['uni'])  
    shell:
        """
        bash {params.mprageise_script} -i {params.inv2} -u {params.uni} -f {output.mprageised_uni} &> {log}
        """